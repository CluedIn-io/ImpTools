Write-Host "you need to open http://localhost:9003/hangfire in your browser"

# define which pod by label and which port to redirect
$label = "role=processing"
$port = 9003

Write-Host "label is `"$label`", looking up name..."
$podName = @(kubectl -n cluedin get pods -l $label -o name)
Write-Host "name is `"$podName`""
kubectl -n cluedin port-forward $podName $port