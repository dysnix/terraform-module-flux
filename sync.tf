locals {
  patches = {
    sops = <<EOT
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kustomize-controller
  namespace: ${data.flux_sync.main.namespace}
  annotations:
    iam.gke.io/gcp-service-account: ${var.gserviceaccount}
EOT
    sops-sync = <<EOT
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: flux-system
  namespace: ${data.flux_sync.main.namespace}
spec:
  decryption:
    provider: sops
EOT
    gar-sa = <<EOT
apiVersion: v1
kind: ServiceAccount
metadata:
  name: image-reflector-controller
  namespace: ${data.flux_sync.main.namespace}
  annotations:
    iam.gke.io/gcp-service-account: ${var.image_reflector_gserviceaccount}
EOT
    image-reflector-args = <<EOT
apiVersion: apps/v1
kind: Deployment
metadata:
  name: image-reflector-controller
  namespace: ${data.flux_sync.main.namespace}
spec:
  template:
    spec:
      containers:
        - name: manager
          args:
            - '--events-addr=http://notification-controller.${data.flux_sync.main.namespace}.svc.cluster.local./'
            - '--watch-all-namespaces=true'
            - '--log-level=info'
            - '--log-encoding=json'
            - '--enable-leader-election'
            - '--gcp-autologin-for-gcr'
EOT
  }
}

data "flux_sync" "main" {
  target_path = var.target_path
  url         = "ssh://git@github.com/${var.repo_owner}/${var.repo_name}.git"
  branch      = var.branch
  patch_names = ["sops","sops-sync","gar-sa","image-reflector-args"]
}


data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}

locals {
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "sync" {
  depends_on = [kubectl_manifest.install, kubernetes_namespace.flux_system]
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body  = each.value
}

locals {
  known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
}

resource "kubernetes_secret" "main" {
  depends_on = [kubectl_manifest.install]

  metadata {
    name      = data.flux_sync.main.secret
    namespace = data.flux_sync.main.namespace
  }

  data = {
    known_hosts    = local.known_hosts
    identity       = var.ssh_private_key_pem
    "identity.pub" = var.ssh_public_key
  }
}
