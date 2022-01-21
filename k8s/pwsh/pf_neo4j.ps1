# define which pod by label and which port to redirect
$label = "app=elasticsearch-master"
$port = 7474

Write-Host "label is `"$label`", looking up name..."
$podName = @(kubectl get pods -l $label -o name)
Write-Host "name is `"$podName`""
kubectl port-forward $podName $port
