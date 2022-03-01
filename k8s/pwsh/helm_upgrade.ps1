# for version 3.2.5 only

helm upgrade cluedin-demo cluedin/cluedin `
  -n cluedin `
  --install `
  --version 3.2.5 `
  --values C:\rudi.harris\k8s\cluedin\apac-demo\values.3.2.5.yml
