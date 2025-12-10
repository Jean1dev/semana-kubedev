#!/bin/bash

echo "=== Diagnostico de Problemas com Rancher ==="
echo ""

echo "1. Verificando status dos pods do Rancher..."
kubectl get pods -n cattle-system
echo ""

echo "2. Verificando status dos pods do cert-manager..."
kubectl get pods -n cert-manager
echo ""

echo "3. Verificando eventos recentes do Rancher..."
kubectl get events -n cattle-system --sort-by='.lastTimestamp' | tail -10
echo ""

echo "4. Verificando eventos recentes do cert-manager..."
kubectl get events -n cert-manager --sort-by='.lastTimestamp' | tail -10
echo ""

echo "5. Verificando servicos..."
kubectl get svc -n cattle-system
echo ""

echo "6. Testando conectividade com Docker Hub..."
kubectl run test-connectivity-$(date +%s) \
  --image=busybox \
  --rm -i \
  --restart=Never \
  -- nslookup registry-1.docker.io 2>&1 || echo "ERRO: Nao foi possivel resolver DNS do Docker Hub"
echo ""

echo "7. Verificando nodes do cluster..."
kubectl get nodes -o wide
echo ""

echo "8. Verificando se ha problemas com imagens..."
for pod in $(kubectl get pods -n cattle-system -o name); do
  echo "--- Detalhes do pod: $pod ---"
  kubectl describe $pod -n cattle-system | grep -A 5 "Events:" | tail -5
done

echo ""
echo "=== Diagnostico concluido ==="
echo ""
echo "Se os pods estao em ContainerCreating por muito tempo, verifique:"
echo "  - Conectividade de rede"
echo "  - DNS funcionando"
echo "  - Docker rodando na maquina host"
echo "  - Firewall/proxy bloqueando acesso ao Docker Hub"

