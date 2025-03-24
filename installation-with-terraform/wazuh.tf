resource "lxd_instance" "wazuh" {
  name     = "wazuh"
  image    = "ubuntu2204"
  profiles = ["default"]

  limits = {
    cpu    = "4"
    memory = "8GB"
  }
}