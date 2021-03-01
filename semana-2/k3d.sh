#cria o cluster
k3d cluster create

k3d cluster list

k3d cluster delete ${NOME_CLUSTER}

k3d cluster create meucluster --servers 2 --agents 2

kubectl get nodes

kubectl get pods

kubectl create -f ${PATH DO ARQUIVO}