
## K8Guard

- [About K8Guard](#about)	 
  	- [Name](#name)
	- [Features](#features)
	- [Violations Examples](#violations-examples)
	- [Design](#microservices)	  
	- [Requirements](#requirements)	 
- How tos:
	- [Developer setup](#first-time-developer-setup)
	- [Build the project](#build-before-deploy)
	- Deploy
		- [Deploy in docker-compose](#run-in-docker-compose)
		- [Deploy in minikube](#run-in-minikube)
- Legal
	- [Authors](https://github.com/k8guard/k8guard-start-from-here/blob/master/AUTHORS.md)
	- [Become a contributor](https://github.com/k8guard/k8guard-start-from-here/blob/master/CONTRIBUTING.md)
	- 	[Apache License 2.0](https://github.com/k8guard/k8guard-start-from-here/blob/master/LICENSE)

----

# About

#### Name

* K8Guard is auditing system for kuberentes, It is pronounced like Kate Guard. like a guardian angel for your kubernetes clusters.  it is open source and developed by Target Corp.


#### Features

- Discovers violations in a kubernetes cluster.
- Notifies and warns the namespace owners before doing hard actions. <small>(via email or chat) </small>
- Ceans up the violating entities.
- Generates report and metrics of violations and actions.
- Provides an API for integration.
- Highly configurable for different needs.


#### Violations Examples
1. Invalid Image Size <small>(5 GB image)</small>
1. Invalid Image Repo <small>(Download image from a shady repo in internet?)</small>
1. Extra Capabilities <small>(change UID and PID?)</small>
1. Privileged Mode <small>(admin rights on the container?)</small>
1. Host Volumes Mounted <small>(mount the kubernetes file system on your container?)</small>
1. Single Replica Deployment <small>(Didn't read 12-factor?)</small>
1. Invalid Ingress <small>(Have * in your ingress? Or a bad word?)</small>


#### Microservices

- **Discover:** Finds violations
- **Action:** Notifies violators and does action on them.
- **Report:** Generates human readable/searchable reports of the violations and actions.


#### Requirements

1. System level token for a Kubernetes cluster.

###### Optional:

1. A Kafka topic. <small>*(only if you need the action service)*</small>
1. A Cassandra keyspace. <small>*(only if you want to use action and report service)*</small>
1. Prometheus Server <small>*(only if you need metrics and grafana dashboards)*</small>



----



# First Time Developer Setup

* Install Go and Setup your setup your `$GOPATH`.

* First clone this repo this way:

	```
	mkdir -p $GOPATH/src/github.com/k8guard/
	cd $GOPATH/src/github.com/k8guard/
	git clone https://github.com/k8guard/k8guard-start-from-here.git
    cd $GOPATH/src/github.com/k8guard/k8guard-start-from-here
	```
* k8guard-start-from-here folder is your where you wanna be, when run this project.


* Run developer-setup:

	```
	make developer-setup
	```

	* Hint 1: The above steps will clone other repos (k8guardlibs, k8guard-discover, k8guard-action, k8guard-report), and install golang tools (glide, goimport) for you, and also will setup the pre-commits hooks. note: it uses brew to install glide for only for mac users currently.


	* Hint 2: `Makefile` is your friend and it is better than this documentation. take a look at the Makefile in the root of this folder, to undrestand all the commands you need.


# Build Before Deploy

- To Build all the micro-services:

	```
	make build-all
	```
	- Hint: you can build each micro-service individually if you don't wanna build all of them:
		- ```make build-discover```
		- ``` make build-action```
		- ``` make build-report```




#  Deploy

You can choose to either deploy in minikube or run in in docker-compose. all batteries are included (kafka, cassandra, memcached)

##  Run in docker-compose

1. Config :
	edit `.env` and `env-creds` files. (default values should work fine.)

1. Bring the core (cassandra, kafka, memcached):

	```
	make up-core
	```
1.  Bring up action, in a new terminal run:

	```
	make up-action
	```

1.  Bring up discover, in a new terminal run:

	```
	make up-discover
	```

1.  To bring up action, in a new terminal run:

	```
	make up-action
	```

1. Open the Discover api url in the browser:
    ```
    http://localhost:3000
    ```

1. Open the Report service url in the browser:
    ```
    http://localhost:3001
    ```

### Clean up docker-compose

- To clean the docker-compose

	```
	make clean
	```

- Hint alternatively, you can clean individual services:

	`make clean-action`

	`make clean-discover`

	`make clean-report`

	`make clean-core`



## Run in minikube
Make sure you have installed minkube and edit the config maps and secrets inside the minikube folder for each service, and follow these steps:

1. ```minikube start --kubernetes-version v1.5.1```
1. ```eval $(minikube docker-env)```
1. ```make deploy-minikube```


Give it a couple minutes. and hit the service urls:

- Get discover service url:

    ``` minikube service k8guard-discover-service ```

- Get report service url:

    ``` minikube service k8guard-report-service ```



### Clean up minikube
To delete the deployment in minikube:

```
make clean-minikube
```
