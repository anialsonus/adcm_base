ADCMBASE_IMAGE ?= hub.arenadata.io/adcm/base


# Default target
.PHONY: help

help: ## Shows that help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


##################################################
#                 B U I L D
##################################################

build: ## Build base image for ADCM's container. That is alpine with all packages.
	docker build --pull=true --no-cache=true  -t $(ADCMBASE_IMAGE):$$(date '+%Y%m%d%H%M%S') -t $(ADCMBASE_IMAGE):latest .
