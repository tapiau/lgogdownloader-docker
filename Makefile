REPO=https://github.com/Sude-/lgogdownloader.git

ifndef TAG
	TAG=$(shell (git ls-remote --tags ${REPO} \
		| awk '{print $$2}' \
		| grep -E 'refs/tags/v[0-9]+\.[0-9]+(\.[0-9]+)?(-[0-9A-Za-z\.-]+)?(\+[0-9A-Za-z\.-]+)?$$' \
		| sort -V \
		| tail -n1 \
		| sed 's/refs\/tags\///' \
	))
endif

DOCKER_IMAGE=tapiau/lgogdownloader:${TAG}

all:
	@echo "Building ${DOCKER_IMAGE}"

	@docker build -t ${DOCKER_IMAGE} --build-arg TAG=${TAG} .

	@docker push ${DOCKER_IMAGE}


#  grep -E 'refs/tags/v[0-9]+\.[0-9]+(\.[0-9]+)?(-[0-9A-Za-z\.-]+)?(\+[0-9A-Za-z\.-]+)?\\$'
# | sort -V | tail -n1 | sed 's/refs\/tags\///'
