developer-setup: setup-source create-hooks

setup-source:
	brew install glide
	go get golang.org/x/tools/cmd/goimports
	cd .. && (git clone https://github.com/k8guard/k8guardlibs.git || true) && cd k8guardlibs && make deps
	cd .. && (git clone https://github.com/k8guard/k8guard-discover.git || true) && cd k8guard-discover && make deps
	cd .. && (git clone https://github.com/k8guard/k8guard-action.git || true) && cd k8guard-action && make deps
	cd .. && (git clone https://github.com/k8guard/k8guard-report.git || true) && cd k8guard-report && make deps
	cp .env-creds-template .env-creds
	cp .env-template .env

create-hooks:
	cd ../k8guardlibs && ln -s ../../hooks/pre-commit .git/hooks/pre-commit
	cd ../k8guard-discover && ln -s ../../hooks/pre-commit .git/hooks/pre-commit
	cd ../k8guard-action && ln -s ../../hooks/pre-commit .git/hooks/pre-commit
	cd ../k8guard-report && ln -s ../../hooks/pre-commit .git/hooks/pre-commit

build-discover:
	cd ../k8guard-report && make clean
	cd ../k8guard-discover && make build

build-action:
	cd ../k8guard-report && make clean
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

up: up-core up-action-d up-discover-d up-report-d

sup: build-all up

.PHONY: build
