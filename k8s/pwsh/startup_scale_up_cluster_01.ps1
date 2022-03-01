Write-Host "scaling up top level pods"
kubectl scale deploy -n cluedin --replicas=1 --all