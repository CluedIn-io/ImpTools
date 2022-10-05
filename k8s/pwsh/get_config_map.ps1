# list all config maps
# kubectl -n cluedin get cm

# kubectl -n cluedin get cm | FindStr server
# cluedin-apiserver                           1      27d
# cluedin-server                              27     27d
# cluedin-server-crawling                     5      27d
# cluedin-server-crawling-disable             1      27d
# cluedin-server-packages                     1      27d
# cluedin-server-processing                   5      27d
# cluedin-server-processing-disable           19     27d

# example get config map
kubectl -n cluedin get cm -o yaml cluedin-server