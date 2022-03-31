#!/bin/bash

pods=`kubectl get pod -l app=dep1-app -o json | jq -r .items[].metadata.name`
for pod in $pods
do
	kubectl exec -it $pod -- rm -f /tmp/stress
done

