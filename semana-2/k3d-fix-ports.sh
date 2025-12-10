#!/bin/bash

echo "=== Verificacao e Correcao de Portas para k3d ==="
echo ""

PORTS=(8080 8181 8282 8383)

echo "Verificando portas necessarias para o cluster k3d..."
echo ""

for port in "${PORTS[@]}"; do
    if ss -tulpn | grep -q ":$port "; then
        echo "[CONFLITO] Porta $port esta em uso:"
        ss -tulpn | grep ":$port " | head -1
        PID=$(ss -tulpn | grep ":$port " | grep -oP 'pid=\K[0-9]+' | head -1)
        if [ ! -z "$PID" ]; then
            PROCESS=$(ps -p $PID -o comm= 2>/dev/null)
            echo "  Processo: $PROCESS (PID: $PID)"
        fi
        echo ""
    else
        echo "[OK] Porta $port esta livre"
    fi
done

echo ""
echo "=== Opcoes de Solucao ==="
echo ""
echo "OPCAO 1: Parar o processo que esta usando a porta 8080"
echo "  Execute: kill <PID>"
echo "  Ou se precisar forcar: kill -9 <PID>"
echo ""
echo "OPCAO 2: Usar portas diferentes no cluster k3d"
echo "  Edite o comando de criacao do cluster para usar portas diferentes:"
echo "  k3d cluster create binno --servers 1 --agents 2 \\"
echo "    -p \"9080:30000@loadbalancer\" \\"
echo "    -p \"9181:30001@loadbalancer\" \\"
echo "    -p \"9282:30002@loadbalancer\" \\"
echo "    -p \"9383:30003@loadbalancer\""
echo ""
echo "OPCAO 3: Verificar se ha clusters k3d antigos rodando"
echo "  Execute: k3d cluster list"
echo "  Se houver clusters, delete-os: k3d cluster delete <nome>"

