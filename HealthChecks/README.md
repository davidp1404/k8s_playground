# K8s application modeling
## Health checks

Create the environment in your k8s instance and start demo app
```
git clone https://github.com/davidp1404/k8s_playground.git
cd k8s_playground/
./set-env.sh
cd HealthChecks
make apply

k get pod -l app=pyweb
NAME                     READY   STATUS    RESTARTS   AGE
pyweb-845d94cd89-5s2sb   1/1     Running   0          6s
pyweb-845d94cd89-j87x7   1/1     Running   0          6s
pyweb-ping               1/1     Running   0          3s
```
Start a new terminal and execute:
```
make watch1
kubectl exec -it pyweb-ping -- python /tmp/httping.py
http://pyweb-service:8080 2022-02-25 12:10:03.644260 code: 200
http://pyweb-service:8080 2022-02-25 12:10:04.148395 code: 200
http://pyweb-service:8080 2022-02-25 12:10:04.652645 code: 200
http://pyweb-service:8080 2022-02-25 12:10:05.157840 code: 200
```
Previous window will show you how the service is responding when some events happen (the customer perspective).

Start another terminal and execute:
```
make watch2
Every 1.0s: kubectl get endpoints,pod | grep pyweb   ES-00004027: Fri Feb 25 13:13:23 2022

endpoints/pyweb-service              10.240.77.210:8080,10.240.84.61:8080  5m34s
pod/pyweb-845d94cd89-5s2sb                    1/1     Running   0          5m35s
pod/pyweb-845d94cd89-j87x7                    1/1     Running   0          5m35s
pod/pyweb-ping                                1/1     Running   0          5m32s
```
Previous window will show you each second how related pods and endpoints change when some events happen.

## The events
To understand the logic behind these events you must read the files in this folder with python code.
1. One of the pods suffer an internal failure. To simulate it execute :
```
k exec -it $(k get pod -l app=pyweb -o json | jq -r .items[0].metadata.name) -- rm /tmp/ok
```
What does the customer see?, why?, does it recover?.   

To recover the error execute:
```
k exec -it $(k get pod -l app=pyweb -o json | jq -r .items[0].metadata.name) -- touch /tmp/ok
```

2. You scale the deployment adding 1 pod more, to do so execute:
```
k scale deployment pyweb --replicas=3
```
What does the customer see?, why?, does it recover?.


## Reflections
- There are three things you can change to improve customer experience in the yaml definitions.
- There a key change to improve customer experience that only can be solved by the developer (who create the pyweb.py file)


<details close>
<summary> Solution</summary>
<br>

## Key points to highlight:
- If you don't set the readiness probe, the kubelet assumes that the app is ready to receive traffic as soon as the container starts.
- If the container takes 10 secons to start, all the requests to it will fail for those 10 seconds. 
- If the application reaches an unrecoverable error, you should let it crash quickly. A common best-practice if is to implement a full health check in your app returning an error code that tells k8s (kubelet) the container/pod is dead. If your app is vulnerable to deadlocks implements watchdog functions.
- Readiness probes delay setting conditions conditions to insertion of the pod in the service (endpoints join the pieces), but does nothing after it is added.
- Liveness probles monitor and restart pods along all its live.
- You must understand the [pod lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/) to tune properly your app for minimal downtime. There are not single value definition that fits all cases.





