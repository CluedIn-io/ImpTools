Write-Host "scaling up low level pods (stateful)"
kubectl scale statefulset -n cluedin --replicas=1 --all

Write-Host "poll get pods until all are up"
Write-Host "then run .\startup_scale_up_cluster_01.ps1"