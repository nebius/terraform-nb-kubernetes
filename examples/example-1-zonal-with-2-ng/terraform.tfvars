
folder_id            = "bjer0eu4okh6vntopouq"
network_id           = "btcci5d99ka84l988qvs"
cluster_name         = "kube-regional-cluster"
cluster_version      = "1.23"
description          = "Kubernetes test cluster"
public_access        = false
create_kms           = false
enable_cilium_policy = false


#PORT TO MODULE


# kms_key = {
#   name = "kube-regional-kms-key"
# }

# master_maintenance_windows = [
#   {
#     day        = "monday"
#     start_time = "23:00"
#     duration   = "3h"
#   }
# ]

# master_labels = {
#   environment = "dev"
#   owner       = "example"
#   role        = "master"
#   service     = "kubernetes"
# }

# node_groups = {
#   "yc-k8s-ng-01" = {
#     description = "Kubernetes nodes group 01 with fixed 1 size scaling"
#     auto_scale = {
#       min     = 2
#       max     = 4
#       initial = 2
#     }
#   },
#   "yc-k8s-ng-02" = {
#     description = "Kubernetes nodes group 02 with auto scaling"
#     auto_scale = {
#       min     = 2
#       max     = 4
#       initial = 2
#     }
#   }
# }
