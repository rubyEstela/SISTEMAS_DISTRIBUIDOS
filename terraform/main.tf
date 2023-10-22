terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.23.1"
    }
  }
}



provider "docker" {}

resource "docker_network" "app_network" {
  name = "app_network"
}


resource "docker_image" "imagen_java" {
  name         = "arquitectura"
  build{ 
    path="../arquitectura"
    dockerfile="Dockerfile"
  }
}

resource "docker_container" "aplicacion" {
  image = docker_image.imagen_java.image_id
  name  = "backend"

  ports {
    internal = 8091
    external = 8091
  }

  networks_advanced {
    name = docker_network.app_network.name
  }
}


resource "docker_image" "imagen_postgres" {
  name         = "bd"
  build{ 
    path="../postgres_docker"
    dockerfile="Dockerfile"
  }
}

resource "docker_container" "postgres" {
  image = docker_image.imagen_postgres.image_id
  name  = "base_datos"

  ports {
    internal = 9876
    external = 9876
  }

env = ["POSTGRES_PASSWORD=1111"]

networks_advanced {
    name = docker_network.app_network.name
  }

}

resource "docker_image" "image_firewall" {
  name = "api-firewall:latest"
}

resource "docker_container" "firewall" {
  name  = "firewall"
  image = docker_image.image_firewall.image_id
  
  restart = "on-failure"

  env = [
    "APIFW_URL=http://0.0.0.0:8080",
    "APIFW_API_SPECS=/opt/resources/httpbin.json",
    "APIFW_SERVER_URL=http://backend:80",
    "APIFW_SERVER_MAX_CONNS_PER_HOST=512",
    "APIFW_SERVER_READ_TIMEOUT=5s",
    "APIFW_SERVER_WRITE_TIMEOUT=5s",
    "APIFW_SERVER_DIAL_TIMEOUT=200ms",
    "APIFW_REQUEST_VALIDATION=BLOCK",
    "APIFW_RESPONSE_VALIDATION=BLOCK",
    "APIFW_DENYLIST_TOKENS_FILE=/opt/resources/tokens.denylist.db",
    "APIFW_DENYLIST_TOKENS_COOKIE_NAME=test",
    "APIFW_DENYLIST_TOKENS_HEADER_NAME=",
    "APIFW_DENYLIST_TOKENS_TRIM_BEARER_PREFIX=true"
  ]

  ports {
    internal = 8080
    external = 8080
  }

  volumes {
    container_path  = "/opt/resources"
    host_path      = "/volumes/api-firewall"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.app_network.name
  }
  
}
