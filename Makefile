CONTAINER_NAME=demo-worker

.PHONY: container

container:
	docker build -f Dockerfile -t datagridsys/${CONTAINER_NAME} .

