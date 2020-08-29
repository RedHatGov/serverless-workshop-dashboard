# OpenShift Serverless Workshop
This repo contains the lab guides for a workshop on OpenShift Serverless (Knative). These labs have been designed to work within an OpenShift Homeroom deployment. The TL;DR of homeroom is that we build all these labs into a website, stuff that in a container, and deploy that container to the OpenShift cluster that the workshop attendees are using. This lets us show instructions side-by-side with the OpenShift webconsole and CLI terminal.


## Deploying this workshop
Assuming you have a cluster and that you are logged with admin privileges.

1. Set a local `CLUSTER_SUBDOMAIN` environment variable
```
CLUSTER_SUBDOMAIN=<apps.openshift.com>
```
2. Create a project for the homeroom to live
```
oc new-project homeroom --display-name="Homeroom Workshops"
```
3. Grab the template to deploy a `workshop-spawner`. Note that the `CUSTOM_TAB_*` variables take the form `<tabLabel>=<url>`
```
oc process -f https://raw.githubusercontent.com/RedHatGov/workshop-spawner/develop/templates/hosted-workshop-production.json \
    -p SPAWNER_NAMESPACE=homeroom \
    -p CLUSTER_SUBDOMAIN=$CLUSTER_SUBDOMAIN \
    -p WORKSHOP_NAME=serverless-workshop \
    -p CONSOLE_IMAGE=quay.io/openshift/origin-console:4.5 \
    -p WORKSHOP_IMAGE=quay.io/redhatgov/serverless-workshop-labguides:latest
| oc apply -f -
```
4. Give this URL (or preferably a shortened version) to your workshop attendees:
```
echo https://serverless-workshop-homeroom.$CLUSTER_SUBDOMAIN
```

