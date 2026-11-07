policy "policy" {
  source            = "./policy.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "storage-residency" {
  source            = "./storage-residency.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "replication-residency" {
  source            = "./replication-residency.sentinel"
  enforcement_level = "hard-mandatory"
}