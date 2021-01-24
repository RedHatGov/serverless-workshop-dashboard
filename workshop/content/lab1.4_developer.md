# The Developer Stakeholder
There are many types of users from different types of roles that can all benefit from Serverless. In this section, we will be exploring how Serverless can immediately improve a developer's workflow and productivity.

The first major win is that it frees the developer to simply focus on their application code.  No need to worry about complicated frameworks or application servers that dictate to the developer how they should solve the business problem.

The second major win is that deploying to a development kubernetes environment becomes as easy as a simple one line command. No more messy YAML and a more intuitive workflow that fits the way a developer prefers to work.

## Deploy Service

1.  Use project/namespace with assigned user number
Make sure you are logged in first with the `oc login` command

```
# replace X with your assigned number
export USER_NUMBER=X
oc project user$USER_NUMBER
```

2.  Build the project

Build the project and wait until build succeeds.

```
oc new-build python:3.6~https://github.com/RedHatGov/serverless-workshop-code --name hello-python --context-dir=hello-python --strategy=docker
```

3.  Deploy the service

```
HELLO_IMAGE_URI=$(oc get is hello-python --template='{{.status.dockerImageRepository}}')
kn service create hello-python --image $HELLO_IMAGE_URI --env TARGET=Python
```

Your output should look similar to:
```
Creating service 'hello-python' in namespace 'hello':

  0.042s The Configuration is still working to reflect the latest desired specification.
  0.075s The Route is still working to reflect the latest desired specification.
  0.140s Configuration "hello-python" is waiting for a Revision to become ready.
 21.017s ...
 21.018s Ingress has not yet been reconciled.
 21.018s unsuccessfully observed a new generation
 21.223s Ready to serve.

Service 'hello-python' created to latest revision 'hello-python-dydsc-1' is available at URL:
http://hello-python-hello.apps.cluster-tysons-4d23.tysons-4d23.example.opentlc.com
```

4.  Test it

In one terminal, watch the pods:

```
oc get pods -w
```

You should see:

```
NAME                                               READY   STATUS      RESTARTS   AGE
hello-python-1-build                               0/1     Completed   0          7h36m
hello-python-dydsc-1-deployment-6b6ffd68cb-njqx4   2/2     Running     0          11s
```

In another terminal, curl the endpoint:

```
HELLO_URL=$(oc get route.serving.knative.dev hello-python --template='{{.status.url}}')
curl $HELLO_URL
```

You should see:

```
Hello Python!
```

After ~90s of idle time, you should see the `hello-python` service transition to `Terminating` before ultimately being removed.

```
NAME                                               READY   STATUS      RESTARTS   AGE
hello-python-1-build                               0/1     Completed   0          7h36m
hello-python-dydsc-1-deployment-6b6ffd68cb-njqx4   2/2     Terminating 0          67s
```


## Update Service

Now say a new requirement has come in that we need to say `Hello Pythonistas` instead of `Hello Python`.

1.  Deploy the updated service
```
kn service update hello-python --image $HELLO_IMAGE_URI --env TARGET=Pythonistas
# can alternatively force create instead of update
# kn service create hello-python --image $HELLO_IMAGE_URI --env TARGET=Pythonistas -f
```

2.  Test it

Ensure you are still watching the pods, if not, in one terminal run:

```
oc get pods -w
```

The `hello-python` should not be running.

In another terminal we'll curl the endpoint again.

```
curl $HELLO_URL
```

You should now see the `hello-python` service appear and change states from `Pending` to `ContainerCreating` to `Running`.

The result of the `curl` command should be:

```
Hello Pythonistas!
```

If you wait another ~90s, then you will see the `hello-python` service again be destroyed.

3.  Delete service

```
kn service delete hello-python
```

## Summary
In this lab you saw how easy it was as a developer to quickly build and deploy code into the OpenShift cluster.  It was a single command to build and another to deploy.  Our service sprang to life when we used it and spun back down when it was not.  This simple workflow makes it easy for developers to get started and the low resource utilization when services are idle means potentially being able to support more services and developers on the platform.
