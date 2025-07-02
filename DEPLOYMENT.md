# 🚀 Pipeline de CI/CD para SisChampions2022 en AWS

Este documento describe cómo desplegar la aplicación Laravel SisChampions2022 en AWS usando un pipeline de CI/CD completo.

## 📋 Arquitectura del Pipeline

```
GitHub Repository
       ↓
GitHub Actions (CI/CD)
       ↓
AWS ECR (Container Registry)
       ↓
AWS ECS (Container Orchestration)
       ↓
AWS RDS (Database)
       ↓
AWS ALB (Load Balancer)
       ↓
Route 53 (DNS) + ACM (SSL)
```

## 🛠️ Servicios AWS Utilizados

- **ECS (Elastic Container Service)**: Orquestación de contenedores
- **ECR (Elastic Container Registry)**: Registro de imágenes Docker
- **RDS (Relational Database Service)**: Base de datos MySQL
- **ALB (Application Load Balancer)**: Balanceador de carga
- **Route 53**: Gestión de DNS
- **ACM (AWS Certificate Manager)**: Certificados SSL
- **CloudWatch**: Monitoreo y logs
- **Secrets Manager**: Gestión de secretos
- **S3**: Almacenamiento del estado de Terraform

## 📁 Estructura de Archivos

```
SisChampions2022/
├── .github/
│   └── workflows/
│       └── deploy.yml          # Pipeline de GitHub Actions
├── terraform/
│   ├── main.tf                 # Configuración principal de Terraform
│   └── variables.tf            # Variables de Terraform
├── docker/
│   └── supervisord.conf        # Configuración de Supervisor
├── scripts/
│   └── deploy.sh               # Script de despliegue manual
├── Dockerfile                  # Imagen Docker de la aplicación
├── task-definition.json        # Definición de tarea ECS
├── aws-config.sh              # Script de configuración AWS
└── DEPLOYMENT.md              # Este archivo
```

## 🚀 Pasos para el Despliegue

### 1. Prerrequisitos

- Cuenta de AWS con permisos de administrador
- AWS CLI instalado y configurado
- Docker instalado
- Terraform instalado
- Dominio registrado (opcional)

### 2. Configuración Inicial de AWS

```bash
# Ejecutar el script de configuración
chmod +x aws-config.sh
./aws-config.sh
```

Este script:
- Configura las credenciales de AWS
- Crea un bucket S3 para el estado de Terraform
- Crea un usuario IAM para GitHub Actions
- Genera un archivo con los secretos para GitHub

### 3. Configurar Secretos en GitHub

1. Ve a tu repositorio en GitHub
2. Ve a **Settings** > **Secrets and variables** > **Actions**
3. Agrega los siguientes secretos:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`

### 4. Configurar Terraform

```bash
cd terraform

# Inicializar Terraform
terraform init

# Revisar el plan
terraform plan

# Aplicar la configuración
terraform apply
```

### 5. Configurar el Dominio (Opcional)

Si tienes un dominio personalizado:

1. Actualiza la variable `domain_name` en `terraform/variables.tf`
2. Ejecuta `terraform apply` nuevamente
3. Configura los nameservers de tu dominio con los proporcionados por Route 53

### 6. Desplegar la Aplicación

El pipeline se ejecutará automáticamente cuando hagas push a la rama `main` o `master`.

Para despliegue manual:

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

## 🔧 Configuración de la Aplicación

### Variables de Entorno

La aplicación utiliza las siguientes variables de entorno:

```env
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:...
DB_CONNECTION=mysql
DB_HOST=sischampions2022-db.cluster-xyz.REGION.rds.amazonaws.com
DB_PORT=3306
DB_DATABASE=sischampions2022
DB_USERNAME=admin
DB_PASSWORD=...
JWT_SECRET=...
```

### Base de Datos

La base de datos se crea automáticamente con:
- **Motor**: MySQL 8.0
- **Instancia**: db.t3.micro (gratuita)
- **Almacenamiento**: 20GB con auto-scaling hasta 100GB
- **Backups**: Automáticos cada 7 días

### Escalabilidad

- **ECS Tasks**: 2 instancias por defecto
- **CPU**: 256 unidades (0.25 vCPU)
- **Memoria**: 512 MiB
- **Auto-scaling**: Configurado para escalar basado en CPU

## 📊 Monitoreo

### CloudWatch Logs

Los logs de la aplicación están disponibles en:
```
/ecs/sischampions2022
```

### Métricas

- **ECS**: CPU, memoria, número de tareas
- **RDS**: CPU, memoria, conexiones, I/O
- **ALB**: Requests, latencia, errores

### Alertas

Configura alertas en CloudWatch para:
- CPU > 80%
- Memoria > 80%
- Errores 5xx > 1%

## 🔒 Seguridad

### Red

- **VPC**: Red privada con subnets públicas y privadas
- **Security Groups**: Reglas de firewall específicas
- **ALB**: Solo puertos 80 y 443 abiertos
- **RDS**: Solo accesible desde ECS

### Secretos

- **APP_KEY**: Generado automáticamente
- **DB_PASSWORD**: Generado automáticamente
- **JWT_SECRET**: Generado automáticamente

### SSL/TLS

- **Certificado**: Automático con ACM
- **Redirección**: HTTP → HTTPS automática

## 🚨 Troubleshooting

### Problemas Comunes

1. **Error de permisos ECS**
   ```bash
   # Verificar roles IAM
   aws iam get-role --role-name ecsTaskExecutionRole
   ```

2. **Error de conexión a la base de datos**
   ```bash
   # Verificar security groups
   aws ec2 describe-security-groups --group-names sischampions2022-rds-*
   ```

3. **Error de health check**
   ```bash
   # Verificar logs de la aplicación
   aws logs describe-log-streams --log-group-name /ecs/sischampions2022
   ```

### Comandos Útiles

```bash
# Ver estado de ECS
aws ecs describe-services --cluster sischampions2022-cluster --services sischampions2022-service

# Ver logs de la aplicación
aws logs tail /ecs/sischampions2022 --follow

# Escalar el servicio
aws ecs update-service --cluster sischampions2022-cluster --service sischampions2022-service --desired-count 3

# Ver métricas de CloudWatch
aws cloudwatch get-metric-statistics --namespace AWS/ECS --metric-name CPUUtilization --dimensions Name=ClusterName,Value=sischampions2022-cluster
```

## 💰 Costos Estimados

### Servicios Gratuitos (12 meses)
- **ECR**: 500MB de almacenamiento
- **ECS**: 750 horas/mes de Fargate
- **RDS**: 750 horas/mes de db.t3.micro
- **ALB**: 750 horas/mes
- **Route 53**: 1 zona hospedada

### Servicios de Pago
- **CloudWatch**: ~$5-10/mes
- **Secrets Manager**: ~$0.40/mes
- **S3**: ~$0.50/mes

**Total estimado**: $5-15/mes después del período gratuito

## 🔄 Actualizaciones

### Despliegue Automático

1. Haz cambios en tu código
2. Haz commit y push a la rama `main`
3. GitHub Actions ejecutará automáticamente:
   - Tests
   - Build de la imagen Docker
   - Push a ECR
   - Despliegue a ECS

### Despliegue Manual

```bash
# Actualizar solo la aplicación
./scripts/deploy.sh

# Actualizar infraestructura
cd terraform
terraform apply
```

## 📞 Soporte

Para problemas o preguntas:
1. Revisa los logs en CloudWatch
2. Verifica el estado de los servicios en AWS Console
3. Consulta la documentación de AWS
4. Abre un issue en el repositorio

## 🎯 Próximos Pasos

- [ ] Configurar auto-scaling basado en métricas
- [ ] Implementar blue-green deployments
- [ ] Agregar monitoreo con Prometheus/Grafana
- [ ] Configurar backups automáticos de la base de datos
- [ ] Implementar CDN con CloudFront
- [ ] Agregar WAF para seguridad adicional 