.PHONY: build
build: clean  ## Build a distribute
	scripts/build.sh build

release: build  ## build and upload to pypi
	scripts/build.sh release

.PHONY: clean
clean:   ## Clean cache
	scripts/build.sh clean

.PHONY: install
install:  ## Install to local storage
	@pip install .

.PHONY: test
test:  ## Unit test
	pytest -p "no:warnings" .

.PHONY: pep8
pep8:  ## pep8
	@black $(CURDIR) --line-length 99

.PHONY: image
image:  ## build docker image
	@scripts/docker-build.sh

.PHONY: azure
azure:   ## deploy develop to rqams.com
	@scripts/deploy.sh azure

.PHONY: server
server:  ## run debug http server
	@scripts/debug.sh run-server

.PHONE: shell
shell:  ## flask shell
	@scripts/debug.sh shell

.PHONE: celery
celery:  ## run celery
	@@scripts/debug.sh worker

# Absolutely awesome: http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := build
