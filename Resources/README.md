#  K8s application modeling
## Resources and Resiliency

Create the environment in your k8s instance and start demo app
```
git clone https://github.com/davidp1404/k8s_playground.git
cd k8s_playground/
./set-env.sh
cd Resources
make apply

$ k get pod -o wide 
$ k get pod -o wide
NAME                          READY   STATUS    RESTARTS   AGE   IP              NODE            NOMINATED NODE   READINESS GATES
sample-app-59f7b5d8f8-j8zl9   1/1     Running   0          49s   10.240.96.225   k8swrk-lab-02   <none>           <none>
sample-app-59f7b5d8f8-k7twx   1/1     Running   0          49s   10.240.96.238   k8swrk-lab-02   <none>           <none>
```
Review yaml definition of file SampleApp.yaml
Open grafana dashboard "Compute Resources/Namespace (Workload)" and select "playground" namespace and deployment "sample-app".

## Play a little

1. How many cpu/mem requested the pods?, if the yaml definition doesn't set resource requests nor limits, where they come from?
```
make resources
```

2. Explore what happen when your pod exceeds resource thresholds.

```
# Open a terminal and execute:
make stress-low
make watch

# Open another terminal and execute:
make monitor

# Open another terminal and execute:
make top
```
- How many cpu/mem resources show the top output?, where they come from?
- Try to execute a higher load in the pod with:
 ```
make stress-off
make stress-hard
stress: info: [2339] dispatching hogs: 4 cpu, 0 io, 4 vm, 0 hdd
stress: FAIL: [2339] (415) <-- worker 2352 got signal 9
stress: WARN: [2339] (417) now reaping child worker processes
stress: FAIL: [2339] (451) failed run completed in 2s
command terminated with exit code 1
 ```
- Why the stress process is killed?, by whom?

3. What should you do to be able to execute a higher load?. 

4. Try to play executing into the pods a higher load. Do the cpu load changes impact in the same way that the memory ones?, why?.    
Examples of stress commands:
 ```
stress -m 4 --vm-bytes 1073741824   # spawn 4 processes using 1GB of memory each
stress -c 4                         # spawn 4 processes requesting as much cpu as they can
 ```

5. Play with app resiliency
Using http-server.yaml 
```
k create -f http-server.yaml
# In another terminal execute this monitor customer perspective
make httping
PING my-http-server:80 (/):
connected to 10.240.23.86:80 (237 bytes), seq=0 time=  2.90 ms 200 OK
connected to 10.240.23.86:80 (237 bytes), seq=1 time=  1.37 ms 200 OK
connected to 10.240.23.86:80 (237 bytes), seq=2 time=  0.84 ms 200 OK
...
```
- Change the strategy to "type: Recreate" and compare 
- Try to scale the replicas to a number higher that your workers, what happen?
- Restablish the strategy to "type: RollingUpdate" and change the surge and unavailable numbers.
```
k rollout restart deployment my-http-server
# Watch how pod are recreated
watch -n 1 kubectl get pod -l app=my-http-server
```

Resources:
- https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
- https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/#node-out-of-memory-behavior
- https://medium.com/tailwinds-navigator/kubernetes-tip-how-does-oomkilled-work-ba71b135993b 

<details close>
<summary> Solution</summary>
<br>
