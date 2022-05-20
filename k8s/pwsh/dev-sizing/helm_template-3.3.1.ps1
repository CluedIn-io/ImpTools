helm template cluedin-demo cluedin/cluedin-platform `
  -n cluedin `
  --dry-run `
  --version 1.0.2 `
  --values values.3.3.1.cluedin-platform-1.0.2.yml

# example usage to figure out what images will be required
# PS > .\helm_template-3.3.1.ps1 | FindStr "image:"
          # image: "quay.io/prometheus/node-exporter:v1.2.2"
          # image: "docker.io/groundnuty/k8s-wait-for:v1.3"
          # image: "docker.io/cluedin/controller:3.3.1"
          # image: "cluedin/openrefine:3.3.1"
          # image: "docker.io/groundnuty/k8s-wait-for:v1.3"
          # image: "docker.io/groundnuty/k8s-wait-for:v1.3"
          # image: "docker.io/groundnuty/k8s-wait-for:v1.3"
        # image: "docker.io/cluedin/cluedin-micro-annotation:3.3.1"
        # image: "docker.io/cluedin/cluedin-server:3.3.1"
          # image: "docker.io/cluedin/nuget-installer:3.3.1"
          # image: "docker.io/groundnuty/k8s-wait-for:v1.3"
          # image: "docker.io/groundnuty/k8s-wait-for:v1.3"
          # image: "docker.io/groundnuty/k8s-wait-for:v1.3"
        # image: "docker.io/cluedin/cluedin-server:3.3.1"
		# ...