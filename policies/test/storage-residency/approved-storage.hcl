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
      "aws_instance.ubuntu" = {
        mode = "managed"
        type = "aws_instance"
        change = {
          actions = ["create"]
          after   = { availability_zone = "us-east-1a" }
        }
      }
      "aws_s3_bucket.data" = {
        mode = "managed"
        type = "aws_s3_bucket"
        change = {
          actions = ["create"]
          after   = { region = "us-east-1" }
        }
      }
    }
  }
}

test {
  rules = { main = true }
}
