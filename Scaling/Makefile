.ONESHELL:
.SILENT:
SHELL = /usr/bin/bash

apply:
	kubectl create cm dep1-app-script --from-file=script.sh 
	kubectl label cm dep1-app-script app=dep1-app
	kubectl create -f dep1.yaml

clean:
	-kubectl delete deployments -l app=dep1-app
	-kubectl delete cm -l app=dep1-app

redeploy: clean apply
	

stress-on:
	./stress-on.sh

stress-off:
	./stress-off.sh

monitor:
	watch -n 1 "kubectl get pod,horizontalpodautoscalers.autoscaling -l app=dep1-app;kubectl top pod -l app=dep1-app"




