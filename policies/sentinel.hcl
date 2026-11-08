policy "approved-regions" {
  source            = "./approved-regions.sentinel"
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

policy "infrastructure-security" {
  source            = "./infrastructure-security.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "supply-chain-security" {
  source            = "./supply-chain-security.sentinel"
  enforcement_level = "hard-mandatory"
}