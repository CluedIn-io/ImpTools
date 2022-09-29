# Convenience Scripts

Typically when I setup a new cluster, I create a new folder for it and then copy the current scripts in this folder to there. Next I update the `login.ps1` script accordlying and use that to ensure that I'm always in the correct context.

Rudi: The intent of this folder is to store common CluedIn specific kubectl and the like commands as used by the implementation team. Please feel free to add yours.

Please turn it into an example .ps1 file and feel free to commit to the above... bonus points for putting some comments in the script 😉

All the port forward scripts use labels rather than pod names to ensure the scripts work across many different instances. Labels are used where ever possible.

These examples have been selected on the basis of common usage.

| Script | Description |
| --- | --- |
|login.ps1| Example script for changing our context to the cluster of interest and ensuring we are in the right context|
|set_ns_to_cluedin.ps1 | No longer requried as I have added "-n cluedin" to everything pretty much - Set the current context to the cluedin namespace - means you don't need to put `-n cluedin` on all your `kubectl` commands |
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

# get all pods (in the cluedin namespace)
PS > .\gp.ps1
NAME                                               READY   STATUS    RESTARTS   AGE
alertmanager-cluedin-alertmanager-0               2/2     Running     0          30m
cluedin-annotation-6f68df4bdc-nvnfl               1/1     Running     0          20m
cluedin-cert-manager-57c5cf77d7-55tkw             1/1     Running     0          20m
cluedin-cert-manager-cainjector-d85487df8-sf25s   1/1     Running     0          20m
cluedin-cert-manager-webhook-85fc5f746c-x4sjp     1/1     Running     0          20m
cluedin-controller-755f7c89b4-fpcqs               1/1     Running     0          20m
cluedin-datasource-5bbc477556-prt65               1/1     Running     0          20m
cluedin-elasticsearch-0                           1/1     Running     0          30m
cluedin-gql-c7c8c8476-scvnr                       1/1     Running     0          20m
cluedin-grafana-666d57888d-f228f                  3/3     Running     0          20m
cluedin-haproxy-ingress-69589b754b-d7lrw          1/1     Running     0          20m
cluedin-kube-state-metrics-57799978fc-4llzx       1/1     Running     0          20m
cluedin-libpostal-554855d787-ns6sh                1/1     Running     0          20m
cluedin-neo4j-core-0                              1/1     Running     0          30m
cluedin-openrefine-684f4864db-bkg22               1/1     Running     0          20m
cluedin-operator-f7b8c8bb-r27wx                   1/1     Running     0          20m
cluedin-prepare-dd55bbdf9-f4b69                   1/1     Running     0          20m
cluedin-prometheus-node-exporter-5457p            1/1     Running     0          3d21h
cluedin-prometheus-node-exporter-5b9hp            1/1     Running     0          21d
cluedin-prometheus-node-exporter-fgfp9            1/1     Running     0          21d
cluedin-prometheus-node-exporter-jhxgv            1/1     Running     0          21d
cluedin-prometheus-node-exporter-kjjr7            1/1     Running     0          21d
cluedin-prometheus-node-exporter-m52pm            1/1     Running     0          3d21h
cluedin-prometheus-node-exporter-sxgxg            1/1     Running     0          21d
cluedin-prometheus-node-exporter-t6vc4            1/1     Running     0          21d
cluedin-rabbitmq-0                                1/1     Running     0          30m
cluedin-redis-master-0                            2/2     Running     0          30m
cluedin-server-74fddf54c9-56tsw                   1/1     Running     0          20m
cluedin-server-crawling-748cdc5767-4wpl5          1/1     Running     0          20m
cluedin-server-processing-659dcb95c6-8dttk        1/1     Running     0          20m
cluedin-sqlserver-c96dcbc8d-vg4qh                 1/1     Running     0          20m
cluedin-submitter-d7cdc495-jfnsz                  1/1     Running     0          20m
cluedin-ui-5c7f86dddf-fc2kq                       1/1     Running     0          20m
cluedin-webapi-7fd6d479f7-srxpt                   1/1     Running     0          20m
init-cluedin-job-rl74l                            0/1     Completed   0          21d
init-neo4j-job-g65wb                              0/1     Completed   0          21d
init-sqlserver-job-kmdfk                          0/1     Completed   0          21d
prometheus-cluedin-prometheus-0                   2/2     Running     0          30m

# if after running gp.ps1 there not enough pods running then start up the cluster
PS > .\startup_scale_up_cluster_00.ps1
# poll gp till all running before running next startup 01
PS > .\gp.ps1
PS > .\startup_scale_up_cluster_01.ps1
# poll gp till all running
PS > .\gp.ps1

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
