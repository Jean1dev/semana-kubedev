# Análise Completa: Imagens Docker JDK 11 Disponíveis

## Resumo Executivo

Com a descontinuação da imagem oficial `openjdk:11` do Docker Hub em julho de 2022, várias alternativas surgiram. Esta análise compara as principais distribuições JDK 11 disponíveis.

---

## 1. Eclipse Temurin (antigo AdoptOpenJDK)

**Tag Recomendada:** `eclipse-temurin:11`

### Características:
- **Tamanho da Imagem (Alpine):** ~58 MB (jre-alpine)
- **Tamanho da Imagem (JDK completo):** ~200-300 MB
- **Base Image:** Debian, Ubuntu, Alpine Linux
- **Certificação:** TCK-certificado (Technology Compatibility Kit)
- **Manutenção:** Eclipse Adoptium Project
- **Atualizações:** Regulares com patches de segurança
- **Vulnerabilidades (2022):** 1 vulnerabilidade de alta severidade reportada

### Vantagens:
- Menor tamanho entre as principais opções (versão Alpine)
- Certificação TCK garante compatibilidade
- Suporte ativo da comunidade Eclipse
- Múltiplas variantes (JDK, JRE, Alpine, Debian)

### Desvantagens:
- Histórico de vulnerabilidades reportadas
- Menor suporte comercial comparado a outras opções

### Uso:
```dockerfile
FROM eclipse-temurin:11
# ou para menor tamanho:
FROM eclipse-temurin:11-jre-alpine
```

---

## 2. Amazon Corretto

**Tag Recomendada:** `amazoncorretto:11`

### Características:
- **Tamanho da Imagem (Alpine):** ~185 MB (alpine-jdk)
- **Tamanho da Imagem (JDK completo):** ~400-500 MB
- **Base Image:** Amazon Linux, Alpine Linux
- **Certificação:** TCK-certificado
- **Manutenção:** Amazon Web Services
- **Atualizações:** Suporte de longo prazo (LTS) com atualizações regulares
- **Vulnerabilidades (2022):** Nenhuma vulnerabilidade reportada

### Vantagens:
- Suporte de longo prazo garantido pela Amazon
- Zero vulnerabilidades reportadas em estudos
- Ideal para ambientes AWS
- Distribuição gratuita e pronta para produção

### Desvantagens:
- Tamanho maior comparado a outras opções
- Pode ser "overkill" para projetos simples

### Uso:
```dockerfile
FROM amazoncorretto:11
# ou versão Alpine:
FROM amazoncorretto:11-alpine-jdk
```

---

## 3. Azul Zulu

**Tag Recomendada:** `azul/zulu-openjdk:11`

### Características:
- **Tamanho da Imagem (Alpine):** ~66 MB (jre-alpine)
- **Tamanho da Imagem (JDK completo):** ~250-350 MB
- **Base Image:** Ubuntu, Alpine Linux, CentOS
- **Certificação:** TCK-certificado
- **Manutenção:** Azul Systems
- **Atualizações:** Regulares, com versões comerciais disponíveis
- **Vulnerabilidades (2022):** Nenhuma vulnerabilidade reportada

### Vantagens:
- Zero vulnerabilidades reportadas
- Suporte comercial disponível
- Boa performance e otimizações
- Tamanho intermediário

### Desvantagens:
- Namespace diferente (`azul/zulu-openjdk` vs padrão)
- Menos popular que Eclipse Temurin

### Uso:
```dockerfile
FROM azul/zulu-openjdk:11
# ou versão Alpine:
FROM azul/zulu-openjdk-alpine:11-jre
```

---

## 4. BellSoft Liberica JDK

**Tag Recomendada:** `bellsoft/liberica-runtime-container:jdk-11`

### Características:
- **Tamanho da Imagem:** ~387 MB (jdk-11-musl)
- **Base Image:** Alpine Linux (musl)
- **Certificação:** TCK-certificado
- **Manutenção:** BellSoft
- **Atualizações:** Regulares com patches de segurança
- **Vulnerabilidades:** Não especificado em estudos recentes

### Vantagens:
- Foco em containers e runtime
- Suporte comercial disponível
- Otimizado para ambientes containerizados

### Desvantagens:
- Tamanho maior
- Menos popular que outras opções
- Namespace diferente

### Uso:
```dockerfile
FROM bellsoft/liberica-runtime-container:jdk-11-musl
```

---

## 5. Microsoft OpenJDK

**Tag Recomendada:** `mcr.microsoft.com/openjdk/jdk:11`

### Características:
- **Tamanho da Imagem:** ~200-300 MB
- **Base Image:** Ubuntu, Alpine
- **Certificação:** TCK-certificado
- **Manutenção:** Microsoft
- **Atualizações:** Regulares

### Vantagens:
- Suporte da Microsoft
- Boa integração com Azure
- Distribuição oficial

### Desvantagens:
- Menos popular que outras opções
- Foco em ecossistema Microsoft

### Uso:
```dockerfile
FROM mcr.microsoft.com/openjdk/jdk:11
```

---

## Comparação Rápida

| Distribuição | Tamanho (Alpine) | Vulnerabilidades | Suporte LTS | Popularidade |
|--------------|------------------|------------------|-------------|--------------|
| **Eclipse Temurin** | ~58 MB | 1 alta (2022) | ✅ | ⭐⭐⭐⭐⭐ |
| **Amazon Corretto** | ~185 MB | 0 | ✅ | ⭐⭐⭐⭐ |
| **Azul Zulu** | ~66 MB | 0 | ✅ | ⭐⭐⭐ |
| **BellSoft Liberica** | ~387 MB | N/A | ✅ | ⭐⭐ |
| **Microsoft OpenJDK** | ~200-300 MB | N/A | ✅ | ⭐⭐ |

---

## Recomendações por Caso de Uso

### 🎯 **Produção Geral (Recomendado)**
**Eclipse Temurin:11**
- Melhor equilíbrio entre tamanho, popularidade e suporte
- Certificação TCK
- Atualizações regulares

### 🔒 **Máxima Segurança**
**Amazon Corretto:11** ou **Azul Zulu:11**
- Zero vulnerabilidades reportadas
- Suporte de longo prazo garantido

### 📦 **Menor Tamanho**
**Eclipse Temurin:11-jre-alpine**
- Menor footprint (~58 MB)
- Ideal para microserviços

### ☁️ **Ambientes AWS**
**Amazon Corretto:11**
- Integração nativa com serviços AWS
- Suporte oficial da Amazon

### 💼 **Suporte Comercial**
**Azul Zulu:11** ou **BellSoft Liberica**
- Opções de suporte comercial disponíveis

---

## Conclusão

Para a maioria dos casos de uso, **Eclipse Temurin:11** é a escolha recomendada por oferecer o melhor equilíbrio entre tamanho, popularidade, suporte da comunidade e certificação. Para ambientes que priorizam segurança máxima ou estão no ecossistema AWS, **Amazon Corretto:11** é uma excelente alternativa.

---

**Última Atualização:** Baseado em dados de 2022-2024
**Nota:** Vulnerabilidades e tamanhos podem variar ao longo do tempo. Sempre verifique as versões mais recentes antes de usar em produção.
