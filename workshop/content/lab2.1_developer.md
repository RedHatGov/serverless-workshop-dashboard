# The Developer Stakeholder
There are many types of users from different types of roles that can all benefit from Serverless. In this section, we will be exploring how Serverless can immediately improve a developer's workflow and productivity.

The first major win is that it frees the developer to simply focus on their application code.  No need to worry about complicated frameworks or application servers that dictate to the developer how they should solve the business problem.

The second major win is that deploying to a development kubernetes environment becomes as easy as a simple one line command. No more messy YAML and a more intuitive workflow that fits the way a developer prefers to work.

1.  Create a dockerhub.com account

2.  Check out the code we will be using.  It is a very simple `Python Flask Hello World` application.
```
git clone https://github.com/jkeam/hello-python.git
cd hello-python
```

3.  Build the project
```
docker build -t YOUR_DOCKERHUB_USERNAME/hello-python .
docker push YOUR_DOCKERHUB_USERNAME/hello-python
```

3.  Create project/namespace
```
oc new-project hello
```

4.  Deploy the service
```
kn service create hello-python --namespace hello --image YOUR_DOCKERHUB_USERNAME/hello-python:latest --env TARGET=Python
```

5.  Open the url that is returned from above and see your app
```
Hello Python!
```


Now let's say a new requirement has come in that we need to say `Goodbye` instead of `Hello`.

1.  Open `app.py` and on line 10 change `Hello` to `Goodbye`

2.  Rebuild
```
docker build -t YOUR_DOCKERHUB_USERNAME/hello-python .
docker push YOUR_DOCKERHUB_USERNAME/hello-python
```

3.  Deploy the updated service
```
kn service update hello-python --namespace hello --image YOUR_DOCKERHUB_USERNAME/hello-python:latest --env TARGET=Python
# or you can alternatively force create
kn service create hello-python --namespace hello --image YOUR_DOCKERHUB_USERNAME/hello-python:latest --env TARGET=Python -f
```

4.  Open the url and see the new text
```
Goodbye Python!
```

5.  Delete service
```
kn service delete hello-python
```
