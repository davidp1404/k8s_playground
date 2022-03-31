# Application development
## Scaling

Create the environment in your k8s instance and start demo app
```
git clone https://github.com/davidp1404/k8s_playground.git
cd k8s_playground/
./set-env.sh
cd Scaling
make apply
$ k get pod
NAME                        READY   STATUS    RESTARTS   AGE
dep1-app-644ff46688-kmzjq   1/1     Running   0          57m
dep1-app-644ff46688-nrkvn   1/1     Running   0          50m
```
- Read Horizontal Pod Autoscaler documentation at https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
- Review yaml definition of repo yaml files.
- Open grafana dashboard "Compute Resources/Namespace (Workload)" and select "playground" namespace and deployment "dep1-app". Alternatively use "k top pod" command.

## Play a little

1. Simulate workload in current pods
```
make stress-on
make monitor
# Open another shell windows a execute
k get events -w
```
- How long metrics take to show higher values?, where is this timer tuned?
- How many pods are created when metrics break thresolds?, how I can change that?
- Does cpu/mem metrics change in first pods created?
- How are target metrics measured, at pod level or deployment level?
- What would happend in this example if we don't limit the maximum number of pod?

2. Reduce workload
```
make stress-off
# Open another shell windows a execute
k get events -w
```
- How often and how many pods are removed?, how I can change that?
- How we can force a minimum time window to avoid instability with sort peaks 

3. Reflections    
- How hpa feature relates to health concepts (readiness, liveness) and resource capacity planning? 

<details close>
<summary> Solution</summary>
<br>
