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
      "aws_s3_bucket.data" = {
        mode = "managed"
        type = "aws_s3_bucket"
        change = {
          actions = ["create"]
          after   = { region = "us-west-1" }
        }
      }
    }
  }
}

test {
  rules = { main = false }
}
