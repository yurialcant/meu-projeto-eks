# Projeto EKS com Terraform

Este projeto demonstra uma infraestrutura completa de DevOps usando **Terraform** para provisionar um cluster **Amazon EKS** e fazer deploy de uma aplicação containerizada.

## 🏗️ Arquitetura

O projeto está organizado em **3 workspaces** do Terraform:

1. **`vpc`** - Cria a infraestrutura de rede (VPC, subnets, gateways)
2. **`eks`** - Provisiona o cluster EKS e node groups
3. **`app`** - Deploy da aplicação no Kubernetes

## 📁 Estrutura do Projeto

```
meu-projeto-eks/
├── main.tf                 # Configuração principal do Terraform
├── variables.tf            # Variáveis globais
├── outputs.tf              # Outputs globais
├── Dockerfile              # Container da aplicação
├── index.html              # Página web da aplicação
├── modules/
│   ├── vpc/                # Módulo de rede
│   ├── eks/                # Módulo do cluster EKS
│   └── app_deploy/         # Módulo de deploy da aplicação
└── README.md               # Este arquivo
```

## 🚀 Como Usar

### Pré-requisitos

- Terraform >= 1.0
- AWS CLI configurado
- kubectl instalado
- Docker instalado

### Passos para Deploy

#### 1. Configurar o Backend S3

Certifique-se de que o bucket S3 `meuprojetoeks` existe na região `us-east-1`.

#### 2. Deploy da VPC

```bash
# Criar e selecionar workspace vpc
terraform workspace new vpc
terraform workspace select vpc

# Inicializar e aplicar
terraform init
terraform plan
terraform apply
```

#### 3. Deploy do Cluster EKS

```bash
# Criar e selecionar workspace eks
terraform workspace new eks
terraform workspace select eks

# Inicializar e aplicar
terraform init
terraform plan
terraform apply
```

#### 4. Build e Push da Imagem Docker

```bash
# Fazer login no ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_url)

# Build da imagem
docker build -t $(terraform output -raw ecr_repository_url):latest .

# Push da imagem
docker push $(terraform output -raw ecr_repository_url):latest
```

#### 5. Deploy da Aplicação

```bash
# Criar e selecionar workspace app
terraform workspace new app
terraform workspace select app

# Inicializar e aplicar
terraform init
terraform plan
terraform apply
```

### Acessar a Aplicação

Após o deploy, você pode acessar a aplicação através da URL fornecida no output:

```bash
terraform output application_url
```

## 🛠️ Tecnologias Utilizadas

- **Terraform** - Infrastructure as Code
- **AWS EKS** - Kubernetes gerenciado
- **Docker** - Containerização
- **ECR** - Registry de imagens
- **Kubernetes** - Orquestração de containers
- **Helm** - Gerenciador de pacotes Kubernetes

## 📝 Notas Importantes

- O projeto usa **workspaces** do Terraform para separar os ambientes
- O **backend S3** é usado para armazenar o estado do Terraform
- As **subnets privadas** são usadas para os worker nodes do EKS e têm `map_public_ip_on_launch = true` para permitir que os worker nodes recebam IPs públicos (necessário para o EKS)
- O **LoadBalancer** é criado automaticamente para expor a aplicação

## 🔧 Customização

Você pode customizar o projeto editando as variáveis em `variables.tf`:

- `aws_region` - Região AWS (padrão: us-east-1)
- `project_name` - Nome do projeto (padrão: eks-hello-world)
- `availability_zones` - Zonas de disponibilidade

## 🧹 Limpeza

Para destruir a infraestrutura, execute os comandos na ordem inversa:

```bash
# Destruir aplicação
terraform workspace select app
terraform destroy

# Destruir cluster EKS
terraform workspace select eks
terraform destroy

# Destruir VPC
terraform workspace select vpc
terraform destroy
``` 