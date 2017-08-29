.DEFAULT_GOAL := help
.PHONY: help

developer-setup: setup-source create-pre-commit-hooks ## Run this only once. Downloads github repos and creates pre-commit hooks.

setup-source:
	echo "Installing glide"
	curl https://glide.sh/get | sh
	echo "Installing goimports"
	go get golang.org/x/tools/cmd/goimports
	echo "Cloning Repos"
	cd .. && (git clone https://github.com/k8guard/k8guardlibs.git || true) && cd k8guardlibs && make deps
	cd .. && (git clone https://github.com/k8guard/k8guard-discover.git || true) && cd k8guard-discover && make deps
	cd .. && (git clone https://github.com/k8guard/k8guard-action.git || true) && cd k8guard-action && make deps
	cd .. && (git clone https://github.com/k8guard/k8guard-report.git || true) && cd k8guard-report && make deps
	echo "Creating config files"
	cp .env-creds-template .env-creds
	cp .env-template .env
	cp minikube/action/k8guard-action-secrets.yaml.EXAMPLE  minikube/action/k8guard-action-secrets.yaml
	cp minikube/report/k8guard-report-secrets.yaml.EXAMPLE  minikube/report/k8guard-report-secrets.yaml

update-source: ## git pulls origin/master on all the k8guard repos and updates dependencies.
	@read -p "This will pull origin/master on all k8guard repos, please enter to continue " _
	cd ../k8guardlibs && git checkout master && git pull origin master && make deps
	cd ../k8guard-discover && git checkout master && git pull origin master && make deps
	cd ../k8guard-action && git checkout master && git pull origin master && make deps
	cd ../k8guard-report && git checkout master && git pull origin master && make deps

create-pre-commit-hooks: ## creates pre-commit hooks for formatting for all the repos.
	cd ../k8guard-discover && make create-pre-commit-hooks
	cd ../k8guard-action && make create-pre-commit-hooks
	cd ../k8guardlibs && make create-pre-commit-hooks
	cd ../k8guard-report && make create-pre-commit-hooks

build-discover: ## builds discover microservice from source.
	cd ../k8guard-discover && make clean
	cd ../k8guard-discover && make build

build-action: ## builds action microservice from source.
	cd ../k8guard-action && make clean
	cd ../k8guard-action && make build

build-report: ## builds report microservice from source.
	cd ../k8guard-report && make clean
	cd ../k8guard-report && make build

build-all: build-discover build-action build-report ## builds all the microservices from source.

build-action-local-docker:
	cd ../k8guard-action && make build-docker

build-discover-local-docker:
	cd ../k8guard-discover && make build-docker

build-report-local-docker:
	cd ../k8guard-report && make build-docker

build-local-dockers: build-action-local-docker build-discover-local-docker build-report-local-docker ## Builds all the docker images locally from source code


#############################################################################
#######		original docker compose using memcache/kafka/zookeeper    #######
#############################################################################

clean-compose: clean-action-compose clean-discover-compose clean-report-compose clean-core-compose

clean-core-compose:
	docker-compose -f docker-compose-core.yaml down

up-core-compose: clean-core-compose
	docker-compose -f docker-compose-core.yaml up -d

clean-action-compose:
	docker-compose -f docker-compose-action.yaml down

up-action-compose: clean-action-compose
	docker-compose -f docker-compose-action.yaml build
	docker-compose -f docker-compose-action.yaml up

up-action-compose-d: clean-action-compose
	docker-compose -f docker-compose-action.yaml build
	docker-compose -f docker-compose-action.yaml up -d

clean-discover-compose:
	docker-compose -f docker-compose-discover.yaml down

up-discover-compose: clean-discover-compose
	docker-compose -f docker-compose-discover.yaml build
	docker-compose -f docker-compose-discover.yaml up

up-discover-compose-d: clean-discover-compose
		docker-compose -f docker-compose-discover.yaml build
		docker-compose -f docker-compose-discover.yaml up -d

clean-report-compose:
	docker-compose -f docker-compose-report.yaml down

up-report-compose: clean-report-compose
	docker-compose -f docker-compose-report.yaml build
	docker-compose -f docker-compose-report.yaml up

up-report-compose-d: clean-report-compose
	docker-compose -f docker-compose-report.yaml build
	docker-compose -f docker-compose-report.yaml up -d

up-compose: up-core-compose up-action-compose-d up-discover-compose-d up-report-compose-d ## deploys all the microservices to dokcer-compose


####################################################################
#######		lightweight docker compose using redis           #######
####################################################################

clean-compose-lightweight: clean-action-compose-lightweight clean-discover-compose-lightweight clean-report-compose-lightweight clean-core-compose-lightweight

clean-core-compose-lightweight:
	docker-compose -f docker-compose-core-lightweight.yaml down

up-core-compose-lightweight: clean-core-compose-lightweight
	docker-compose -f docker-compose-core-lightweight.yaml up -d

clean-action-compose-lightweight:
	docker-compose -f docker-compose-action-lightweight.yaml down

up-action-compose-lightweight: clean-action-compose-lightweight
	docker-compose -f docker-compose-action-lightweight.yaml build
	docker-compose -f docker-compose-action-lightweight.yaml up

up-action-compose-lightweight-d: clean-action-compose-lightweight
	docker-compose -f docker-compose-action-lightweight.yaml build
	docker-compose -f docker-compose-action-lightweight.yaml up -d

clean-discover-compose-lightweight:
	docker-compose -f docker-compose-discover-lightweight.yaml down

up-discover-compose-lightweight: clean-discover-compose-lightweight
	docker-compose -f docker-compose-discover-lightweight.yaml build
	docker-compose -f docker-compose-discover-lightweight.yaml up

up-discover-compose-lightweight-d: clean-discover-compose-lightweight
		docker-compose -f docker-compose-discover-lightweight.yaml build
		docker-compose -f docker-compose-discover-lightweight.yaml up -d

clean-report-compose-lightweight:
	docker-compose -f docker-compose-report-lightweight.yaml down

up-report-compose-lightweight: clean-report-compose-lightweight
	docker-compose -f docker-compose-report-lightweight.yaml build
	docker-compose -f docker-compose-report-lightweight.yaml up

up-report-compose-lightweight-d: clean-report-compose-lightweight
	docker-compose -f docker-compose-report-lightweight.yaml build
	docker-compose -f docker-compose-report-lightweight.yaml up -d

up-compose-lightweight: up-core-compose-lightweight up-action-compose-lightweight-d up-discover-compose-lightweight-d up-report-compose-lightweight-d ## deploys all the microservices to dokcer-compose


##################################################################################
#######		original minikube deployment using memcache/kafka/zookepper    #######
##################################################################################

clean-minikube: ## delete all pods and jobs on the minikube
	kubectl delete -f minikube/core || true
	kubectl delete -f minikube/report || true
	kubectl delete -f minikube/discover-api || true
	kubectl delete -f minikube/discover-cronjob || true
	kubectl delete -f minikube/action || true

sclean-minikube: ## super clean minikube, delete minikube completely.
	minikube delete

deploy-minikube: build-local-dockers ## Builds all docker images from source and deploys to minikube.
	kubectl config use-context minikube
	kubectl apply -f minikube/core
	@read -p "Pausing ... Please press enter to continue " _
	kubectl apply -f minikube/action
	kubectl apply -f minikube/report
	kubectl apply -f minikube/discover-api
	kubectl apply -f minikube/discover-cronjob

build-deploy-minikube: build-all deploy-minikube

####################################################################
#######		lightweight minikube deployment using redis      #######
####################################################################

clean-minikube-lightweight: ## delete all pods and jobs on the minikube
	kubectl delete -f minikube/core-lightweight || true
	kubectl delete -f minikube/report-lightweight || true
	kubectl delete -f minikube/discover-api-lightweight || true
	kubectl delete -f minikube/discover-cronjob-lightweight || true
	kubectl delete -f minikube/action-lightweight || true

sclean-minikube-lightweight: sclean-minikube-lightweight  ## super clean minikube, delete minikube completely.

deploy-minikube-lightweight: build-local-dockers ## Builds all docker images from source and deploys to minikube.
	kubectl config use-context minikube
	kubectl apply -f minikube/core-lightweight
	@read -p "Pausing ... Please press enter to continue " _
	kubectl apply -f minikube/action-lightweight
	kubectl apply -f minikube/report-lightweight
	kubectl apply -f minikube/discover-api-lightweight
	kubectl apply -f minikube/discover-cronjob-lightweight

build-deploy-minikube-lightweight: build-all deploy-minikube-lightweight




sup-compose: build-all up ## super up (Builds all and then deploys up all the microservices in docker-compose)

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
