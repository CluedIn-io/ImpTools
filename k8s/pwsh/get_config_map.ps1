# list all config maps
# kubectl.exe get cm

# kubectl.exe get cm | FindStr server
# cluedin-demo-monitoring-apiserver                           1      43d
# cluedin-demo-server                                         30     43d
# cluedin-demo-server-crawling                                4      43d
# cluedin-demo-server-crawling-disable                        1      43d
# cluedin-demo-server-processing                              4      43d
# cluedin-demo-server-processing-disable                      19     43d

# example get config map
kubectl.exe get cm -o yaml cluedin-demo-server