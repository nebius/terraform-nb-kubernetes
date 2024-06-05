locals {
  # Generating node groups locations list for auto_scale policy
  chunked_node_groups_keys = var.node_groups != null ? chunklist(tolist(keys(var.node_groups)), length(coalesce(try(var.node_locations, []), [var.master_locations[0]]))) : []
  auto_node_groups_locations = length(local.chunked_node_groups_keys) > 0 ? concat([
    for x, list in local.chunked_node_groups_keys : concat([
      for y, name in list : {
        node_group_name = name
        zone            = try(coalesce(try(var.node_locations, []), [var.master_locations[0]])[y].zone, var.master_locations[0].zone)
        subnet_id       = try(coalesce(try(var.node_locations, []), [var.master_locations[0]])[y].subnet_id, var.master_locations[0].subnet_id)
      }
    ])
  ]...) : []
  node_locations_subnets_ids = concat(flatten([for location in coalesce(try(var.node_locations, []), [var.master_locations[0]]) : try(location.subnet_id, var.master_locations[0].subnet_id)]))

  master_locations_subnets_ids = concat(flatten([for location in var.master_locations : location.subnet_id]))
}

resource "nebius_kubernetes_node_group" "kube_node_groups" {
  for_each = var.node_groups

  cluster_id  = nebius_kubernetes_cluster.kube_cluster.id
  name        = each.key
  description = lookup(each.value, "description", null)
  version     = lookup(each.value, "version", var.cluster_version)
  labels      = lookup(each.value, "labels", {})

  instance_template {
    platform_id = lookup(each.value, "platform_id", var.node_groups_defaults.platform_id)

    resources {
      cores         = lookup(each.value, "node_cores", var.node_groups_defaults.node_cores)
      core_fraction = lookup(each.value, "core_fraction", var.node_groups_defaults.core_fraction)
      memory        = lookup(each.value, "node_memory", var.node_groups_defaults.node_memory)
      gpus          = lookup(each.value, "node_gpus", var.node_groups_defaults.node_gpus)
    }

    dynamic "gpu_settings" {
      for_each = compact([lookup(each.value, "gpu_cluster_id", null)])
      content {
        gpu_cluster_id  = each.value.gpu_cluster_id
        gpu_environment = each.value.gpu_environment
      }
    }

    boot_disk {
      type = lookup(each.value, "disk_type", var.node_groups_defaults.disk_type)
      size = lookup(each.value, "disk_size", var.node_groups_defaults.disk_size)
    }

    scheduling_policy {
      preemptible = lookup(each.value, "preemptible", var.node_groups_defaults.preemptible)
    }

    dynamic "placement_policy" {
      for_each = compact([lookup(each.value, "placement_group_id", null)])
      content {
        placement_group_id = placement_policy.value
      }
    }

    network_interface {
      subnet_ids = flatten([
        for location in coalesce(try(each.value["node_locations"], []), [var.master_locations[0]]) : try(location.subnet_id, var.master_locations[0].subnet_id)
      ])

      nat                = lookup(each.value, "nat", var.node_groups_defaults.nat)
      ipv4               = lookup(each.value, "ipv4", var.node_groups_defaults.ipv4)
      ipv6               = lookup(each.value, "ipv6", var.node_groups_defaults.ipv6)
      security_group_ids = local.security_groups_list

      dynamic "ipv4_dns_records" {
        for_each = lookup(each.value, "ipv4_dns_records_options", [])
        content {
          fqdn        = try(ipv4_dns_records.value["fqdn"], null)
          dns_zone_id = try(ipv4_dns_records.value["dns_zone_id"], null)
          ttl         = try(ipv4_dns_records.value["ttl"], null)
          ptr         = try(ipv4_dns_records.value["ptr"], null)
        }
      }
      dynamic "ipv6_dns_records" {
        for_each = lookup(each.value, "ipv6_dns_records_options", [])
        content {
          fqdn        = try(ipv6_dns_records.value["fqdn"], null)
          dns_zone_id = try(ipv6_dns_records.value["dns_zone_id"], null)
          ttl         = try(ipv6_dns_records.value["ttl"], null)
          ptr         = try(ipv6_dns_records.value["ptr"], null)
        }
      }
    }

    container_network {
      pod_mtu = lookup(each.value, "pod_mtu", var.pod_mtu)
    }

    network_acceleration_type = lookup(each.value, "network_acceleration_type", var.network_acceleration_type)

    dynamic "container_runtime" {
      for_each = compact([lookup(each.value, "container_runtime_type", var.container_runtime_type)])
      content {
        type = container_runtime.value
      }
    }
  }

  node_labels            = try(each.value.node_labels, null)
  node_taints            = try(each.value.node_taints, null)
  allowed_unsafe_sysctls = try(each.value.allowed_unsafe_sysctls, null)

  scale_policy {
    dynamic "fixed_scale" {
      for_each = flatten([lookup(each.value, "fixed_scale", can(each.value["auto_scale"]) ? [] : [{ size = 1 }])])
      content {
        size = fixed_scale.value.size
      }
    }

    dynamic "auto_scale" {
      for_each = flatten([lookup(each.value, "auto_scale", [])])
      content {
        min     = auto_scale.value.min
        max     = auto_scale.value.max
        initial = auto_scale.value.initial
      }
    }
  }

  allocation_policy {
    dynamic "location" {
      for_each = coalesce(try(each.value["node_locations"], []), [var.master_locations[0]])
      content {
        zone = try(location.value.zone, var.master_locations[0].zone)
      }
    }
  }

  maintenance_policy {
    auto_repair  = var.master_auto_upgrade
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

  dynamic "deploy_policy" {
    for_each = anytrue([can(each.value["max_expansion"]), can(each.value["max_unavailable"])]) ? [{
      max_expansion   = each.value.max_expansion
      max_unavailable = each.value.max_unavailable
    }] : []

    content {
      max_expansion   = each.value.max_expansion
      max_unavailable = each.value.max_unavailable
    }
  }
}
