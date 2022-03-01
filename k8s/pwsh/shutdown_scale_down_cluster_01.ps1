Write-Host "scaling down low level pods (statefulset)"
kubectl scale statefulset -n cluedin --replicas=0 --all

Write-Host "poll get pods until down"
Write-Host "then the cluster can be powered/turned off"