# Ejemplo de implementación del módulo Security Group
# Este ejemplo demuestra cómo usar el módulo para crear security groups con diferentes configuraciones

module "security_groups" {
  source = "../"

  # Variables básicas del proyecto
  client        = var.client
  functionality = var.functionality
  environment   = var.environment

  # Configuración de Security Groups
  sg_config = var.sg_config
}
