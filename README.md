![Released Container Image](https://github.com/RedHatGov/serverless-workshop-dashboard/workflows/Released%20Container%20Image/badge.svg)

![Nightly Container Image](https://github.com/RedHatGov/serverless-workshop-dashboard/workflows/Nightly%20Container%20Image/badge.svg)


# OpenShift Serverless Workshop
This repo contains the lab guides for a workshop on OpenShift Serverless (Knative). These labs have been designed to work within an OpenShift Homeroom deployment. The TL;DR of homeroom is that we build all these labs into a website, stuff that in a container, and deploy that container to the OpenShift cluster that the workshop attendees are using. This lets us show instructions side-by-side with the OpenShift webconsole and CLI terminal.

## Deploying this workshop - if you have RHPDS
We are working on getting this into a click-to-provision environment. It's not there yet, when it is this section will tell you how to order it.

## Deploying this workshop - in your own cluster
Assuming you have a cluster and that you are logged with admin privileges.

1. Set a local `CLUSTER_SUBDOMAIN` environment variable
    > `CLUSTER_SUBDOMAIN=<apps.openshift.com>`

2. Create a project for the homeroom to live
    > `oc new-project homeroom --display-name="Homeroom Workshops"`

3. Grab the template to deploy a `workshop-spawner`. Note that the `CUSTOM_TAB_*` variables take the form `<tabLabel>=<url>`
> ```
> oc process -f https://raw.githubusercontent.com/RedHatGov/workshop-spawner/develop/templates/hosted-workshop-production.json \
>    -p SPAWNER_NAMESPACE=homeroom \
>    -p CLUSTER_SUBDOMAIN=$CLUSTER_SUBDOMAIN \
>    -p WORKSHOP_NAME=serverless-workshop \
>    -p CONSOLE_IMAGE=quay.io/openshift/origin-console:4.5 \
>    -p WORKSHOP_IMAGE=quay.io/redhatgov/serverless-workshop-dashboard:latest \
>    | oc apply -n homeroom -f -
> ```

## Access info for the workshop
Your workshop attendees will need user accounts in the OpenShift cluster.

Now give this URL (or preferably a shortened version) to your workshop attendees:
>`echo https://serverless-workshop-homeroom.$CLUSTER_SUBDOMAIN`

## Cleaning up after the workshop
As long as no one else is running a homeroom workshop in the same cluster, you can clean up with the following:
>`oc delete project homeroom`

---

## Developers
### Building this locally
You need the docker or podman CLI. Then simply run:
> `docker build . -t serverless-workshop-dashboard`

### Running locally (note this requires a lot of memory)
You'll need [Code Ready Containers](https://cloud.redhat.com/openshift/install/crc/installer-provisioned).

Start your cluster and create a project to work in
> `crc start`
> 
> `oc new-project homeroom --display-name="Homeroom Workshops"`

Build the image in your cluster: 
> `oc new-build --strategy docker --binary --docker-image quay.io/redhatgov/workshop-dashboard:latest --name=serverless-workshop-dashboard`
> 
> `oc start-build serverless-workshop-dashboard --from-dir . --follow`

Export a cluster subdomain:
> `CLUSTER_SUBDOMAIN=<apps.openshift.com>`

Deploy the workshop using the imported image:
> ```
> oc process -f https://raw.githubusercontent.com/RedHatGov/workshop-spawner/develop/templates/hosted-workshop-production.json \
>    -p SPAWNER_NAMESPACE=homeroom \
>    -p CLUSTER_SUBDOMAIN=$CLUSTER_SUBDOMAIN \
>    -p WORKSHOP_NAME=serverless-workshop \
>    -p CONSOLE_IMAGE=quay.io/openshift/origin-console:4.5 \
>    -p WORKSHOP_IMAGE=serverless-workshop-dashboard:latest \
>    | oc apply -n homeroom -f -
> ```

Wait until it's ready
> `oc get pods -w`

It will be available here (login your developer/developer account - kubadmin doesn't seem to work):
> `open https://serverless-workshop-homeroom.$CLUSTER_SUBDOMAIN`
