# Creating a container c1
resource "lxd_instance" "c1" {
  name     = "c1"
  image    = "ubuntu2204"
  profiles = ["default"]

  limits = {
    cpu    = "0,1"
    memory = "256MB"
  }
}

# Creating a container c2
resource "lxd_instance" "c2" {
  name     = "c2"
  image    = "ubuntu2204"
  profiles = ["default"]

  limits = {
    cpu    = "0,1"
    memory = "256MB"
  }
}