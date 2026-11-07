mock "tfconfig/v2" {
  module {
    source = "../../mocks/mock-storage-tfconfig-v2.sentinel"
  }
}

mock "tfplan/v2" {
  data = {
    variables = {
      region = { value = "us-west-1" }
    }
    resource_changes = {}
  }
}

test {
  rules = { main = false }
}
