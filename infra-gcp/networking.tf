resource "google_compute_network" "vpc" {
  name                    = "${var.resource_group_name}-vn"
  auto_create_subnetworks = false
  project                 = var.resource_group_name
}

resource "google_compute_subnetwork" "master" {
  name          = "${var.resource_group_name}-master-subnet"
  ip_cidr_range = var.master_subnet_cidr
  region       = var.resource_group_location
  network       = google_compute_network.vpc.name
  project                 = var.resource_group_name
}

resource "google_compute_subnetwork" "admin" {
  name          = "${var.resource_group_name}-admin-subnet"
  ip_cidr_range = var.admin_subnet_cidr
  region        = var.resource_group_location
  network       = google_compute_network.vpc.name
  project       = var.resource_group_name
}

resource "google_compute_subnetwork" "worker" {
  name          = "${var.resource_group_name}-worker-subnet"
  ip_cidr_range = var.worker_subnet_cidr
  region        = var.resource_group_location
  network       = google_compute_network.vpc.name
  project       = var.resource_group_name
}

resource "google_compute_subnetwork" "stateful" {
  name          = "${var.resource_group_name}-stateful-subnet"
  ip_cidr_range = var.stateful_subnet_cidr
  region        = var.resource_group_location
  network       = google_compute_network.vpc.name
  project       = var.resource_group_name
}

resource "google_compute_firewall" "admin_firewall" {
  name    = "${var.resource_group_name}-admin-fw"
  network = google_compute_network.vpc.name
  project = var.resource_group_name

  allow {
    protocol = "tcp"
    ports    = ["22"]  # Allow SSH
  }

  source_ranges = ["0.0.0.0/0"]  # Allow from anywhere
  target_tags   = ["k8s-admin"]  # Tag for admin nodes
}

resource "google_compute_firewall" "internal_firewall" {
  name    = "${var.resource_group_name}-internal-fw"
  network = google_compute_network.vpc.name
  project = var.resource_group_name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]  # Allow all internal traffic
  }

  source_ranges = ["10.0.0.0/8"]  # Replace with your internal range
  target_tags   = ["k8s-master", "k8s-worker", "k8s-lb", "k8s-stateful"]  # Tags for relevant nodes
}

resource "google_compute_firewall" "lb_firewall" {
  name    = "${var.resource_group_name}-lb-fw"
  network = google_compute_network.vpc.name
  project = var.resource_group_name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]  # Allow HTTP and HTTPS
  }

  source_ranges = ["0.0.0.0/0"]  # Allow from anywhere
  target_tags   = ["k8s-lb"]  # Tag for load balancer nodes
}

