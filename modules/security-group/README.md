# Módulo Terraform: transer-iac-tf-mod-security-group

Este módulo de Terraform permite crear y gestionar Security Groups de Amazon VPC con configuraciones flexibles, incluyendo reglas de ingress y egress dinámicas, soporte para múltiples protocolos y referencias entre security groups.

Para ver el historial completo de cambios, consulta el [CHANGELOG.md](./CHANGELOG.md). Se recomienda fijar versiones específicas del módulo en producción para garantizar estabilidad.

## Características

✅ Creación de Security Groups con configuración flexible  
✅ Reglas de ingress y egress dinámicas  
✅ Soporte para múltiples protocolos (TCP, UDP, ICMP, ALL)  
✅ Referencias entre Security Groups y CIDR blocks  
✅ Nomenclatura estandarizada sin contadores numéricos  
✅ Sistema de etiquetado transversal y específico  
✅ Implementación con `for_each` para estabilidad  
✅ Outputs estructurados para integración con otros servicios  
✅ Validaciones de entrada para configuraciones correctas  
✅ Soporte para descripciones detalladas en cada regla  

## Estructura del Módulo

```
transer-iac-tf-mod-security-group/
├── main.tf                           # Recursos principales de Security Groups
├── variables.tf                      # Variables de entrada con validaciones
├── outputs.tf                        # Salidas del módulo
├── README.md                         # Documentación principal
├── CHANGELOG.md                      # Registro de cambios
└── sample/                           # Directorio con ejemplo de uso
    ├── README.md                     # Documentación del ejemplo
    ├── main.tf                       # Configuración principal del ejemplo
    ├── variables.tf                  # Variables del ejemplo
    ├── outputs.tf                    # Salidas del ejemplo
    ├── providers.tf                  # Configuración de proveedores
    └── terraform.auto.tfvars.sample  # Ejemplo de variables
```

## Implementación y Configuración

### Requisitos Técnicos

| Componente | Versión Mínima | Descripción |
|------------|----------------|-------------|
| Terraform  | >= 1.0.0       | Motor de infraestructura como código |
| AWS Provider | >= 4.31.0    | Proveedor de AWS para Terraform |

### Provider Configuration

```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.31.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Environment = "production"
      Project     = "transer"
      Owner       = "cloudops"
      ManagedBy   = "terraform"
    }
  }
}
```

### Configuración del Backend

Se recomienda configurar un backend remoto para el estado de Terraform:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "security-groups/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Convenciones de Nomenclatura

Los recursos creados por este módulo siguen el estándar de nomenclatura:

```
{client}-{functionality}-{environment}-sg-{application}
```

**Ejemplo**: `transer-webapp-pdn-sg-web`

### Estrategia de Etiquetado

Todos los recursos incluyen etiquetas estándar:

- **Name**: Nombre completo del recurso siguiendo la convención
- **id_case**: Número de ticket asociado al cambio
- **accessclass**: Clasificación de acceso del security group
- **application**: Nombre de la aplicación específica

### Recursos Gestionados

| Recurso | Descripción | Cantidad |
|---------|-------------|----------|
| `aws_security_group` | Security Groups de VPC con reglas personalizadas | Variable según configuración |

### Parámetros de Entrada

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sg_config"></a> [sg_config](#input_sg_config) | Configuration for Security Groups organized by unique key | `map(object({...}))` | n/a | yes |
| <a name="input_functionality"></a> [functionality](#input_functionality) | Functionality or specific project identifier | `string` | n/a | yes |
| <a name="input_client"></a> [client](#input_client) | Client name identifier | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input_environment) | Deployment environment (dev, qa, pdn) | `string` | n/a | yes |

### Estructura de Configuración

La variable `sg_config` acepta un mapa de objetos con la siguiente estructura:

```hcl
sg_config = {
  "web-servers" = {
    ticket      = "TICKET-123"           # Associated ticket number
    description = "Security group for web servers"  # SG description
    vpc_id      = "vpc-12345678"         # VPC ID where SG will be created
    application = "web"                  # Application name
    accessclass = "public"               # Access classification
    ingress = [
      {
        from_port       = 80             # Start port
        to_port         = 80             # End port
        protocol        = "tcp"          # Protocol (tcp, udp, icmp, all, -1)
        cidr_blocks     = ["0.0.0.0/0"]  # CIDR blocks (optional)
        security_groups = []             # Security group IDs (optional)
        description     = "HTTP access"  # Rule description
      }
    ]
    egress = [
      {
        from_port   = 0                  # Start port
        to_port     = 0                  # End port
        protocol    = "-1"               # Protocol (-1 for all)
        cidr_blocks = ["0.0.0.0/0"]      # CIDR blocks
        description = "All outbound traffic"  # Rule description
      }
    ]
  }
}
```

#### Protocolos Soportados

- `tcp`: Transmission Control Protocol
- `udp`: User Datagram Protocol
- `icmp`: Internet Control Message Protocol
- `all` / `-1`: Todos los protocolos

### Valores de Salida

| Name | Description |
|------|-------------|
| <a name="output_sg_info"></a> [sg_info](#output_sg_info) | Map containing Security Group information including ID, name, ARN and application for each key |

### Ejemplos de Uso

#### Security Group Básico para Servidores Web

```hcl
module "web_security_groups" {
  source = "./modules/transer-iac-tf-mod-security-group"
  
  client        = "transer"
  functionality = "webapp"
  environment   = "pdn"
  
  sg_config = {
    "web-servers" = {
      ticket      = "TRANS-001"
      description = "Security group for web servers"
      vpc_id      = "vpc-12345678"
      application = "web"
      accessclass = "public"
      ingress = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTP access from anywhere"
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS access from anywhere"
        }
      ]
      egress = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]
    }
  }
}
```

#### Security Groups con Referencias Entre Ellos

```hcl
module "app_security_groups" {
  source = "./modules/transer-iac-tf-mod-security-group"
  
  client        = "transer"
  functionality = "webapp"
  environment   = "pdn"
  
  sg_config = {
    "web-tier" = {
      ticket      = "TRANS-002"
      description = "Security group for web tier"
      vpc_id      = "vpc-12345678"
      application = "web"
      accessclass = "public"
      ingress = [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTP from internet"
        }
      ]
      egress = [
        {
          from_port   = 3000
          to_port     = 3000
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/8"]
          description = "App tier communication"
        }
      ]
    }
    
    "app-tier" = {
      ticket      = "TRANS-002"
      description = "Security group for application tier"
      vpc_id      = "vpc-12345678"
      application = "app"
      accessclass = "private"
      ingress = [
        {
          from_port       = 3000
          to_port         = 3000
          protocol        = "tcp"
          security_groups = ["${module.app_security_groups.sg_info["web-tier"].sg_id}"]
          description     = "Access from web tier"
        }
      ]
      egress = [
        {
          from_port   = 5432
          to_port     = 5432
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/8"]
          description = "Database communication"
        }
      ]
    }
  }
}
```

## Escenarios de Uso Comunes

### Arquitectura de 3 Capas

Configuración típica para aplicaciones web con separación de capas:

```hcl
sg_config = {
  "web-tier" = {
    description = "Web servers - public access"
    ingress = [
      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }
  
  "app-tier" = {
    description = "Application servers - private"
    ingress = [
      { from_port = 8080, to_port = 8080, protocol = "tcp", security_groups = ["sg-web"] }
    ]
  }
  
  "db-tier" = {
    description = "Database servers - restricted"
    ingress = [
      { from_port = 5432, to_port = 5432, protocol = "tcp", security_groups = ["sg-app"] }
    ]
  }
}
```

### Microservicios con Comunicación Interna

Para arquitecturas de microservicios que requieren comunicación entre servicios:

```hcl
sg_config = {
  "api-gateway" = {
    description = "API Gateway security group"
    ingress = [
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }
  
  "user-service" = {
    description = "User microservice"
    ingress = [
      { from_port = 3001, to_port = 3001, protocol = "tcp", security_groups = ["sg-api-gateway"] }
    ]
  }
  
  "order-service" = {
    description = "Order microservice"
    ingress = [
      { from_port = 3002, to_port = 3002, protocol = "tcp", security_groups = ["sg-api-gateway"] }
    ]
  }
}
```

## Consideraciones Operativas

### Rendimiento y Escalabilidad

- **Límites de AWS**: Hasta 2,500 reglas por security group
- **Reglas por VPC**: Hasta 10,000 reglas por VPC por región
- **Security Groups por ENI**: Hasta 5 security groups por interfaz de red
- **Evaluación de Reglas**: Las reglas se evalúan como un conjunto (OR lógico)

### Limitaciones y Restricciones

- Los security groups son **stateful** (el tráfico de retorno se permite automáticamente)
- No se pueden especificar reglas de **deny** (solo allow)
- Los cambios en security groups se aplican **inmediatamente**
- No se pueden referenciar security groups de otras regiones

### Costos y Optimización

- **Sin costo directo**: Los security groups no tienen costo adicional
- **Optimización**: Consolidar reglas similares para reducir complejidad
- **Monitoreo**: Usar VPC Flow Logs para analizar tráfico

### Recomendaciones de Implementación

1. **Principio de menor privilegio**: Otorgar solo los accesos mínimos necesarios
2. **Separación por capas**: Crear security groups específicos por función
3. **Documentar reglas**: Usar descripciones claras en cada regla
4. **Revisar periódicamente**: Auditar reglas no utilizadas
5. **Usar referencias**: Preferir referencias entre SGs sobre CIDR blocks cuando sea posible

## Seguridad y Cumplimiento

### Consideraciones de Seguridad

- **Acceso Mínimo**: Implementar principio de menor privilegio
- **Segregación de Red**: Separar tráfico por función y sensibilidad
- **Monitoreo**: Habilitar VPC Flow Logs para auditoría
- **Documentación**: Mantener descripciones actualizadas de cada regla

### Mejores Prácticas Implementadas

✅ Nomenclatura estandarizada para trazabilidad  
✅ Etiquetado consistente para governance  
✅ Validación de configuraciones de entrada  
✅ Separación de responsabilidades por aplicación  
✅ Documentación detallada de reglas  

### Lista de Verificación de Cumplimiento

- [x] Recursos etiquetados según estándares corporativos
- [x] Nomenclatura siguiendo convenciones establecidas
- [x] Principio de menor privilegio aplicado
- [x] Validaciones de entrada implementadas
- [x] Documentación completa y actualizada

## Observaciones

- **Compatibilidad**: Este módulo es compatible con AWS Provider >= 4.31.0
- **Versionado**: Se recomienda usar tags específicos en lugar de `main` en producción
- **Monitoreo**: Configurar VPC Flow Logs para visibilidad del tráfico
- **Testing**: Probar las configuraciones en entornos de desarrollo antes de producción
- **Dependencias**: Asegurar que las VPCs existan antes de crear security groups

## Seguimiento de cambios

| Fecha        | Descripcion                           | Version | Construido por                   | Aprobador |
|--------------|---------------------------------------|---------|----------------------------------|----------|
| 2025/07/06   | Refactoring crítico y creación v1.0.0| v1.0.0  | Andres Mauricio Sanchez Gonzalez| NA       |
