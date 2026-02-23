# Módulo Terraform: transer-iac-tf-mod-vpc

## Descripción

Este módulo de Terraform crea una infraestructura completa de VPC en AWS con subredes públicas, privadas y de base de datos, incluyendo Internet Gateway y NAT Gateway según sea necesario. El módulo está diseñado para proporcionar una base sólida de red para aplicaciones empresariales con separación clara entre capas de aplicación.

Para ver el historial completo de cambios, consulta el [CHANGELOG.md](./CHANGELOG.md).

**Recomendación**: Se recomienda fijar versiones específicas del módulo en lugar de usar la rama principal para garantizar estabilidad en producción.

## Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                    VPC                                          │
│                              (10.0.0.0/16)                                      │
│                                                                                 │
│  ┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────────┐  │
│  │   Public Subnets    │  │   Private Subnets   │  │   Database Subnets      │  │
│  │   (10.0.1.0/24)     │  │   (10.0.10.0/24)    │  │   (10.0.20.0/24)        │  │
│  │   (10.0.2.0/24)     │  │   (10.0.11.0/24)    │  │   (10.0.21.0/24)        │  │
│  │                     │  │                     │  │                         │  │
│  │ ┌─────────────────┐ │  │ ┌─────────────────┐ │  │ ┌─────────────────────┐ │  │
│  │ │   us-east-1a    │ │  │ │   us-east-1a    │ │  │ │    us-east-1a       │ │  │
│  │ │   us-east-1b    │ │  │ │   us-east-1b    │ │  │ │    us-east-1b       │ │  │
│  │ └─────────────────┘ │  │ └─────────────────┘ │  │ └─────────────────────┘ │  │
│  └─────────────────────┘  └─────────────────────┘  └─────────────────────────┘  │
│           │                         │                                           │
│  ┌─────────────────────┐    ┌─────────────────────┐                             │
│  │  Internet Gateway   │    │    NAT Gateway      │                             │
│  │     (IGW)           │    │   + Elastic IP      │                             │
│  └─────────────────────┘    └─────────────────────┘                             │
└─────────────────────────────────────────────────────────────────────────────────┘
                    │                         │
                    │                         │
            ┌───────────────┐         ┌───────────────┐
            │   Internet    │         │   Internet    │
            │   (0.0.0.0/0) │         │   (0.0.0.0/0) │
            └───────────────┘         └───────────────┘
```

## Características

✅ **VPC personalizable** con configuración flexible de CIDR, DNS y tenencia de instancias  
✅ **Subredes multi-capa** organizadas por función (pública, privada, base de datos)  
✅ **Internet Gateway** opcional para conectividad externa de subredes públicas  
✅ **NAT Gateway** con Elastic IP automática para acceso saliente de subredes privadas  
✅ **Tablas de enrutamiento** automáticas configuradas para cada tipo de subred  
✅ **Etiquetado consistente** siguiendo convenciones organizacionales estándar  
✅ **Validaciones integradas** para CIDR blocks y configuraciones de tenencia  
✅ **Arquitectura modular** con submódulos especializados para cada componente  

## Estructura del Módulo

```
transer-iac-tf-mod-vpc/
├── .gitignore                 # Archivos a ignorar por Git
├── CHANGELOG.md               # Registro de cambios y versiones
├── README.md                  # Documentación principal del módulo
├── main.tf                    # Configuración principal de VPC y orquestación de módulos
├── variables.tf               # Definición de variables de entrada con validaciones
├── outputs.tf                 # Salidas del módulo para integración con otros recursos
├── subnet/                    # Submódulo para gestión de subredes
│   ├── main.tf               # Recursos de subredes y tablas de enrutamiento
│   ├── variables.tf          # Variables específicas del submódulo
│   └── outputs.tf            # Salidas del submódulo de subredes
├── internet_gateway/         # Submódulo para Internet Gateway
│   ├── main.tf               # Recurso de Internet Gateway
│   ├── variables.tf          # Variables del Internet Gateway
│   └── outputs.tf            # Salidas del Internet Gateway
├── nat_gateway/              # Submódulo para NAT Gateway
│   ├── main.tf               # Recursos de NAT Gateway y Elastic IP
│   ├── variables.tf          # Variables del NAT Gateway
│   └── outputs.tf            # Salidas del NAT Gateway
└── sample/                   # Directorio con implementación de ejemplo completa
    ├── README.md             # Documentación detallada del ejemplo
    ├── main.tf               # Configuración principal con arquitectura de 3 capas
    ├── variables.tf          # Variables con valores por defecto y validaciones
    ├── outputs.tf            # Salidas completas incluyendo Security Groups
    ├── providers.tf          # Configuración de proveedores AWS con tags
    └── terraform.auto.tfvars.sample # Plantilla de variables personalizable
```

## Implementación de Ejemplo

El directorio `sample/` contiene una implementación completa y funcional del módulo que demuestra las mejores prácticas de uso. Esta implementación incluye:

### Características del Ejemplo

✅ **Arquitectura de 3 capas** con subredes públicas, privadas y de base de datos  
✅ **Security Groups** configurados para cada capa con reglas de seguridad apropiadas  
✅ **Variables simplificadas** con valores por defecto para facilitar el uso  
✅ **Configuración completa** de proveedores AWS con etiquetado automático  
✅ **Documentación detallada** con instrucciones paso a paso  
✅ **Plantilla de variables** personalizable para diferentes entornos  

### Cómo Usar el Ejemplo

```bash
# Navegar al directorio de ejemplo
cd sample/

# Copiar y personalizar variables
cp terraform.auto.tfvars.sample terraform.auto.tfvars

# Inicializar y desplegar
terraform init
terraform plan
terraform apply
```

### Recursos Incluidos en el Ejemplo

- **VPC** con configuración DNS habilitada
- **6 Subredes** distribuidas en 2 zonas de disponibilidad
- **Internet Gateway** para conectividad externa
- **NAT Gateway** para acceso saliente de subredes privadas
- **3 Security Groups** con reglas de seguridad por capas
- **Route Tables** configuradas automáticamente

Para más detalles, consulta la documentación completa en `sample/README.md`.

## Implementación y Configuración

### Requisitos Técnicos

| Componente | Versión Mínima | Versión Recomendada |
|------------|----------------|---------------------|
| Terraform  | >= 1.0.0       | >= 1.5.0           |
| Provider AWS | >= 4.31.0     | >= 5.0.0           |

### Configuración del Provider

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
  region = var.aws_region
  
  default_tags {
    tags = {
      environment = var.environment
      project     = var.functionality
      owner       = "cloudops"
      client      = var.client
      area        = "infrastructure"
      provisioned = "terraform"
      datatype    = "operational"
    }
  }
}
```

### Configuración del Backend

Se recomienda configurar un backend remoto para el estado de Terraform:

```hcl
terraform {
  backend "s3" {
    bucket         = "tu-bucket-terraform-state"
    key            = "vpc/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Convenciones de Nomenclatura

Los recursos siguen el patrón estándar de nomenclatura:
```
{client}-{functionality}-{environment}-{resource_type}-{service}
```

**Ejemplos:**
- VPC: `transer-app-prod-vpc-web`
- Subnet: `transer-app-prod-subnet-web`
- Internet Gateway: `transer-app-prod-igw-public`
- NAT Gateway: `transer-app-prod-nat`

### Estrategia de Etiquetado

El módulo implementa un sistema de etiquetado en dos niveles:

1. **Etiquetas Transversales**: Aplicadas automáticamente a través de `default_tags` del proveedor AWS
2. **Etiquetas Específicas**: Definidas por recurso usando la propiedad `id_case` y `accessclass`

**Etiquetas automáticas aplicadas:**
- `Name`: Generado según convención de nomenclatura
- `id_case`: ID del ticket o caso de trabajo
- `accessclass`: Clasificación de acceso (public/private)

### Recursos Gestionados

| Recurso AWS | Descripción | Cantidad |
|-------------|-------------|----------|
| `aws_vpc` | VPC principal | 1 |
| `aws_subnet` | Subredes (públicas, privadas, BD) | Variable según configuración |
| `aws_internet_gateway` | Gateway de Internet | 0-1 (opcional) |
| `aws_nat_gateway` | Gateway NAT | Variable según configuración |
| `aws_eip` | IP elástica para NAT Gateway | Variable según NAT Gateways |
| `aws_route_table` | Tablas de enrutamiento | 1 por tipo de subred |
| `aws_route_table_association` | Asociaciones subnet-route table | 1 por subred |
| `aws_route` | Rutas de tráfico | Variable según gateways |

### Parámetros de Entrada

#### Variables Comunes

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client"></a> [client](#input_client) | Nombre del cliente | `string` | n/a | yes |
| <a name="input_functionality"></a> [functionality](#input_functionality) | Funcionalidad del recurso | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input_environment) | Ambiente (dev, test, prod) | `string` | n/a | yes |
| <a name="input_service"></a> [service](#input_service) | Nombre del servicio | `string` | n/a | yes |
| <a name="input_ticket"></a> [ticket](#input_ticket) | ID del ticket o caso | `string` | n/a | yes |

#### Variables de VPC

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_block"></a> [cidr_block](#input_cidr_block) | Bloque CIDR para la VPC | `string` | n/a | yes |
| <a name="input_instance_tenancy"></a> [instance_tenancy](#input_instance_tenancy) | Tenencia de instancias (default/dedicated) | `string` | `"default"` | no |
| <a name="input_enable_dns_support"></a> [enable_dns_support](#input_enable_dns_support) | Habilitar soporte DNS en la VPC | `bool` | `true` | no |
| <a name="input_enable_dns_hostnames"></a> [enable_dns_hostnames](#input_enable_dns_hostnames) | Habilitar hostnames DNS en la VPC | `bool` | `true` | no |

#### Variables de Subredes

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_public_cidr_blocks"></a> [public_cidr_blocks](#input_public_cidr_blocks) | Configuración de subredes públicas | `list(object)` | n/a | yes |
| <a name="input_private_cidr_blocks"></a> [private_cidr_blocks](#input_private_cidr_blocks) | Configuración de subredes privadas | `list(object)` | n/a | yes |
| <a name="input_rds_cidr_blocks"></a> [rds_cidr_blocks](#input_rds_cidr_blocks) | Configuración de subredes de base de datos | `list(object)` | n/a | yes |

#### Variables de Gateway

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_igw"></a> [create_igw](#input_create_igw) | Crear Internet Gateway (1=sí, 0=no) | `number` | n/a | yes |
| <a name="input_nat_config"></a> [nat_config](#input_nat_config) | Configuración de NAT Gateway | `list(object)` | `[]` | no |

### Estructura de Configuración

#### Objeto de Configuración de Subred

```hcl
{
  ticket            = string  # ID del ticket o caso de trabajo
  cidr_block        = string  # Bloque CIDR de la subred (ej: "10.0.1.0/24")
  availability_zone = string  # Zona de disponibilidad AWS (ej: "us-east-1a")
  service           = string  # Nombre del servicio (ej: "web", "app", "db")
  accessclass       = string  # Clasificación de acceso ("public" o "private")
}
```

#### Objeto de Configuración de NAT Gateway

```hcl
{
  subnet_id = string  # ID de la subred pública donde crear el NAT Gateway
}
```

### Valores de Salida

| Name | Description |
|------|-------------|
| <a name="output_vpc_id"></a> [vpc_id](#output_vpc_id) | ID de la VPC creada |
| <a name="output_subnet_public_info"></a> [subnet_public_info](#output_subnet_public_info) | Información completa de las subredes públicas |
| <a name="output_route_table_public_info"></a> [route_table_public_info](#output_route_table_public_info) | Información de las tablas de enrutamiento públicas |
| <a name="output_subnet_private_info"></a> [subnet_private_info](#output_subnet_private_info) | Información completa de las subredes privadas |
| <a name="output_route_table_private_info"></a> [route_table_private_info](#output_route_table_private_info) | Información de las tablas de enrutamiento privadas |
| <a name="output_subnet_rds_info"></a> [subnet_rds_info](#output_subnet_rds_info) | Información completa de las subredes de base de datos |
| <a name="output_route_table_rds_info"></a> [route_table_rds_info](#output_route_table_rds_info) | Información de las tablas de enrutamiento de BD |

### Ejemplos de Uso

#### Ejemplo Básico

```hcl
module "vpc" {
  source = "git::https://github.com/tu-org/transer-iac-tf-mod-vpc.git?ref=v1.0.0"

  # Variables comunes
  client        = "transer"
  functionality = "app"
  environment   = "prod"
  service       = "web"
  ticket        = "TICKET-123"

  # Configuración de VPC
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  # Subredes públicas
  public_cidr_blocks = [
    {
      ticket            = "TICKET-123"
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
      service           = "web"
      accessclass       = "public"
    },
    {
      ticket            = "TICKET-123"
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
      service           = "web"
      accessclass       = "public"
    }
  ]

  # Subredes privadas
  private_cidr_blocks = [
    {
      ticket            = "TICKET-123"
      cidr_block        = "10.0.10.0/24"
      availability_zone = "us-east-1a"
      service           = "app"
      accessclass       = "private"
    }
  ]

  # Subredes de base de datos
  rds_cidr_blocks = [
    {
      ticket            = "TICKET-123"
      cidr_block        = "10.0.20.0/24"
      availability_zone = "us-east-1a"
      service           = "db"
      accessclass       = "private"
    }
  ]

  # Internet Gateway
  create_igw = 1

  # NAT Gateway
  nat_config = [
    {
      subnet_id = module.vpc.subnet_public_info[0].id
    }
  ]
}
```

## Escenarios de Uso Comunes

### Escenario 1: Aplicación Web de 3 Capas

```hcl
module "vpc_three_tier" {
  source = "git::https://github.com/tu-org/transer-iac-tf-mod-vpc.git?ref=v1.0.0"

  client        = "transer"
  functionality = "webapp"
  environment   = "prod"
  service       = "ecommerce"
  ticket        = "WEBAPP-001"

  cidr_block = "10.1.0.0/16"

  # Capa de presentación (Load Balancers)
  public_cidr_blocks = [
    {
      ticket            = "WEBAPP-001"
      cidr_block        = "10.1.1.0/24"
      availability_zone = "us-east-1a"
      service           = "alb"
      accessclass       = "public"
    },
    {
      ticket            = "WEBAPP-001"
      cidr_block        = "10.1.2.0/24"
      availability_zone = "us-east-1b"
      service           = "alb"
      accessclass       = "public"
    }
  ]

  # Capa de aplicación (Servidores web/app)
  private_cidr_blocks = [
    {
      ticket            = "WEBAPP-001"
      cidr_block        = "10.1.10.0/24"
      availability_zone = "us-east-1a"
      service           = "app"
      accessclass       = "private"
    },
    {
      ticket            = "WEBAPP-001"
      cidr_block        = "10.1.11.0/24"
      availability_zone = "us-east-1b"
      service           = "app"
      accessclass       = "private"
    }
  ]

  # Capa de datos (Bases de datos)
  rds_cidr_blocks = [
    {
      ticket            = "WEBAPP-001"
      cidr_block        = "10.1.20.0/24"
      availability_zone = "us-east-1a"
      service           = "mysql"
      accessclass       = "private"
    },
    {
      ticket            = "WEBAPP-001"
      cidr_block        = "10.1.21.0/24"
      availability_zone = "us-east-1b"
      service           = "mysql"
      accessclass       = "private"
    }
  ]

  create_igw = 1
  nat_config = [
    {
      subnet_id = module.vpc_three_tier.subnet_public_info[0].id
    }
  ]
}
```

### Escenario 2: Entorno de Desarrollo Simplificado

```hcl
module "vpc_dev" {
  source = "git::https://github.com/tu-org/transer-iac-tf-mod-vpc.git?ref=v1.0.0"

  client        = "transer"
  functionality = "dev"
  environment   = "dev"
  service       = "testing"
  ticket        = "DEV-001"

  cidr_block = "10.2.0.0/16"

  # Solo una subred pública para desarrollo
  public_cidr_blocks = [
    {
      ticket            = "DEV-001"
      cidr_block        = "10.2.1.0/24"
      availability_zone = "us-east-1a"
      service           = "dev"
      accessclass       = "public"
    }
  ]

  # Subredes privadas mínimas
  private_cidr_blocks = [
    {
      ticket            = "DEV-001"
      cidr_block        = "10.2.10.0/24"
      availability_zone = "us-east-1a"
      service           = "app"
      accessclass       = "private"
    }
  ]

  # Base de datos de desarrollo
  rds_cidr_blocks = [
    {
      ticket            = "DEV-001"
      cidr_block        = "10.2.20.0/24"
      availability_zone = "us-east-1a"
      service           = "postgres"
      accessclass       = "private"
    }
  ]

  create_igw = 1
  # Sin NAT Gateway para reducir costos en desarrollo
  nat_config = []
}
```

## Consideraciones Operativas

### Rendimiento y Escalabilidad

- **Límites de VPC**: Una VPC puede tener hasta 200 subredes por región
- **Límites de CIDR**: Se pueden asociar hasta 5 bloques CIDR adicionales por VPC
- **NAT Gateway**: Soporta hasta 45 Gbps de ancho de banda
- **Zonas de Disponibilidad**: Se recomienda distribuir subredes en al menos 2 AZ para alta disponibilidad

### Limitaciones y Restricciones

- **CIDR Overlapping**: Los bloques CIDR no pueden superponerse entre VPCs que requieran comunicación
- **Tenancy**: El cambio de tenancy de "default" a "dedicated" requiere recrear la VPC
- **NAT Gateway**: Requiere una subred pública existente para su creación
- **Internet Gateway**: Solo se puede asociar un IGW por VPC

### Costos y Optimización

**Componentes con costo:**
- **NAT Gateway**: ~$45/mes por gateway + $0.045 por GB procesado
- **Elastic IP**: Gratis mientras esté asociada a un recurso en uso
- **VPC, Subredes, Route Tables**: Sin costo adicional

**Estrategias de optimización:**
- Usar un solo NAT Gateway para entornos de desarrollo
- Implementar múltiples NAT Gateways solo en producción para alta disponibilidad
- Considerar NAT Instances para cargas de trabajo con menor throughput

### Recomendaciones de Implementación

- **Planificación de CIDR**: Planifica cuidadosamente los bloques CIDR para evitar conflictos futuros
- **Zonas de Disponibilidad**: Distribuye recursos en múltiples AZ para alta disponibilidad
- **Monitoreo**: Implementa VPC Flow Logs para monitoreo y troubleshooting
- **Seguridad**: Usa Security Groups y NACLs para implementar defensa en profundidad

## Seguridad y Cumplimiento

### Consideraciones de Seguridad

- **Aislamiento de Red**: Las subredes de base de datos no tienen acceso directo a Internet
- **Principio de Menor Privilegio**: Cada capa tiene acceso solo a los recursos necesarios
- **Cifrado en Tránsito**: Todo el tráfico entre subredes permanece dentro de la red AWS
- **Logging**: Se recomienda habilitar VPC Flow Logs para auditoría

### Mejores Prácticas Implementadas

✅ **Separación de capas** mediante subredes dedicadas  
✅ **Validación de entrada** para bloques CIDR y configuraciones  
✅ **Etiquetado consistente** para trazabilidad y gestión  
✅ **Nomenclatura estandarizada** para identificación clara de recursos  
✅ **Configuración modular** para facilitar mantenimiento  
✅ **Documentación completa** de configuraciones y dependencias  

### Lista de Verificación de Cumplimiento

- [x] Nomenclatura de recursos conforme al estándar organizacional
- [x] Etiquetas obligatorias aplicadas a todos los recursos
- [x] Validaciones implementadas para garantizar configuraciones correctas
- [x] Separación adecuada entre capas de aplicación
- [x] Documentación completa de arquitectura y configuración
- [x] Soporte para múltiples zonas de disponibilidad
- [x] Configuración segura de enrutamiento de red
- [x] Implementación de principios de menor privilegio en conectividad

## Seguimiento de cambios

| Fecha        | Descripción                           | Versión | Construido por                   | Aprobador |
|--------------|---------------------------------------|---------|----------------------------------|----------|
| 2024/06/27   | Creación inicial del módulo VPC       | v1.0.0  | Andres Gonzalez                 | NA       |

## Observaciones

- **Dependencias de Orden**: El NAT Gateway debe crearse después de las subredes públicas
- **Recreación de Recursos**: Cambios en CIDR blocks requieren recrear subredes
- **Límites de AWS**: Verificar límites de servicio antes de implementar en cuentas con muchos recursos
- **Costos de NAT**: Considerar el impacto en costos al implementar múltiples NAT Gateways
- **Conectividad Híbrida**: Para conexiones on-premises, considerar implementar Virtual Private Gateway o Transit Gateway

> "Este módulo ha sido desarrollado siguiendo los estándares de Pragma CloudOps, garantizando una implementación segura, escalable y optimizada que cumple con todas las políticas de la organización. Pragma CloudOps recomienda revisar este código con su equipo de infraestructura antes de implementarlo en producción."
