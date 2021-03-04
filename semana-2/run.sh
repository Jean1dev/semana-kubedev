kubectl apply -f k8s/mongodb/deployment.yaml
kubectl apply -f k8s/mongodb/service.yaml

kubectl apply -f k8s/api/deployment.yaml
kubectl apply -f k8s/api/service.yaml

kubectl get all

sleep 3

echo '----------------------------------'
kubectl get pods

sleep 3

echo '----------------------------------'
kubectl get pods