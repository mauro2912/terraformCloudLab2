# Ejemplo de implementación del módulo transer-iac-tf-mod-security-group

Este ejemplo demuestra cómo usar el módulo Security Group para crear grupos de seguridad de VPC con diferentes configuraciones, incluyendo arquitecturas de múltiples capas, referencias entre security groups y reglas de acceso granulares.

## Estructura de archivos

```
sample/
├── README.md                         # Este archivo de documentación
├── main.tf                           # Configuración principal del ejemplo
├── variables.tf                      # Variables del ejemplo con valores por defecto
├── outputs.tf                        # Salidas del ejemplo
├── providers.tf                      # Configuración de proveedores
└── terraform.auto.tfvars.sample      # Ejemplo de variables para personalizar
```

## Requisitos previos

Antes de ejecutar este ejemplo, asegúrate de tener:

- **Terraform >= 1.0.0** instalado
- **AWS CLI configurado** con credenciales válidas
- **Permisos IAM necesarios** para crear recursos de VPC:
  - `ec2:CreateSecurityGroup`
  - `ec2:DeleteSecurityGroup`
  - `ec2:DescribeSecurityGroups`
  - `ec2:AuthorizeSecurityGroupIngress`
  - `ec2:AuthorizeSecurityGroupEgress`
  - `ec2:RevokeSecurityGroupIngress`
  - `ec2:RevokeSecurityGroupEgress`
  - `ec2:CreateTags`
- **VPC existente** donde crear los security groups
- **Conocimiento de la arquitectura** de red de tu aplicación

## Cómo usar este ejemplo

### 1. Preparación de variables

Copia el archivo de ejemplo de variables:

```bash
cp terraform.auto.tfvars.sample terraform.auto.tfvars
```

Edita `terraform.auto.tfvars` según tus necesidades:

```hcl
# Personaliza estos valores
client        = "tu-cliente"
functionality = "tu-proyecto"
environment   = "dev"  # o "qa", "pdn"

# IMPORTANTE: Actualiza el VPC ID con tu VPC real
sg_config = {
  "web-servers" = {
    vpc_id = "vpc-tu-vpc-id-real"  # Reemplaza con tu VPC ID
    # ... resto de configuración
  }
}
```

### 2. Inicialización de Terraform

```bash
terraform init
```

### 3. Verificación del plan

```bash
terraform plan
```

Revisa cuidadosamente el plan para asegurar que los recursos a crear son los esperados.

### 4. Aplicación de la configuración

```bash
terraform apply
```

Confirma con `yes` cuando se solicite.

### 5. Verificación de recursos creados

```bash
# Listar security groups creados
aws ec2 describe-security-groups --filters "Name=tag:ManagedBy,Values=terraform"

# Obtener detalles de un security group específico
aws ec2 describe-security-groups --group-ids <security-group-id>

# Verificar reglas de un security group
aws ec2 describe-security-groups --group-ids <security-group-id> --query 'SecurityGroups[0].IpPermissions'
```

## Escenarios incluidos

### Escenario 1: Arquitectura de 3 capas (Web-App-DB)

```hcl
{
  "web-servers" = {
    description = "Web tier - public access"
    accessclass = "public"
    ingress = [
      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }
  
  "app-servers" = {
    description = "Application tier - private access"
    accessclass = "private"
    ingress = [
      { from_port = 8080, to_port = 8080, protocol = "tcp", security_groups = ["sg-web"] }
    ]
  }
  
  "db-servers" = {
    description = "Database tier - restricted access"
    accessclass = "restricted"
    ingress = [
      { from_port = 5432, to_port = 5432, protocol = "tcp", security_groups = ["sg-app"] }
    ]
  }
}
```

**Flujo de trabajo:**
1. Los usuarios acceden a los servidores web desde internet (puertos 80/443)
2. Los servidores web se comunican con los servidores de aplicación (puerto 8080)
3. Los servidores de aplicación acceden a la base de datos (puerto 5432)
4. Cada capa solo permite acceso desde la capa anterior

### Escenario 2: Load Balancer con servidores backend

```hcl
{
  "load-balancer" = {
    description = "Application Load Balancer"
    accessclass = "public"
    ingress = [
      { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] }
    ]
    egress = [
      { from_port = 8080, to_port = 8080, protocol = "tcp", cidr_blocks = ["10.0.0.0/8"] }
    ]
  }
}
```

**Flujo de trabajo:**
1. El load balancer recibe tráfico HTTP/HTTPS desde internet
2. Distribuye el tráfico a los servidores backend en puerto 8080
3. Solo permite comunicación hacia la red privada

### Escenario 3: Acceso administrativo controlado

```hcl
{
  "bastion-host" = {
    description = "Bastion host for administrative access"
    accessclass = "restricted"
    ingress = [
      { from_port = 22, to_port = 22, protocol = "tcp", cidr_blocks = ["203.0.113.0/24"] }
    ]
  }
}
```

**Flujo de trabajo:**
1. Solo permite acceso SSH desde IPs específicas de administración
2. Actúa como punto de entrada seguro para administración
3. Otros recursos permiten SSH solo desde este bastion

## Flujos de trabajo recomendados

### Desarrollo y Testing

```bash
# 1. Crear entorno de desarrollo
terraform workspace new dev
terraform apply -var="environment=dev"

# 2. Probar conectividad entre security groups
aws ec2 describe-security-groups --group-ids <sg-id> --query 'SecurityGroups[0].IpPermissions'

# 3. Verificar reglas con herramientas de red
telnet <target-ip> <port>
nc -zv <target-ip> <port>
```

### Promoción a Producción

```bash
# 1. Crear workspace de producción
terraform workspace new pdn
terraform apply -var="environment=pdn" -var="client=production-client"

# 2. Configurar monitoreo de security groups
aws logs create-log-group --log-group-name "/aws/vpc/flowlogs"

# 3. Habilitar VPC Flow Logs
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids <vpc-id> \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name "/aws/vpc/flowlogs"
```

## Integración con otros servicios AWS

### Integración con EC2

```bash
# Lanzar instancia EC2 con security group
aws ec2 run-instances \
  --image-id ami-12345678 \
  --instance-type t3.micro \
  --security-group-ids <security-group-id> \
  --subnet-id <subnet-id>
```

### Integración con RDS

```hcl
resource "aws_db_instance" "database" {
  # ... otras configuraciones
  vpc_security_group_ids = [module.security_groups.sg_info["db-servers"].sg_id]
}
```

### Integración con Application Load Balancer

```hcl
resource "aws_lb" "app_lb" {
  # ... otras configuraciones
  security_groups = [module.security_groups.sg_info["load-balancer"].sg_id]
}
```

## Solución de problemas comunes

### Error: "InvalidGroup.NotFound"

**Causa:** El security group referenciado no existe o fue eliminado.

**Solución:**
```bash
# Verificar que el security group existe
aws ec2 describe-security-groups --group-ids <sg-id>

# Recrear el security group si es necesario
terraform apply -replace="module.security_groups.aws_security_group.sg[\"key-name\"]"
```

### Error: "InvalidVpcID.NotFound"

**Causa:** El VPC ID especificado no existe o no es accesible.

**Solución:**
```bash
# Verificar VPCs disponibles
aws ec2 describe-vpcs

# Actualizar terraform.auto.tfvars con VPC ID correcto
vpc_id = "vpc-correct-id"
```

### Error: "RulesPerSecurityGroupLimitExceeded"

**Causa:** Se excedió el límite de reglas por security group (50 reglas por defecto).

**Solución:**
1. Consolidar reglas similares usando rangos de puertos
2. Dividir en múltiples security groups
3. Solicitar aumento de límite a AWS Support

### Conectividad no funciona después de aplicar

**Causa:** Las reglas pueden estar mal configuradas o falta una regla de egress.

**Solución:**
```bash
# Verificar reglas de ingress y egress
aws ec2 describe-security-groups --group-ids <sg-id>

# Probar conectividad
telnet <target-ip> <port>

# Revisar VPC Flow Logs para tráfico bloqueado
aws logs filter-log-events \
  --log-group-name "/aws/vpc/flowlogs" \
  --filter-pattern "REJECT"
```

## Limpieza

Para eliminar todos los recursos creados:

```bash
# 1. Eliminar recursos de Terraform
terraform destroy

# 2. Verificar que no queden security groups huérfanos
aws ec2 describe-security-groups --filters "Name=tag:ManagedBy,Values=terraform"

# 3. Limpiar workspace (opcional)
terraform workspace select default
terraform workspace delete dev
```

### Consideraciones especiales para la limpieza

- **Dependencias**: Los security groups no se pueden eliminar si están en uso por otros recursos
- **Referencias cruzadas**: Eliminar primero los recursos que referencian los security groups
- **Default security group**: El security group por defecto de la VPC no se puede eliminar

### Verificación post-limpieza

```bash
# Confirmar que no existen security groups relacionados
aws ec2 describe-security-groups \
  --filters "Name=tag:Project,Values=transer" \
  --query 'SecurityGroups[?GroupName!=`default`]'

# Verificar logs de VPC Flow si están habilitados
aws logs describe-log-groups --log-group-name-prefix "/aws/vpc/"
```

## Mejores prácticas implementadas

- **Principio de menor privilegio**: Solo se abren los puertos necesarios
- **Separación por capas**: Cada tier tiene su propio security group
- **Documentación de reglas**: Cada regla tiene una descripción clara
- **Referencias entre SGs**: Se prefieren referencias sobre CIDR blocks cuando es posible
- **Etiquetado consistente**: Todos los recursos están etiquetados apropiadamente
