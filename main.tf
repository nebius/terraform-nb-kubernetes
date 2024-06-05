locals {
  folder_id = var.folder_id == null ? data.nebius_client_config.client.folder_id : var.folder_id
  node_locations = length(var.node_locations) == 0 ? [var.master_locations[0]] : var.node_locations

  master_regions = length(var.master_locations) > 1 ? [{
    region    = var.master_region
    locations = var.master_locations
  }] : []

  master_locations = length(var.master_locations) > 1 ? [] : var.master_locations

  security_groups_list = concat(var.security_groups_ids_list, var.enable_default_rules == true ? [
    nebius_vpc_security_group.k8s_main_sg[0].id,
    nebius_vpc_security_group.k8s_master_whitelist_sg[0].id,
    nebius_vpc_security_group.k8s_nodes_ssh_access_sg[0].id
    ] : [], length(var.custom_ingress_rules) > 0 || length(var.custom_egress_rules) > 0 ? [
    nebius_vpc_security_group.k8s_custom_rules_sg[0].id
  ] : [])

  # Merging master labels with node group labels
  node_groups_labels = concat([
    for i, v in tolist(keys(var.node_groups)) : lookup(var.node_groups[v], "labels", {})
  ])
  merged_node_labels_with_master = merge(zipmap(
    flatten([for item in local.node_groups_labels : keys(item)]),
    flatten([for item in local.node_groups_labels : values(item)])
  ), var.master_labels)
}

resource "nebius_kubernetes_cluster" "kube_cluster" {
  name                     = "${var.cluster_name}-${random_string.unique_id.result}"
  description              = var.description
  folder_id                = local.folder_id
  network_id               = var.network_id
  labels                   = try(local.merged_node_labels_with_master, {})
  cluster_ipv4_range       = var.cluster_ipv4_range
  cluster_ipv6_range       = var.cluster_ipv6_range
  node_ipv4_cidr_mask_size = var.node_ipv4_cidr_mask_size
  service_ipv4_range       = var.service_ipv4_range
  service_ipv6_range       = var.service_ipv6_range
  service_account_id       = nebius_iam_service_account.master.id
  node_service_account_id  = nebius_iam_service_account.node_account.id
  network_policy_provider  = var.enable_cilium_policy ? null : var.network_policy_provider


  dynamic "network_implementation" {
    for_each = var.enable_cilium_policy ? ["cilium"] : []
    content {
      cilium {}
    }
  }

  master {
    version            = var.cluster_version
    public_ip          = var.public_access
    security_group_ids = local.security_groups_list

    dynamic "zonal" {
      for_each = local.master_locations
      content {
        zone      = zonal.value["zone"]
        subnet_id = zonal.value["subnet_id"]
      }
    }

    dynamic "regional" {
      for_each = local.master_regions
      content {
        region = regional.value["region"]
        dynamic "location" {
          for_each = regional.value["locations"]
          content {
            zone      = location.value["zone"]
            subnet_id = location.value["subnet_id"]
          }
        }
      }
    }

    maintenance_policy {
      auto_upgrade = var.master_auto_upgrade

      dynamic "maintenance_window" {
        for_each = var.master_maintenance_windows
        content {
          day        = maintenance_window.value.day
          start_time = maintenance_window.value.start_time
          duration   = maintenance_window.value.duration
        }
      }
    }
  }

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  depends_on = [
    nebius_resourcemanager_folder_iam_member.node_account,
    nebius_resourcemanager_folder_iam_member.sa_calico_network_policy_role,
    nebius_resourcemanager_folder_iam_member.sa_cilium_network_policy_role,
    nebius_resourcemanager_folder_iam_member.sa_node_group_public_role_admin,
    nebius_resourcemanager_folder_iam_member.sa_node_group_loadbalancer_role_admin,
    nebius_resourcemanager_folder_iam_member.sa_logging_writer_role,
    nebius_resourcemanager_folder_iam_member.sa_public_loadbalancers_role
  ]

}
