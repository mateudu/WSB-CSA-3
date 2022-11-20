terraform {
  required_version = "~>1.3.2"
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=0.3.0"
    }
  }
}

provider "azuredevops" {
  org_service_url       = "https://dev.azure.com/XXX/"
  personal_access_token = "XXX"
}

variable "projectName" {
  default = "Lab14"
}

## Project
resource "azuredevops_project" "lab" {
  name        = var.projectName
  description = "This is sample desc!"
}

resource "azuredevops_project_features" "example-features" {
  project_id = azuredevops_project.lab.id
  features = {
    "boards"       = "disabled"
    "repositories" = "enabled"
    "pipelines"    = "enabled"
    "testplans"    = "disabled"
    "artifacts"    = "enabled"
  }
}

## Teams
resource "azuredevops_team" "admin" {
  project_id = azuredevops_project.lab.id
  name       = "Lab14 Administrators"
}

resource "azuredevops_team" "dev" {
  project_id = azuredevops_project.lab.id
  name       = "Lab14 Developers"
}

## Getting Built-in Groups
data "azuredevops_group" "readers" {
  project_id = azuredevops_project.lab.id
  name       = "Readers"
}

data "azuredevops_group" "projectAdmins" {
  project_id = azuredevops_project.lab.id
  name       = "Project Administrators"
}

## Permission Assignments
resource "azuredevops_group_membership" "dev-team-readers-membership" {
  group = data.azuredevops_group.readers.descriptor
  members = [
    azuredevops_team.dev.descriptor
  ]
}

resource "azuredevops_group_membership" "admin-team-projectAdmins-membership" {
  group = data.azuredevops_group.projectAdmins.descriptor
  members = [
    azuredevops_team.admin.descriptor
  ]
}

## Repository setup
resource "azuredevops_git_repository" "main_repo" {
  project_id = azuredevops_project.lab.id
  name       = "main-repo"
  initialization {
    init_type = "Clean"
  }
}
