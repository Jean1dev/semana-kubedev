# Documentação: Instalação e Uso do Rancher no Cluster k3d

## Visão Geral

O Rancher é uma plataforma de gerenciamento de containers que fornece uma interface gráfica completa para gerenciar clusters Kubernetes. Esta documentação explica como instalar e configurar o Rancher em um cluster k3d local.

## Pré-requisitos

- Cluster k3d criado e funcionando
- Helm instalado no sistema
- kubectl configurado para acessar o cluster
- Acesso à internet para baixar os charts do Helm
- Portas 8080, 8181, 8282, 8383 livres (ou usar portas alternativas)

## Arquitetura da Instalação

### Componentes Instalados

1. **cert-manager**: Gerenciador de certificados TLS necessário para o Rancher
2. **Rancher Server**: Aplicação principal do Rancher que fornece a interface web

### Namespaces Criados

- `cert-manager`: Onde o cert-manager será instalado
- `cattle-system`: Onde o Rancher será instalado

## Processo de Instalação

### Passo 1: Adicionar Helm Repository

O Rancher mantém seus charts Helm no repositório oficial. O comando adiciona esse repositório:

```bash
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
```

**Explicação**: 
- `helm repo add`: Adiciona um novo repositório de charts Helm
- `rancher-latest`: Nome local do repositório
- `helm repo update`: Atualiza a lista de charts disponíveis

### Passo 2: Criar Namespace

```bash
kubectl create namespace cattle-system
```

**Explicação**: 
- Cria um namespace isolado para os recursos do Rancher
- `cattle-system` é o namespace padrão usado pelo Rancher

### Passo 3: Instalar cert-manager

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

**Explicação**:
- O cert-manager é responsável por gerenciar certificados TLS automaticamente
- O Rancher precisa dele para gerar certificados HTTPS válidos
- A instalação via `kubectl apply` cria todos os recursos necessários (CRDs, deployments, services, etc.)

**Recursos criados pelo cert-manager**:
- Custom Resource Definitions (CRDs) para certificados
- Deployment do cert-manager
- Service do cert-manager
- Webhook do cert-manager

### Passo 4: Aguardar cert-manager

```bash
sleep 30
kubectl get pods -n cert-manager
```

**Explicação**:
- É necessário aguardar o cert-manager estar totalmente operacional antes de instalar o Rancher
- O comando `kubectl get pods` verifica se os pods estão rodando

### Passo 5: Instalar Rancher

```bash
helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.local \
  --set bootstrapPassword=admin \
  --set replicas=1
```

**Explicação dos parâmetros**:
- `rancher`: Nome do release Helm (pode ser qualquer nome)
- `rancher-latest/rancher`: Chart do Rancher do repositório adicionado
- `--namespace cattle-system`: Instala no namespace criado anteriormente
- `--set hostname=rancher.local`: Define o hostname que será usado para acessar o Rancher
- `--set bootstrapPassword=admin`: Define a senha inicial do usuário admin
- `--set replicas=1`: Define apenas 1 réplica (adequado para ambiente local)

### Passo 6: Verificar Instalação

```bash
kubectl get pods -n cattle-system
kubectl get svc -n cattle-system rancher
```

**Explicação**:
- `kubectl get pods`: Lista os pods do Rancher e verifica se estão rodando
- `kubectl get svc`: Mostra o serviço do Rancher e seu IP/porta

## Configuração de Acesso

### Opção 1: Usando Port Forward (Recomendado para testes locais)

```bash
kubectl port-forward -n cattle-system svc/rancher 8443:443
```

Depois acesse: `https://localhost:8443`

**Explicação**:
- `port-forward`: Cria um túnel entre sua máquina local e o serviço no cluster
- `8443:443`: Mapeia a porta 8443 local para a porta 443 do serviço
- **Nota**: Usamos a porta 8443 ao invés de 443 porque portas abaixo de 1024 requerem privilégios de root no Linux

### Opção 2: Configurar /etc/hosts

1. Obtenha o IP do serviço:
```bash
kubectl get svc -n cattle-system rancher
```

2. Adicione ao `/etc/hosts`:
```
<IP_DO_SERVICO> rancher.local
```

3. Acesse: `https://rancher.local`

**Explicação**:
- O `/etc/hosts` mapeia o hostname `rancher.local` para o IP do serviço
- Isso permite usar o hostname configurado no Rancher

### Opção 3: Expor via Ingress (se configurado)

Se você tiver um ingress controller configurado no cluster, pode criar um Ingress resource para expor o Rancher.

## Primeiro Acesso

1. Acesse a URL do Rancher (https://rancher.local ou https://localhost)
2. Aceite o aviso de certificado auto-assinado (normal em ambientes locais)
3. Faça login com:
   - **Usuário**: `admin`
   - **Senha**: `admin` (a senha definida no `bootstrapPassword`)

**Importante**: Na primeira vez, o Rancher pedirá para alterar a senha padrão.

## Funcionalidades do Rancher

### Dashboard Principal

- Visão geral de todos os clusters gerenciados
- Status de saúde dos recursos
- Métricas e monitoramento

### Gerenciamento de Clusters

- Adicionar clusters existentes
- Criar novos clusters
- Importar clusters via kubeconfig

### Gerenciamento de Projetos e Namespaces

- Criar e gerenciar projetos
- Organizar namespaces
- Configurar quotas de recursos

### Deployments e Workloads

- Interface visual para criar deployments
- Gerenciar pods, services, ingress
- Visualizar logs e métricas

### ConfigMaps e Secrets

- Criar e editar ConfigMaps
- Gerenciar Secrets de forma segura

## Comandos Úteis

### Verificar Status

```bash
kubectl get pods -n cattle-system
kubectl get svc -n cattle-system
kubectl get ingress -n cattle-system
```

### Ver Logs

```bash
kubectl logs -n cattle-system -l app=rancher
kubectl logs -n cattle-system -l app=rancher -f
```

### Atualizar Rancher

```bash
helm repo update
helm upgrade rancher rancher-latest/rancher -n cattle-system
```

### Desinstalar Rancher

```bash
helm uninstall rancher -n cattle-system
kubectl delete namespace cattle-system
```

### Desinstalar cert-manager

```bash
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

## Troubleshooting

### Problema: Erro ao criar cluster k3d - "address already in use"

**Sintomas**:
- Erro ao executar `k3d cluster create`: `failed to bind host port for 0.0.0.0:8080: address already in use`
- Cluster não é criado

**Causa**:
- Uma aplicação já está usando uma das portas necessárias (8080, 8181, 8282, 8383)

**Diagnóstico**:
```bash
ss -tulpn | grep -E ':(8080|8181|8282|8383) '
./k3d-fix-ports.sh
```

**Soluções**:

1. **Usar portas alternativas** (Recomendado se não puder parar a aplicação):
```bash
k3d cluster delete binno
k3d cluster create binno --servers 1 --agents 2 \
  -p "9080:30000@loadbalancer" \
  -p "9181:30001@loadbalancer" \
  -p "9282:30002@loadbalancer" \
  -p "9383:30003@loadbalancer"
```

2. **Parar o processo que está usando a porta**:
```bash
ss -tulpn | grep :8080
kill <PID>
```

3. **Verificar se há clusters k3d antigos**:
```bash
k3d cluster list
k3d cluster delete <nome-do-cluster>
```

### Problema: Pods não conseguem baixar imagens (Erro de conectividade com Docker Hub)

**Sintomas**:
- Pods ficam em status `ContainerCreating` por muito tempo
- Erro: `failed to pull image` ou `dial tcp: lookup registry-1.docker.io: Try again`

**Diagnóstico**:
```bash
kubectl describe pod -n cattle-system <nome-do-pod>
kubectl get events -n cattle-system --sort-by='.lastTimestamp'
```

**Soluções**:

1. **Verificar conectividade de rede do cluster**:
```bash
kubectl run test-dns --image=busybox --rm -it --restart=Never -- nslookup registry-1.docker.io
```

2. **Recriar o cluster k3d com configuração de DNS**:
```bash
k3d cluster delete binno
k3d cluster create binno \
  --servers 1 \
  --agents 2 \
  -p "8080:30000@loadbalancer" \
  -p "8181:30001@loadbalancer" \
  -p "8282:30002@loadbalancer" \
  -p "8383:30003@loadbalancer" \
  --k3s-arg "--system-default-registry=docker.io@server:0"
```

3. **Verificar se há proxy ou firewall bloqueando**:
```bash
kubectl get nodes -o wide
kubectl describe node <nome-do-node>
```

4. **Aguardar mais tempo** (às vezes é apenas latência de rede):
```bash
kubectl get pods -n cattle-system -w
```

5. **Verificar se o Docker está rodando na máquina host**:
```bash
docker ps
systemctl status docker
```

### Pods não iniciam

```bash
kubectl describe pod -n cattle-system <nome-do-pod>
kubectl logs -n cattle-system <nome-do-pod>
```

### Problemas com certificados

```bash
kubectl get certificates -n cattle-system
kubectl describe certificate -n cattle-system <nome-do-certificado>
```

### Verificar recursos do cert-manager

```bash
kubectl get pods -n cert-manager
kubectl logs -n cert-manager -l app=cert-manager
```

### Resetar senha do admin

Se você perdeu a senha, pode resetá-la:

```bash
kubectl exec -n cattle-system -it <nome-do-pod-rancher> -- reset-password
```

## Integração com o Cluster k3d

O Rancher detecta automaticamente o cluster onde está instalado. Para adicionar o cluster atual:

1. No Rancher, vá em "Clusters"
2. O cluster local já deve aparecer como "Local"
3. Clique nele para ver detalhes e gerenciar recursos

## Segurança em Ambiente Local

**Importante**: Esta configuração usa:
- Certificados auto-assinados (aceite o aviso do navegador)
- Senha padrão simples (altere após primeiro login)
- 1 réplica apenas (não é alta disponibilidade)

Para produção, configure:
- Certificados válidos (Let's Encrypt ou CA própria)
- Senhas fortes
- Múltiplas réplicas
- Backup regular

## Próximos Passos

1. Explorar a interface do Rancher
2. Criar deployments através da UI
3. Visualizar métricas e logs
4. Configurar projetos e namespaces
5. Integrar com outros clusters (se necessário)

## Referências

- [Documentação oficial do Rancher](https://rancher.com/docs/)
- [Rancher Helm Chart](https://github.com/rancher/rancher)
- [cert-manager Documentation](https://cert-manager.io/docs/)

