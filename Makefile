# ------------------- Build configuration

DOCKER_REPO := quay.io/sergealexandre

BUILDX_CACHE=/tmp/docker_cache

BUILD_TYPE=download
#BUILD_TYPE=build

# To authenticate for pushing in github repo (img):
# echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USER --password-stdin

# To authenticate for pushing in github repo (helm):
# echo $GITHUB_TOKEN | helm registry login ghcr.io/$GITHUB_USER -u $GITHUB_USER --password-stdin

# To authenticate for pushing in quay repo (img) (Use encrypted password):
# docker login quay.io

# To authenticate for pushing in quay repo (helm):
#  helm registry login quay.io



# Comment this to just build locally
DOCKER_PUSH := --push

# Source version
METASTORE_VERSION := 3.1.3
HADOOP_VERSION = 3.2.0  # Does not works with 3.2.4
JDBC_VERSION := 42.7.3
IMAGE_TAG := 3.1.3

# You can switch between simple (faster) docker build or multiplatform one.
# For multiplatform build on a fresh system, do 'make docker-set-multiplatform-builder'
#DOCKER_BUILD := docker buildx build --builder multiplatform --cache-to type=local,dest=$(BUILDX_CACHE),mode=max --cache-from type=local,src=$(BUILDX_CACHE) --platform linux/amd64,linux/arm64
DOCKER_BUILD := docker build


.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

# --------------------------------------------------------------------- local

.PHONY: docker
docker: ## Build and push hive-metastore image using postgresql
	$(DOCKER_BUILD) ${DOCKER_PUSH}  -t $(DOCKER_REPO)/hive-metastore:$(IMAGE_TAG) --build-arg ARG_METASTORE_VERSION=${METASTORE_VERSION} \
	--build-arg ARG_HADOOP_VERSION=${HADOOP_VERSION} --build-arg ARG_JDBC_VERSION=${JDBC_VERSION} -f docker/Dockerfile-${BUILD_TYPE} .


.PHONY: chart
chart: ## Build and push helm chart
	cd ./helm && helm package -d ./../tmp hive-metastore
	helm push ./tmp/hive-metastore-0.1.0-chart.tgz oci://${DOCKER_REPO}
