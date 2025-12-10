#!/bin/bash

echo "=== Script de Reinstalacao do Rancher com Correcao de Conectividade ==="
echo ""

echo "Este script vai:"
echo "1. Limpar instalacao atual do Rancher"
echo "2. Deletar o cluster k3d atual"
echo "3. Recriar o cluster com configuracoes corretas"
echo "4. Reinstalar o Rancher"
echo ""

echo ""
echo "=== PASSO 1: Deletando cluster k3d atual ==="
echo "   Isso vai remover automaticamente todos os namespaces e recursos..."
k3d cluster delete binno 2>/dev/null && echo "[OK] Cluster binno deletado" || echo "[INFO] Cluster binno nao existe"

echo ""
echo "=== PASSO 2: Limpando recursos remanescentes (se houver) ==="
echo "   Tentando desinstalar Rancher via Helm (timeout 10s)..."
timeout 10 helm uninstall rancher -n cattle-system 2>/dev/null && echo "[OK] Rancher desinstalado" || echo "[INFO] Rancher nao estava instalado ou ja foi removido"

echo ""
echo "=== PASSO 3: Verificando portas disponiveis ==="
PORTS=(8080 8181 8282 8383)
PORTS_ALTERNATIVAS=(9080 9181 9282 9383)
USE_ALT=false

for i in "${!PORTS[@]}"; do
    if ss -tulpn | grep -q ":${PORTS[$i]} "; then
        echo "[AVISO] Porta ${PORTS[$i]} esta em uso, usando alternativa ${PORTS_ALTERNATIVAS[$i]}"
        USE_ALT=true
    fi
done

if [ "$USE_ALT" = true ]; then
    PORT1=${PORTS_ALTERNATIVAS[0]}
    PORT2=${PORTS_ALTERNATIVAS[1]}
    PORT3=${PORTS_ALTERNATIVAS[2]}
    PORT4=${PORTS_ALTERNATIVAS[3]}
else
    PORT1=${PORTS[0]}
    PORT2=${PORTS[1]}
    PORT3=${PORTS[2]}
    PORT4=${PORTS[3]}
fi

echo ""
echo "=== PASSO 4: Criando cluster k3d com configuracoes otimizadas ==="
echo "Usando portas: $PORT1, $PORT2, $PORT3, $PORT4"

k3d cluster create binno \
  --servers 1 \
  --agents 2 \
  -p "$PORT1:30000@loadbalancer" \
  -p "$PORT2:30001@loadbalancer" \
  -p "$PORT3:30002@loadbalancer" \
  -p "$PORT4:30003@loadbalancer"

if [ $? -ne 0 ]; then
    echo "[ERRO] Falha ao criar cluster k3d"
    exit 1
fi

echo "[OK] Cluster criado com sucesso"

echo ""
echo "=== PASSO 5: Aguardando cluster ficar pronto ==="
sleep 10
kubectl wait --for=condition=Ready nodes --all --timeout=60s

echo ""
echo "=== PASSO 6: Configurando DNS nos nodes ==="
echo "   Configurando DNS para resolver problemas de conectividade..."
for node in k3d-binno-server-0 k3d-binno-agent-0 k3d-binno-agent-1; do
    if docker exec $node sh -c "nslookup registry-1.docker.io" > /dev/null 2>&1; then
        echo "[OK] DNS ja esta funcionando no $node"
    else
        echo "   Configurando DNS no $node..."
        docker exec $node sh -c "echo 'nameserver 8.8.8.8' > /etc/resolv.conf && echo 'nameserver 8.8.4.4' >> /etc/resolv.conf" 2>/dev/null
        if docker exec $node sh -c "nslookup registry-1.docker.io" > /dev/null 2>&1; then
            echo "[OK] DNS configurado com sucesso no $node"
        else
            echo "[AVISO] DNS pode ainda ter problemas no $node"
        fi
    fi
done

echo ""
echo "=== PASSO 7: Testando conectividade do cluster ==="
kubectl run test-connectivity-$(date +%s) \
  --image=busybox \
  --rm -i \
  --restart=Never \
  -- nslookup registry-1.docker.io 2>&1 | head -5 || echo "[AVISO] Teste de conectividade falhou, mas continuando..."

sleep 3

echo ""
echo "=== PASSO 8: Reinstalando Rancher ==="
cd "$(dirname "$0")" || exit
./rancher-install.sh

echo ""
echo "=== Reinstalacao concluida ==="
echo ""
echo "Para verificar o status:"
echo "  kubectl get pods -n cattle-system -w"
echo ""
echo "Para acessar o Rancher (apos os pods ficarem Ready):"
echo "  kubectl port-forward -n cattle-system svc/rancher 8443:443"
echo "  Acesse: https://localhost:8443"
echo "  (Usando porta 8443 pois 443 requer privilégios de root)"

