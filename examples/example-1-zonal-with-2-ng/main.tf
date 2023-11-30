

module "kube" {
  source = "../../"

  network_id =  "btcci5d99ka84l988qvs"

  master_locations = [
    {
      zone      = "eu-north1-c"
      subnet_id = "f8ut3srsmjrlor5uko84"
    }
  ]


  master_labels = {
    environment = "dev"
    owner       = "example"
    role        = "master"
    service     = "kubernetes"
  }

  master_maintenance_windows = [
    {
      day        = "monday"
      start_time = "20:00"
      duration   = "3h"
    }
  ]
  node_groups = {
   "k8s-ng-h100-8gpu1" = {
      description = "Kubernetes nodes h100-8-gpu nodes with autoscaling"
      fixed_scale = {
        size = 2
      }
      platform_id     = "gpu-h100"
      gpu_environment = "runc"
      node_cores      = 160
      node_memory     = 1280
      node_gpus       = 8
      disk_type       = "network-ssd-nonreplicated"
      disk_size       = 372
      nat = true
      node_labels = {
        "group" = "h100-8gpu"
      }
    }
  }
}


