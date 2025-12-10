#!/bin/bash

echo "=== Solucao para Problemas de Conectividade ==="
echo ""

echo "Este script ajuda a resolver problemas de conectividade com Docker Hub"
echo ""

echo "1. Verificando conectividade basica..."
if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    echo "   [OK] Conectividade basica funcionando"
else
    echo "   [ERRO] Sem conectividade de rede basica"
    exit 1
fi

echo ""
echo "2. Verificando DNS..."
if nslookup registry-1.docker.io > /dev/null 2>&1; then
    echo "   [OK] DNS funcionando na maquina host"
else
    echo "   [AVISO] DNS pode ter problemas na maquina host"
fi

echo ""
echo "3. Verificando se o Docker esta rodando..."
if systemctl is-active --quiet docker 2>/dev/null || docker ps > /dev/null 2>&1; then
    echo "   [OK] Docker esta rodando"
else
    echo "   [AVISO] Docker pode nao estar rodando"
fi

echo ""
echo "4. Verificando status atual dos pods..."
kubectl get pods -n cattle-system
kubectl get pods -n cert-manager

echo ""
echo "=== Opcoes de Solucao ==="
echo ""
echo "OPCAO 1: Aguardar mais tempo (pode ser apenas latencia)"
echo "  Execute: kubectl get pods -n cattle-system -w"
echo "  Pressione Ctrl+C quando os pods ficarem Ready"
echo ""
echo "OPCAO 2: Recriar o cluster k3d (recomendado se o problema persistir)"
echo "  Execute os seguintes comandos:"
echo "  k3d cluster delete binno"
echo "  k3d cluster create binno --servers 1 --agents 2 \\"
echo "    -p \"8080:30000@loadbalancer\" \\"
echo "    -p \"8181:30001@loadbalancer\" \\"
echo "    -p \"8282:30002@loadbalancer\" \\"
echo "    -p \"8383:30003@loadbalancer\""
echo "  Depois execute novamente: ./rancher-install.sh"
echo ""
echo "OPCAO 3: Verificar logs detalhados"
echo "  Execute: ./rancher-diagnose.sh"
echo ""
echo "OPCAO 4: Limpar e reinstalar"
echo "  helm uninstall rancher -n cattle-system"
echo "  kubectl delete namespace cattle-system"
echo "  kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml"
echo "  Depois execute novamente: ./rancher-install.sh"

