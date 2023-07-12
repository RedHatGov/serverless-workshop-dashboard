# Build machine learning API

In this lab, you will build and deploy the NLP Prediction Service using OpenShift Serverless.  The prediction service needs a Natural Language Processing (NLP) model to verify if a message describes a legitimate disaster.  To make things easier, we pre-created this model for you and stored this in [OpenShift Data Foundation][1] (ODF).  

The model was trained on a [Twitter dataset][2] originally used for a Kaggle competition, in which tweets were labeled **1** (the tweet is about a real disater) or **0** (the tweet is not about a real disaster).  If you're curious, the model uses a scikit-learn [Multinomial Naive Bayes classifier][3] to make its predictions.  The training code is [here][4] if you want to take a look.

Don't worry too much about the ML details.  The model isn't perfect (it's not super accurate and the data is skewed in favor of 'tweet' messages), but it's a good starting point.  More importantly, we gave you a model you can use to run the prediction service!

## NLP Model

First, let's make sure a storage bucket was created in ODF:

```execute
oc get objectbucket
```

You should see a bucket called `obc-%username%-serverless-workshop-ml`.

Set the keys required to connect to your bucket:

```execute
export AWS_ACCESS_KEY_ID=$(oc get secret serverless-workshop-ml -o jsonpath="{.data.AWS_ACCESS_KEY_ID}" | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(oc get secret serverless-workshop-ml -o jsonpath="{.data.AWS_SECRET_ACCESS_KEY}" | base64 --decode)
```

Set the endpoint and bucket name:

```execute
export ENDPOINT_URL=$(oc get route s3 -n openshift-storage --template='https://{{.spec.host}}')
export BUCKET_NAME=$(oc get cm serverless-workshop-ml -o jsonpath="{.data.BUCKET_NAME}")
```

List the objects in your bucket:

```execute
aws --endpoint $ENDPOINT_URL s3 ls s3://$BUCKET_NAME
```

You should see the `model.pkl` file in the output.

Awesome, the ML model is ready to go.  The code for the prediction service was already written for you.  This will load the ML model, run a REST endpoint, and respond, indicating if the model predicted a legitimate disaster message.  The prediction code is [here][5] if you want to take a look.

## Prediction Service

Let's deploy the NLP Prediction Service on OpenShift Serverless.

Build the container image:

```execute
oc new-build python:3.6-ubi8~https://github.com/RedHatGov/serverless-workshop-code#workshop --name prediction --context-dir=model/prediction
```

Wait until the build completes:

```execute
oc get pods
```

Output (sample):
```
NAME                 READY   STATUS      RESTARTS   AGE
prediction-1-build   0/1     Completed   0          2m4s
```

After the container image is ready, we need to prepare the external configuration for the service.  This includes:

1. Credentials to access ODF
2. Storage bucket and endpoint (where the model is hosted) and file name (the name of the model file itself)

The secret `serverless-workshop-ml` already exists for #1.  For #2, we'll set these directly as environment variables when you deploy the service.

Finally, let's deploy this to OpenShift Serverless!

```execute
PREDICTION_IMAGE_URI=$(oc get is prediction --template='{{.status.dockerImageRepository}}')
kn service create prediction --image $PREDICTION_IMAGE_URI --env-from secret:serverless-workshop-ml \
--env ENDPOINT_URL=$ENDPOINT_URL --env BUCKET_NAME=$BUCKET_NAME --env MODEL_FILE_NAME=model.pkl --force
```

Wait until the service successfully deploys.

List the services:

```execute
kn service list
```

Output (sample):
```
NAME         URL                                                                  LATEST               AGE     CONDITIONS   READY   REASON
prediction   http://prediction-userx.apps.cluster-xxxx.xxxx.example.opentlc.com   prediction-xxxxx-1   2m39s   3 OK / 3     True    
```

## Test API

Alright!  It's time to test the API.

Get the prediction endpoint:

```execute
PREDICTION_URL=$(oc get route.serving.knative.dev prediction --template='{{.status.url}}/predict')
```

Send a sample request.  This should return 'No disaster':

```execute
curl -X POST -d 'Body=nothing to see here' $PREDICTION_URL | xmllint --format -
```

Send another sample request.  This should return 'This is a disaster!':

```execute
curl -X POST -d 'Body=massive flooding and thunderstorms taking place' $PREDICTION_URL | xmllint --format -
```

Wait a minute.  We sent the message 'massive flooding and thunderstorms taking place' and it returned 'No disaster' instead!

The NLP model should have predicted that this is a legitimate message.  What happened?

## Summary

You built the NLP Prediction Service and deployed it using OpenShift Serverless with our pre-built ML model.  However, the prediction service seems to be broken.  We will debug and figure out what is going on in the next lab.

[1]: https://www.redhat.com/en/technologies/cloud-computing/openshift-data-foundation
[2]: https://www.kaggle.com/vbmokin/nlp-with-disaster-tweets-cleaning-data
[3]: https://scikit-learn.org/stable/modules/generated/sklearn.naive_bayes.MultinomialNB.html
[4]: https://github.com/RedHatGov/serverless-workshop-code/blob/workshop/model/training/train.py
[5]: https://github.com/RedHatGov/serverless-workshop-code/blob/workshop/model/prediction/prediction.py
