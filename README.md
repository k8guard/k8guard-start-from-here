# Requirements

* Kubernetes Token that has equivalent access as the system token.



# Getting Started

## 1. Developer Setup
	Make sure to setup your $GOPATH
* Clone this repo (k8guard-start-from-here)
	This path will be where you run all your commands !

	```
	mkdir -p $GOPATH/src/github.com/k8guard/
	cd $GOPATH/src/github.com/k8guard/
	git clone https://github.com/k8guard/k8guard-start-from-here.git
	```
	start-from-here repo is your where you wanna be, when running the project.


* Run developer-setup:

	```
	make developer-setup
	```
The above step will clone other repos for k8guard-discover,k8guard-action,k8guard-action, and install golang tools (glide, goimport) for you, and also will setup the pre-commits hooks.


## 2.Config and Credentials

1. Edit `.env-creds` (for credentials)
1. Edit `.env`   (for config, the default values works too)


## 3. Build the project

1. build all the repos:

	```
	make build-all
	```

Bonous Tip, if you only want to only build one service you can do like this: `make build-discover` or  `make build-action`  



## 4. Run locally

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

## 5. Clean Up After

1. To stop/clean all your services simply run:


	```
	make clean
	```

Bonous Tip, if you only want to clean one service but keep others, you can clean individual service

`make clean-action`
or `make clean-discover`
`make clean-report`
or `make clean-core`


# Shortcut for build and run everything !

```
make sup
```

sup is short for super up ! it will do steps 3 and 4 in one terminal.
