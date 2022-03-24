# example login.ps1 to assist with changing context

# one step setup to obtain AKS login certs and merge with kubectl config file

# az login
# az account set --subscription 3fa2142d-<redacted>-51b64ad6768d
# az aks get-credentials --resource-group APAC-demo-k8s-rg --name APAC-demo-k8s

# k1.cluedin.me is this AKS named context
kubectl config use-context APAC-demo-k8s

# confirm we are in the right context
# check what nodes we have - does that look right?
# check our public load balancer IP matches our DNS lookup for our expected cluster
kubectl -n cluedin get nodes
kubectl -n cluedin get services | FindStr Load
nslookup k1.cluedin.me

