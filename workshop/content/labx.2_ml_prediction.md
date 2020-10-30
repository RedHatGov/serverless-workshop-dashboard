# Build machine learning API

## Background

In this lab, you will build and deploy the `NLP Prediction Service` using OpenShift Serverless.  The prediction service needs a Natural Language Processing (NLP) model to verify if a message describes a legitimate disaster.  To make things easier, we pre-created this model for you and stored this in [OpenShift Container Storage (OCS)][1].  

How did we create this model?  The model was trained on a [Twitter dataset][2] originally used for a Kaggle competition, in which tweets were labeled `1` (the tweet is about a real disater) or `0` (the tweet is not about a real disaster).  If you're curious, the model uses a scikit-learn [Multionomial Naive Bayes classifier][3] to make its predictions.  The training code is [here][4] if you want to take a look.

Don't worry too much about the ML details.  The model isn't perfect (it's not super accurate and the data is skewed in favor of 'tweet' messages), but it's a good starting point.  More importantly, we gave you a model you can use to run the prediction service!  Let's get started.

## Prediction Service

First, let's make sure a storage bucket was created in OCS:

```execute
oc get objectbucket
```

You should see a bucket called `obc-%username%-serverless-workshop-ml`.

Set the endpoint and keys required to connect to your bucket:

```execute
export ENDPOINT_URL=https://s3.openshift-storage.svc:443
# export ENDPOINT_URL=https://s3-openshift-storage.apps.cluster-59ca.59ca.example.opentlc.com:443
export AWS_ACCESS_KEY_ID=$(oc get secret serverless-workshop-ml -o jsonpath="{.data.AWS_ACCESS_KEY_ID}" | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(oc get secret serverless-workshop-ml -o jsonpath="{.data.AWS_SECRET_ACCESS_KEY}" | base64 --decode)
```

List the objects in your bucket:

```execute
export BUCKET_NAME=$(oc get cm serverless-workshop-ml -o jsonpath="{.data.BUCKET_NAME}")
aws2 --endpoint $ENDPOINT_URL s3 ls s3://$BUCKET_NAME
```

You should see the `model.pkl` file in the output.

Awesome, you have the ML model ready to go.  We also wrote the code for the prediction service.  This will load the ML model, run a REST `/predict` endpoint, and respond, indicating if the model predicted a legitimate disaster message was sent.  Take a look at the code [here][5].



[1]: https://www.redhat.com/en/technologies/cloud-computing/openshift-container-storage
[2]: https://www.kaggle.com/vbmokin/nlp-with-disaster-tweets-cleaning-data
[3]: https://scikit-learn.org/stable/modules/generated/sklearn.naive_bayes.MultinomialNB.html
[4]: https://github.com/RedHatGov/serverless-workshop-code/blob/workshop/model/training/train.py
[5]: https://github.com/RedHatGov/serverless-workshop-code/blob/workshop/model/prediction/prediction.py

