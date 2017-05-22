developer-setup: setup-source create-hooks

setup-source:
	ifndef glide
    $(error "glide is not install please install glide")
	endif
	brew install glide
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
	cp minikube/report/k8guard-report-secrets.yaml.EXAMPLE  minikube/action/k8guard-report-secrets.yaml

create-hooks:
	cd ../k8guardlibs && ln -s ../../hooks/pre-commit .git/hooks/pre-commit
	cd ../k8guard-discover && ln -s ../../hooks/pre-commit .git/hooks/pre-commit
	cd ../k8guard-action && ln -s ../../hooks/pre-commit .git/hooks/pre-commit
	cd ../k8guard-report && ln -s ../../hooks/pre-commit .git/hooks/pre-commit

build-discover:
	cd ../k8guard-discover && make clean
	cd ../k8guard-discover && make build

build-action:
	cd ../k8guard-action && make clean
	cd ../k8guard-action && make build

build-report:
	cd ../k8guard-report && make clean
	cd ../k8guard-report && make build

build-all: build-discover build-action build-report

clean: clean-action clean-discover clean-report clean-core

clean-core:
	docker-compose -f docker-compose-core.yaml down

up-core: clean-core
	docker-compose -f docker-compose-core.yaml up -d

clean-action:
	docker-compose -f docker-compose-action.yaml down

up-action: clean-action
	docker-compose -f docker-compose-action.yaml build
	docker-compose -f docker-compose-action.yaml up

up-action-d: clean-action
	docker-compose -f docker-compose-action.yaml build
	docker-compose -f docker-compose-action.yaml up -d

clean-discover:
	docker-compose -f docker-compose-discover.yaml down

up-discover: clean-discover
	docker-compose -f docker-compose-discover.yaml build
	docker-compose -f docker-compose-discover.yaml up

up-discover-d: clean-discover
		docker-compose -f docker-compose-discover.yaml build
		docker-compose -f docker-compose-discover.yaml up -d

clean-report:
	docker-compose -f docker-compose-report.yaml down

up-report: clean-report
	docker-compose -f docker-compose-report.yaml build
	docker-compose -f docker-compose-report.yaml up

up-report-d: clean-report
	docker-compose -f docker-compose-report.yaml build
	docker-compose -f docker-compose-report.yaml up -d

clean-minikube:
	kubectl delete -f minikube/core || true
	kubectl delete -f minikube/report || true
	kubectl delete -f minikube/discover || true
	kubectl delete -f minikube/action || true

# super clean
sclean-minikube:
	minikube delete

build-local-dockers:
	cd ../k8guard-discover && make build-docker
	cd ../k8guard-action && make build-docker
	cd ../k8guard-report && make build-docker

deploy-minikube: build-local-dockers
	kubectl config use-context minikube
	kubectl apply -f minikube/core
	sleep 100
	kubectl apply -f minikube/action
	kubectl apply -f minikube/report
	kubectl apply -f minikube/discover

up: up-core up-action-d up-discover-d up-report-d

# super up
sup: build-all up

.PHONY: build
