# webserver

this is the repo for the assigment given,

it comprises of several parts:

## Application( tested)
the application is a golang webserver with following endpoints:
- the route “/pods” will return a list of all running pods on the cluster
- the route “/metrics” will return a prometheus style metrics on how many requests the app has received
- the route “/me” that will return the local container ip
- the route “/health” that will return “OK {ENV}” if the app is working and the environment variable “ENV” is set

forked from enricofoltran/simple-go-server and edited with the neccasry endpoints

## Docker (tested)
The dockerfile is multistage where the build image is using golang:1.18 image to build the artifact

the next stage takes the built artifact and all its dynmaice librairies and copies them to a lightweight busybox image

final image size: 54 MB

## Helm (tested on minikube)
the helm chart was generated with `helm create webserver-helm` and later updated:
 - configmap was added
 - deployement was updated to use the configmap as env variables and remove unnnecasrry parts

## Jenkins (not tested)
A declartive jenkins file was generated to pull the git repo, build the docker image, and push the image to dockerhub

## Terraform (not tested)
Terraform folder was created using https://github.com/scholzj vpc and minikube modules
the terraform also deploys the local helm chart and create nginx-ingress deployment on the minikube



