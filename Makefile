BASE_IMAGE ?= hub.arenadata.io/adcm/base
TEST_IMAGE ?= hub.arenadata.io/adcm/test
#
#
# Default target
.PHONY: help

help: ## Shows that help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


##################################################
#                 B U I L D
##################################################

build: ## Build base image for ADCM's container. That is alpine with all packages.
	$(eval BASE_NEW_TAG=$(shell date '+%Y%m%d%H%M%S'))
	docker build --pull=true --no-cache=true  -t $(BASE_IMAGE):$(BASE_NEW_TAG) -t $(BASE_IMAGE):latest ./base/.
	docker build --no-cache=true  --build-arg  "BASE_IMAGE=$(BASE_IMAGE)" --build-arg BASE_TAG=$(BASE_NEW_TAG) -t $(TEST_IMAGE):$(BASE_NEW_TAG) -t $(TEST_IMAGE):latest ./test/.
	@echo "docker push $(BASE_IMAGE):$(BASE_NEW_TAG)"
	@echo "docker push $(BASE_IMAGE):latest		   "
	@echo "docker push $(TEST_IMAGE):$(BASE_NEW_TAG)"
	@echo "docker push $(TEST_IMAGE):latest		   "
