variable "REGISTRY" {
  default = "ghcr.io"
}

variable "IMAGE_NAME" {
  default = "victorwmb/devsecops-tp1"
}

variable "VERSION" {
  default = "dev"
}

variable "GITHUB_ACTIONS" {
  default = "false"
}

group "default" {
  targets = ["api-local"]
}

target "docker-metadata-action" {
  tags = ["${REGISTRY}/${IMAGE_NAME}:${VERSION}"]
}

target "_common" {
  context    = "."
  dockerfile = "Dockerfile"
  secret     = ["id=pip_token,src=secrets/pip_token.txt"]
  cache-from = GITHUB_ACTIONS == "true" ? ["type=gha,scope=devsecops-tp1"] : []
}

target "api" {
  inherits  = ["_common", "docker-metadata-action"]
  platforms = ["linux/amd64", "linux/arm64"]
  cache-to  = GITHUB_ACTIONS == "true" ? ["type=gha,scope=devsecops-tp1,mode=max"] : []
}

target "api-local" {
  inherits  = ["_common"]
  platforms = ["linux/amd64"]
  tags      = ["devsecops-tp1-api:local"]
  output    = ["type=docker"]
}

target "api-arm64" {
  inherits  = ["_common"]
  platforms = ["linux/arm64"]
  tags      = ["devsecops-tp1-api:arm64"]
  output    = ["type=docker"]
}

group "ci" {
  targets = ["api", "api-local", "api-arm64"]
}
