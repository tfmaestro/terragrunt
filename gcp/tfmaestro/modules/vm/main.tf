data "google_compute_subnetwork" "subnet" {
  name    = "prod-subnet-01"
  region  = var.region
  project = var.project
}

resource "google_compute_instance" "main" {
  for_each            = var.compute_engines
  name                = each.key
  project             = var.project
  machine_type        = each.value["machine_type"]
  description         = try(each.value["machine_description"], null)
  zone                = each.value["machine_location"]
  can_ip_forward      = var.ip_forward
  deletion_protection = var.deletion_protection
  tags                = each.value["network_tags"]
  labels              = var.machine_labels

  boot_disk {
    device_name = each.key
    initialize_params {
      image = var.boot_image
    }
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.subnet.self_link 
    network_ip = google_compute_address.internal[each.key].address

    access_config {
    }
  }

  metadata = {
    startup-script = file("${path.module}/startup-script.sh")
    ssh-keys = join("\n", [
      "damian:${file("${path.module}/ssh/damian_key.pub")}",
      "kasia:${file("${path.module}/ssh/kasia_key.pub")}"
    ])
  }
}

resource "google_compute_address" "internal" {
  for_each     = var.compute_engines
  name         = "${each.key}-internal"
  description  = "The internal IP address for machine ${each.key}"
  region       = var.region
  subnetwork   = data.google_compute_subnetwork.subnet.self_link 
  project      = var.project
  address_type = "INTERNAL"
  address = (
    cidrhost(var.subnetwork_ip_cidr_range,
    each.value["ip_host"])
  )
}

