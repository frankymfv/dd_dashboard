
terraform {   
required_providers {
    datadog = {
      source = "DataDog/datadog"
      version = "~> 3.0"
    }
  } 
 cloud { 
    
    organization = "FrankyTesting" 
    workspaces { 
      name = "dd_test_222" 
    } 
  } 
} 
