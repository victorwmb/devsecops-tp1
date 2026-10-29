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

function "semver_tags" {
  params = [version]
  result = length(regexall("^[0-9]+\\.[0-9]+\\.[0-9]+$", version)) > 0 ? compact([
    version,
    join(".", slice(split(".", version), 0, 2)),
    split(".", version)[0] == "0" ? "" : split(".", version)[0],
    "latest",
  ]) : [version]
}

group "default" {
  targets = ["api"]
}

target "api" {
  context    = "."
  dockerfile = "Dockerfile"
  platforms  = ["linux/amd64", "linux/arm64"]
  tags       = [for tag in semver_tags(trimprefix(VERSION, "v")) : lower("${REGISTRY}/${IMAGE_NAME}:${tag}")]
  labels = {
    "org.opencontainers.image.source"  = "https://github.com/${IMAGE_NAME}"
    "org.opencontainers.image.version" = trimprefix(VERSION, "v")
  }
  secret     = ["id=pip_token,src=secrets/pip_token.txt"]
  cache-from = GITHUB_ACTIONS == "true" ? ["type=gha,scope=devsecops-tp1"] : []
  cache-to   = GITHUB_ACTIONS == "true" ? ["type=gha,scope=devsecops-tp1,mode=max"] : []
}
