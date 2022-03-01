# define which pod by label and which port to redirect
$label = "app.kubernetes.io/name=rabbitmq"
$port = 15672

Write-Host "label is `"$label`", looking up name..."
$podName = @(kubectl -n cluedin get pods -l $label -o name)
Write-Host "name is `"$podName`""
kubectl -n cluedin port-forward $podName $port