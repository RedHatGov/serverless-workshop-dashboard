# Developers Run
There are many types of users from different types of roles that can all benefit from Serverless. In this section, we will be exploring how Serverless can immediately improve a developer's workflow and productivity.

The first major win is that it frees the developer to simply focus on their application code.  No need to worry about complicated frameworks or application servers that dictate to the developer how they should solve the business problem.

The second major win is that deploying to a development kubernetes environment becomes as easy as a simple one line command. No more messy YAML and a more intuitive workflow that fits the way a developer prefers to work.

## Deploy Service

### Use your project

You will use the OpenShift `oc` CLI  to execute commands for the majority of this lab.  You should already be logged in to your cluster in your web terminal.

Switch to the **Terminal** tab, and try running:

```execute
oc whoami
```
*You can click the play button in the top right corner of the code block to automatically execute the command for you.*

You should see your username: %username%.

The instructor will have preconfigured your project for you.  List your project.

```execute
oc projects
```

You should see your user project '%username%'. Switch to your user project.  For example:

```execute
oc project %username%
```

### Build the project

Build the project and wait until build succeeds.

```execute
oc new-build python:3.6~https://github.com/RedHatGov/serverless-workshop-code --name hello-python --context-dir=hello-python --strategy=docker
```

### Get the image URI

The result of the build produced an image for us.  Let's get the location of that image.

```execute
HELLO_IMAGE_URI=$(oc get is hello-python --template='{{.status.dockerImageRepository}}')
```

### Deploy the service

Deploying the image is as simple as giving it a name, `hello-python`, an image location, and whatever environment variables our application needs.

```execute
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

### Test it

In one terminal, watch the pods:

```execute
oc get pods -w
```

Watch the pods and after about 2 minutes, the `hello-python-foo-deployment-bar` pod will become `2/2 Running` like the example below.  This means it's ready.

```
NAME                                               READY   STATUS      RESTARTS   AGE
hello-python-1-build                               0/1     Completed   0          7h36m
hello-python-dydsc-1-deployment-6b6ffd68cb-njqx4   2/2     Running     0          11s
```

In another terminal, curl the endpoint:

```execute-2
HELLO_URL=$(oc get route.serving.knative.dev hello-python --template='{{.status.url}}')
curl $HELLO_URL
```

You should see:

```
Hello Python!
```

Now let's wait to watch it spin down.  Keep your eyes on the top terminal where you are running the `oc get pods -w` until you see "Terminating".  This will take about 90s by default, and is fully configurable.

```
NAME                                               READY   STATUS      RESTARTS   AGE
hello-python-1-build                               0/1     Completed   0          7h36m
hello-python-dydsc-1-deployment-6b6ffd68cb-njqx4   2/2     Terminating 0          67s
```

This is one of the coolest aspects of Serverless, truly elastic in both directions, scaling both up and down based on usage.  Before we move onto the next section, let's stop watching the pods by clicking the top terminal and pressing `ctrl-c`.

## Update Service

Now say a new requirement has come in that we need to say `Hello Pythonistas` instead of `Hello Python`.

### Deploy the updated service
```execute
kn service update hello-python --image $HELLO_IMAGE_URI --env TARGET=Pythonistas
# can alternatively force create instead of update
# kn service create hello-python --image $HELLO_IMAGE_URI --env TARGET=Pythonistas --force
```

### Test it

Ensure you are still watching the pods, if not, in one terminal run:

```execute
oc get pods -w
```

The `hello-python` should not be running.

In another terminal we'll curl the endpoint again.

```execute-2
curl $HELLO_URL
```

You should now see the `hello-python` service appear and change states from `Pending` to `ContainerCreating` to `Running`.

The result of the `curl` command should be:

```
Hello Pythonistas!
```

If you wait another ~90s, then you will see the `hello-python` service again be destroyed.

### Delete service

```execute
kn service delete hello-python
```

## Summary
In this lab you saw how easy it was as a developer to quickly build and deploy code into the OpenShift cluster.  It was a single command to build and another to deploy.  Our service sprang to life when we used it and spun back down when it was not.  This simple workflow makes it easy for developers to get started and the low resource utilization when services are idle means potentially being able to support more services and developers on the platform.
