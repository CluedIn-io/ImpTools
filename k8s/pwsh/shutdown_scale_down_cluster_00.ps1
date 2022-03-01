Write-Host "scaling down top level pods"
kubectl scale deploy -n cluedin --replicas=0 --all

Write-Host "poll get pods until only the stateful are left"
Write-Host "then run .\shutdown_scale_down_cluster_01.ps1"