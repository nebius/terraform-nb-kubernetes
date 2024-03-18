output "cluster_id" {
  description = "Kubernetes cluster ID."
  value       = try(nebius_kubernetes_cluster.kube_cluster.id, null)
}

output "cluster_name" {
  description = "Kubernetes cluster name."
  value       = try(nebius_kubernetes_cluster.kube_cluster.name, null)
}

output "external_v4_endpoint" {
  description = "Kubernetes external IPv4 endpoint."
  value       = nebius_kubernetes_cluster.kube_cluster.master[0].external_v4_endpoint
}

output "internal_v4_endpoint" {
  description = "Kubernetes internal IPv4 endpoint."
  value       = nebius_kubernetes_cluster.kube_cluster.master[0].internal_v4_endpoint
}

output "cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate."
  value       = nebius_kubernetes_cluster.kube_cluster.master[0].cluster_ca_certificate
}

# public ip with kube config download command 
output "external_cluster_cmd" {
  description = <<EOF
    Kubernetes cluster public IP address.
    Use the following command to download kube config and start working with Nebius Managed Kubernetes cluster:
    `$ ncp managed-kubernetes cluster get-credentials --id <cluster_id> --external`
    This command will automatically add kube config for your user; after that, you will be able to test it with the
    `kubectl get cluster-info` command.
  EOF
  value       = var.public_access ? "ncp managed-kubernetes cluster get-credentials --id ${nebius_kubernetes_cluster.kube_cluster.id} --external" : null
}

# private ip with kube config download command
output "internal_cluster_cmd" {
  description = <<EOF
    Kubernetes cluster private IP address.
    Use the following command to download kube config and start working with Nebius Managed Kubernetes cluster:
    `$ ncp managed-kubernetes cluster get-credentials --id <cluster_id> --internal`
    Note: Kubernetes internal cluster nodes are available from the virtual machines in the same VPC as cluster nodes.
  EOF
  value       = var.public_access == false ? "ncp managed-kubernetes cluster get-credentials --id ${nebius_kubernetes_cluster.kube_cluster.id} --internal" : null
}
