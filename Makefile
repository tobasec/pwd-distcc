# Makefile

# Default values
IMAGE_NAME := distcc-docker
IMAGE_TAG := latest

build:
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) --force-rm=true .

run:
	docker compose up -d --build --force-recreate --remove-orphans
