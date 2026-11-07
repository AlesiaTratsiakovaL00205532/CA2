mock "tfconfig/v2" {
  module {
    source = "../../mocks/mock-storage-tfconfig-v2.sentinel"
  }
}

mock "tfplan/v2" {
  data = {
    variables = {
      region = { value = "us-east-1" }
    }
    resource_changes = {
      "aws_ebs_volume.data" = {
        mode = "managed"
        type = "aws_ebs_volume"
        change = {
          actions = ["create"]
          after   = { availability_zone = "us-west-1a" }
        }
      }
    }
  }
}

test {
  rules = { main = false }
}
