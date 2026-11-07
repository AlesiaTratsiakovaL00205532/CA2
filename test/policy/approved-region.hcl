mock "tfconfig/v2" {
  module {
    source = "../../mocks/mock-tfconfig-v2.sentinel"
  }
}

mock "tfplan/v2" {
  data = {
    variables = {
      region = {
        value = "us-east-1"
      }
    }
  }
}

test {
  rules = {
    main = true
  }
}
