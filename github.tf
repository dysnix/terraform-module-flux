provider "github" {
  owner = var.repo_owner
  token = var.github_token
}

# To make sure the repository exists and the correct permissions are set.
data "github_repository" "main" {
  full_name = "${var.repo_owner}/${var.repo_name}"
}

resource "github_repository_file" "install" {
  repository          = var.repo_name
  file                = data.flux_install.main.path
  content             = data.flux_install.main.content
  branch              = var.branch
  overwrite_on_create = true
}

resource "github_repository_file" "sync" {
  repository          = var.repo_name
  file                = data.flux_sync.main.path
  content             = data.flux_sync.main.content
  branch              = var.branch
  overwrite_on_create = true
}

resource "github_repository_file" "kustomize" {
  repository          = var.repo_name
  file                = data.flux_sync.main.kustomize_path
  content             = data.flux_sync.main.kustomize_content
  branch              = var.branch
  overwrite_on_create = true
}

resource "github_repository_file" "patches" {
  for_each   = data.flux_sync.main.patch_file_paths

  repository = var.repo_name
  file       = each.value
  content    = local.patches[each.key]
  branch     = var.branch
  overwrite_on_create = true
}
