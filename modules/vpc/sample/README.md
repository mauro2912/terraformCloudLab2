# Ejemplo de Implementación - Módulo VPC

Este directorio contiene un ejemplo completo de implementación del módulo `transer-iac-tf-mod-vpc` que demuestra cómo configurar una VPC con arquitectura de 3 capas para una aplicación web.

## Arquitectura del Ejemplo

La implementación de ejemplo crea:

- **VPC**: `10.0.0.0/16` con soporte DNS habilitado
- **Subredes Públicas**: 2 subredes en diferentes AZ para load balancers
- **Subredes Privadas**: 2 subredes en diferentes AZ para servidores de aplicación
- **Subredes de Base de Datos**: 2 subredes en diferentes AZ para RDS
- **Internet Gateway**: Para conectividad externa de subredes públicas
- **NAT Gateway**: Para acceso saliente de subredes privadas

## Estructura de Archivos

```
sample/
├── README.md                     # Esta documentación
├── main.tf                       # Configuración principal del ejemplo
├── variables.tf                  # Variables del ejemplo
├── outputs.tf                    # Salidas del ejemplo
├── providers.tf                  # Configuración de proveedores
└── terraform.auto.tfvars.sample  # Ejemplo de valores de variables
```

## Cómo Usar Este Ejemplo

### 1. Preparar el Entorno

```bash
# Clonar el repositorio y navegar al directorio de ejemplo
cd sample/

# Copiar el archivo de variables de ejemplo
cp terraform.auto.tfvars.sample terraform.auto.tfvars
```

### 2. Configurar Variables

Edita el archivo `terraform.auto.tfvars` con los valores específicos de tu entorno:

```hcl
# Configuración del cliente y proyecto
client        = "tu-cliente"
functionality = "webapp"
environment   = "dev"
service       = "ecommerce"
ticket        = "TICKET-001"

# Configuración de AWS
aws_region = "us-east-1"

# Configuración de red (opcional - usar valores por defecto)
# cidr_block = "10.0.0.0/16"
```

### 3. Desplegar la Infraestructura

```bash
# Inicializar Terraform
terraform init

# Revisar el plan de ejecución
terraform plan

# Aplicar los cambios
terraform apply
```

### 4. Verificar la Implementación

```bash
# Ver las salidas del módulo
terraform output

# Listar recursos creados
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*tu-cliente*"
```

### 5. Limpiar Recursos (Opcional)

```bash
# Destruir todos los recursos creados
terraform destroy
```

## Personalización

### Modificar Configuración de Red

Para personalizar la configuración de red, edita las variables en `terraform.auto.tfvars`:

```hcl
# Cambiar el bloque CIDR principal
cidr_block = "172.16.0.0/16"

# Personalizar subredes públicas
public_subnets = [
  {
    cidr_block        = "172.16.1.0/24"
    availability_zone = "us-east-1a"
    service           = "alb"
  },
  {
    cidr_block        = "172.16.2.0/24"
    availability_zone = "us-east-1b"
    service           = "alb"
  }
]
```

### Agregar Más Subredes

Para agregar subredes adicionales, modifica las listas correspondientes en `variables.tf` y `terraform.auto.tfvars`.

## Recursos Creados

Este ejemplo creará aproximadamente los siguientes recursos:

- 1 VPC
- 6 Subredes (2 públicas, 2 privadas, 2 de BD)
- 1 Internet Gateway
- 1 NAT Gateway
- 1 Elastic IP
- 3 Route Tables
- 6 Route Table Associations
- Múltiples Routes

## Costos Estimados

**Recursos con costo mensual aproximado:**
- NAT Gateway: ~$45/mes + tráfico
- Elastic IP: Gratis (mientras esté en uso)

**Total estimado**: ~$45-60/mes (sin incluir tráfico)

## Troubleshooting

### Error: "CIDR block conflicts"
- Verifica que los bloques CIDR no se superpongan
- Asegúrate de que el CIDR de la VPC sea suficientemente grande

### Error: "Availability zone not available"
- Verifica que las zonas de disponibilidad especificadas existan en tu región
- Usa `aws ec2 describe-availability-zones` para listar AZ disponibles

### Error: "Insufficient permissions"
- Verifica que tu usuario/rol de AWS tenga permisos para crear recursos VPC
- Revisa las políticas IAM asociadas

## Soporte

Para soporte adicional:
1. Revisa la documentación principal del módulo en `../README.md`
2. Consulta los logs de Terraform para errores específicos
3. Contacta al equipo de CloudOps para asistencia técnica
