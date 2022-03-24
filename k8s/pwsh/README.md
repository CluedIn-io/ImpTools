# Convenience Scripts

Typically when I setup a new cluster, I create a new folder for it and then copy the current scripts in this folder to there. Next I update the `login.ps1` script accordlying and use that to ensure that I'm always in the correct context.

note: scripts assume you already have your current context namespace set to cluedin - run [set_ns_to_cluedin.ps1](set_ns_to_cluedin.ps1) to do just that.

Rudi: The intent of this folder is to store common CluedIn specific kubectl and the like commands as used by the implementation team. Please feel free to add yours.

Please turn it into an example .ps1 file and feel free to commit to the above... bonus points for putting some comments in the script 😉

All the port forward scripts use labels rather than pod names to ensure the scripts work across many different instances. Labels are used where ever possible.

These examples have been selected on the basis of common usage.

| Script | Description |
| --- | --- |
|login.ps1| Example script for changing our context to the cluster of interest and ensuring we are in the right context|
|set_ns_to_cluedin.ps1 | Set the current context to the cluedin namespace - means you don't need to put `-n cluedin` on all your `kubectl` commands |
|gp.ps1| shortcut for `kubectl get pods`|
|get_config_map.ps1| contains examples of useful config map commands |
|helm_upgrade-3.3.0.ps1| helm upgrade/install command for 3.3 GA |
|helm_upgrade.ps1| helm upgrade/install command for previous release (3.2.5 GA) |
|install_haproxy-ingress.ps1| 3.2.5 haproxy install command |
|pf_es.ps1| port forward elasticsearch to localhost |
|pf_hangfire.ps1| port forward to access the hangfire scheduler in the processing pod - access by http://localhost:9003/hangfire |
|pf_neo4j.ps1| port forward Neo4j 7474 to localhost |
|pf_neo4j_2nd.ps1| port forward Neo4j 7687 to localhost (run in separate window to above one) |
|pf_rmq.ps1| port forward rabbitmq to localhost |
|pf_sqlserver.ps1| port forward sqlserver to localhost |
|restart_ingress_ui.ps1| restart frontend type pods - ingress and ui |
|restart_main_processing_crawling.ps1| restart the 3 pods that do most of the work |
|restart_rmq.ps1| restart rabbitmq |
|restart_submitter.ps1| restart the submitter |
|shutdown_scale_down_cluster_00.ps1|run me first to shutdown the top level pods|
|shutdown_scale_down_cluster_01.ps1|run me second to shutdown the low level pods once the top level pods are down|
|startup_scale_up_cluster_00.ps1|run me first - opposite of the shutdown process|
|startup_scale_up_cluster_01.ps1|run me second - opposite of the shutdown process|

# Example Session

```
# ensure we are in the right context
# the node pool looks right and the names match what I see in the Azure Portal
# the load balancer second IP address (i.e. the public IP) matches the DNS lookup of the cluster of interest
PS > .\login.ps1
Switched to context "APAC-demo-k8s".
NAME                                  STATUS   ROLES   AGE   VERSION
aks-corepool-17590510-vmss00000e      Ready    agent   10d   v1.20.9
aks-datapool-17590510-vmss00000s      Ready    agent   10d   v1.20.9
aks-datapool-17590510-vmss00000t      Ready    agent   10d   v1.20.9
aks-generalpool-17590510-vmss00000s   Ready    agent   10d   v1.20.9
aks-generalpool-17590510-vmss00000t   Ready    agent   10d   v1.20.9
aks-processpool-17590510-vmss00000e   Ready    agent   10d   v1.20.9
cluedin-haproxy-ingress            LoadBalancer   10.0.90.9      20.193.9.158   80:30025/TCP,443:30007/TCP                              29d
Non-authoritative answer:
Name:    k1.cluedin.me
Address:  20.193.9.158

# set our namespace to default to cluedin
PS > .\set_ns_to_cluedin.ps1
Context "APAC-demo-k8s" modified.

# get all pods (in the cluedin namespace)
PS > .\gp.ps1
NAME                                               READY   STATUS    RESTARTS   AGE
alertmanager-cluedin-alertmanager-0                2/2     Running   0          27h
cluedin-annotation-85576b49bb-jf6bb                1/1     Running   0          27h
cluedin-cert-manager-6555bff977-96hwk              1/1     Running   0          27h
cluedin-cert-manager-cainjector-556ddb47d6-8tq77   1/1     Running   0          27h
cluedin-cert-manager-webhook-59ddc48fbf-h7tqs      1/1     Running   0          27h
cluedin-controller-5c95967ff4-pj8sh                1/1     Running   0          27h
cluedin-datasource-7644786b48-vbft7                1/1     Running   2          27h
cluedin-elasticsearch-0                            1/1     Running   0          27h
cluedin-gql-5fc4f5d858-gfv8t                       1/1     Running   0          27h
cluedin-grafana-7b45668d44-bmxxk                   2/2     Running   0          27h
cluedin-haproxy-ingress-dddfc9cf9-bdrk6            1/1     Running   0          27h
cluedin-kube-state-metrics-659ffc4664-lflqd        1/1     Running   0          27h
cluedin-neo4j-core-0                               1/1     Running   0          27h
cluedin-openrefine-55f89987ff-xg69k                1/1     Running   0          27h
cluedin-operator-998bcdf49-z24fb                   1/1     Running   0          27h
cluedin-prepare-58f6b9696b-dnxv9                   1/1     Running   2          27h
cluedin-prometheus-node-exporter-4cpcm             1/1     Running   0          27h
cluedin-prometheus-node-exporter-5trqc             1/1     Running   0          27h
cluedin-prometheus-node-exporter-7bhdq             1/1     Running   0          27h
cluedin-prometheus-node-exporter-8kdtd             1/1     Running   0          27h
cluedin-prometheus-node-exporter-x9mtc             1/1     Running   0          27h
cluedin-prometheus-node-exporter-zlv76             1/1     Running   0          27h
cluedin-rabbitmq-0                                 1/1     Running   0          27h
cluedin-redis-master-0                             2/2     Running   0          27h
cluedin-server-5b8989bcd5-2t954                    1/1     Running   0          27h
cluedin-server-processing-f9bd4695f-szcvq          1/1     Running   0          27h
cluedin-sqlserver-64ff77dd95-cgslq                 1/1     Running   0          27h
cluedin-submitter-644fc8bdf8-gppz6                 1/1     Running   0          27h
cluedin-ui-c969d466c-797g9                         1/1     Running   0          27h
cluedin-webapi-69f8b8dc8f-8xfkr                    1/1     Running   0          27h
prometheus-cluedin-prometheus-0                    2/2     Running   0          27h

# port forward so you can connect to http://localhost:15672/ to connect to rabbitmq admin web portal
# typically you run this in it's own window since it blocks the terminal
PS > .\pf_rmq.ps1
label is "app.kubernetes.io/name=rabbitmq", looking up name...
name is "pod/cluedin-rabbitmq-0"
Forwarding from 127.0.0.1:15672 -> 15672
Forwarding from [::1]:15672 -> 15672
<use ctrl+c to break portforward>

# restart the 3 pods that do most of the work
PS > .\restart_main_processing_crawling.ps1
```

# kubectl-aliases-powershell
https://github.com/shanoor/kubectl-aliases-powershell

"This repository contains a script to generate hundreds of convenient kubectl PowerShell aliases programmatically."

Roman: *"I personally use this (forked from this https://github.com/ahmetb/kubectl-aliases) but fairly speaking, I prefer to memoize the native commands instead of custom aliases. So the only thing I use heavily is `k` instead of `kubectl`"*
