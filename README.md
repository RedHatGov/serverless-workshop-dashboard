![Released Container Image](https://github.com/RedHatGov/serverless-workshop-dashboard/workflows/Released%20Container%20Image/badge.svg)

![Nightly Container Image](https://github.com/RedHatGov/serverless-workshop-dashboard/workflows/Nightly%20Container%20Image/badge.svg)


# OpenShift Serverless Workshop
This repo contains the lab guides for a workshop on OpenShift Serverless (Knative). These labs have been designed to work within an OpenShift Homeroom deployment. The TL;DR of homeroom is that we build all these labs into a website, stuff that in a container, and deploy that container to the OpenShift cluster that the workshop attendees are using. This lets us show instructions side-by-side with the OpenShift webconsole and CLI terminal.

## How To Provision

### Order from RHPDS

In the catalog, navigate to [All Services] -> [Openshift Workshop] -> [OpenShift 4 ML Serverless]

Make sure to set select Size "Small" or "Large".  Also set the "Users" count with the expected number of participants in your workshop.


## Access info for the workshop
> Make sure you provisioned the workshop using RHPDS or [ran the AgnosticD role](./README-AgnosticD.md) on the cluster.

Give this URL to workshop attendees: 
```
echo https://username-distribution-homeroom.$CLUSTER_SUBDOMAIN
```

They'll need to enter a valid email address and the workshop password specified by the `LAB_USER_ACCESS_TOKEN` environment variable, for which the default is **redhatlabs**.  Once logged in, they'll be given a user account and a link to the workshop.

You can perform administrative actions by visiting `/admin` in the `username-distribution` app. You'll need to enter `admin` as a username and the value of the `LAB_ADMIN_PASS` environment variable, for which the default is **pleasechangethis**, as a password.

For direct access to the workshop, you can navigate to:
>`echo https://serverless-workshop-homeroom.$CLUSTER_SUBDOMAIN`


## Clean Up
Delete the RHPDS cluster once you are done running the workshop

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
