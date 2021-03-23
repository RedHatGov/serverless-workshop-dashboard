# Setup

As a preqrequisite to running these labs, you will need access to an OpenShift v4.x cluster as a cluster admin.  We also assume you have the `oc` client installed and have logged into your cluster with it.

OpenShift Serverless install can be completely done with Operator Hub webconsole or the CLI - we are going to give you a little taste of both by adding the operator via webconsole and then the rest via CLI

## Knative Serving
Knative serving has already been installed for you.  Verify it now.

1.  Verify installation
```execute
oc get knativeserving.operator.knative.dev/knative-serving \
  -n knative-serving \
  --template='{{range .status.conditions}}{{printf "%s=%s\n" .type .status}}{{end}}'
```

The output will look like:

```
DependenciesInstalled=True
DeploymentsAvailable=True
InstallSucceeded=True
Ready=True
```

2.  Verify serving pods

```execute
oc get pods -n knative-serving
```

You should see something like the following:
```
NAME                                               READY   STATUS      RESTARTS   AGE
eventing-controller-848bcbd4f9-7zz68               1/1     Running     0          3d13h
eventing-webhook-78dcf96448-6568h                  1/1     Running     0          3d13h
imc-controller-8559ff856b-2sdk6                    1/1     Running     0          3d13h
imc-dispatcher-575c7fcd8d-lrpmt                    1/1     Running     0          3d13h
kafka-ch-controller-85f879d577-llzvp               1/1     Running     0          3d13h
kafka-ch-dispatcher-55d76d7db8-q9xzw               1/1     Running     0          3d13h
kafka-controller-manager-bc994c465-t5lv4           1/1     Running     0          3d13h
kafka-webhook-54646f474f-qstvz                     1/1     Running     0          3d13h
mt-broker-controller-56857cccc5-h49sp              1/1     Running     0          3d13h
mt-broker-filter-784b7db965-5ngkk                  1/1     Running     0          3d13h
mt-broker-ingress-6b9f847866-bhk5w                 1/1     Running     0          3d13h
sugar-controller-594784974b-rpvsm                  1/1     Running     0          3d13h
```


## Knative Eventing
Knative eventing has already been installed for you.  Verify it now.

1.  Verify installation
```execute
oc get knativeeventing.operator.knative.dev/knative-eventing \
  -n knative-eventing \
  --template='{{range .status.conditions}}{{printf "%s=%s\n" .type .status}}{{end}}'
```

The output will look like:
```
InstallSucceeded=True
Ready=True
```

2.  Verify eventing pods

```execute
oc get pods -n knative-eventing
```

You should see something like the following:
```
NAME                                   READY   STATUS    RESTARTS   AGE
broker-controller-58765d9d49-g9zp6     1/1     Running   0          7m21s
eventing-controller-65fdd66b54-jw7bh   1/1     Running   0          7m31s
eventing-webhook-57fd74b5bd-kvhlz      1/1     Running   0          7m31s
imc-controller-5b75d458fc-ptvm2        1/1     Running   0          7m19s
imc-dispatcher-64f6d5fccb-kkc4c        1/1     Running   0          7m18s
```

## Tools

### `kn` CLI

`kn` is a very powerful tool for being able to control knative from the command line. Verify that you have it installed by running:

```execute
kn version
```

### `stern` CLI

`stern` is a great tool to easily be able to view logs for a particular container.  Verify that you have it installed by running:

```execute
stern -v
```
