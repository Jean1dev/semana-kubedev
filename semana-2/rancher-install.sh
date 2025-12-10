#!/bin/bash

echo "=== Instalacao do Rancher no cluster k3d ==="

echo "1. Adicionando o Helm repository do Rancher..."
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update

echo "2. Criando namespace para o Rancher..."
kubectl create namespace cattle-system

echo "3. Instalando cert-manager (requisito do Rancher)..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

echo "4. Aguardando cert-manager ficar pronto..."
echo "   Aguardando pods do cert-manager iniciarem..."
for i in {1..30}; do
    READY=$(kubectl get pods -n cert-manager --no-headers 2>/dev/null | grep -c "Running" || echo "0")
    TOTAL=$(kubectl get pods -n cert-manager --no-headers 2>/dev/null | wc -l | tr -d ' ')
    if [ -z "$TOTAL" ] || [ "$TOTAL" = "0" ]; then
        TOTAL=0
    fi
    if [ -z "$READY" ]; then
        READY=0
    fi
    if [ "$READY" -eq "$TOTAL" ] && [ "$TOTAL" -gt 0 ]; then
        echo "   [OK] Cert-manager esta pronto ($READY/$TOTAL pods rodando)"
        break
    fi
    echo "   Aguardando... ($i/30) - $READY/$TOTAL pods prontos"
    sleep 2
done

echo "5. Verificando status do cert-manager..."
kubectl get pods -n cert-manager

echo "6. Instalando o Rancher..."
helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.local \
  --set bootstrapPassword=admin \
  --set replicas=1

echo "7. Aguardando o Rancher iniciar (60 segundos)..."
sleep 60

echo "8. Verificando status do Rancher..."
kubectl get pods -n cattle-system

echo "9. Obtendo o IP do serviço do Rancher..."
kubectl get svc -n cattle-system rancher

echo ""
echo "=== Instalacao concluida ==="
echo ""
echo "OPCOES DE ACESSO:"
echo ""
echo "Opcao 1 - Port Forward (Recomendado para testes locais):"
echo "  kubectl port-forward -n cattle-system svc/rancher 8443:443"
echo "  Acesse: https://localhost:8443"
echo "  (Usando porta 8443 pois 443 requer privilégios de root)"
echo ""
echo "Opcao 2 - Via /etc/hosts:"
echo "  1. Obtenha o IP: kubectl get svc -n cattle-system rancher"
echo "  2. Adicione ao /etc/hosts: <IP_DO_SERVICO> rancher.local"
echo "  3. Acesse: https://rancher.local"
echo ""
echo "CREDENCIAIS INICIAIS:"
echo "  Usuario: admin"
echo "  Senha: admin"
echo ""
echo "COMANDOS UTEIS:"
echo "  Verificar status: kubectl get pods -n cattle-system"
echo "  Ver logs: kubectl logs -n cattle-system -l app=rancher"
echo "  Ver servicos: kubectl get svc -n cattle-system"

