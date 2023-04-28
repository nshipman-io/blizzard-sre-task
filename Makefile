build:
	docker build -t th3-server:${VERSION} .
	kind load docker-image th3-server:${VERSION} --name=blizzard-1

update_deploy: build
	./scripts/deploy.sh ${VERSION}

run_cluster:
	echo "Creating blizzard kind cluster..."
	kind create cluster --config=cluster.yaml
	echo "Installing nginx ingress controller to blizzard kind cluster..."
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	echo "Wait for nginx ingress resources to provision..."
	sleep 20
	kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s


init_app: build
	echo "Loading th3-server image to kind cluster..."
	kind load docker-image th3-server:${VERSION} --name=blizzard-1
	echo "Deploying kubernetes manifests for th3-server: Deployment, Service, Ingress"
	kubectl apply -f infra/blue-deployment.yaml
	kubectl apply -f infra/green-deployment.yaml
	kubectl apply -f infra/service.yaml
	kubectl apply -f infra/ingress.yaml

blue_green_swap:
	./scripts/bg-swap.sh

delete_cluster:
	kind delete cluster --name=blizzard-1