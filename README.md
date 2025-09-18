# Урок 7: Кластер EKS та розгортання Django

Цей проєкт демонструє налаштування кластера Amazon EKS, повторне використання VPC та ECR з уроку 5, а також розгортання Django-додатку за допомогою Helm-чарту.

## Структура проєкту
- `main.tf`: Налаштовує провайдера та модулі (`s3-backend`, `vpc`, `ecr`, `eks`).
- `backend.tf`: Налаштовує S3-бекенд для зберігання стану Terraform.
- `outputs.tf`: Виводить ідентифікатори ресурсів та URL-адреси.
- `modules/s3-backend/`: Керує бакетом S3 та таблицею DynamoDB для стану Terraform.
- `modules/vpc/`: Повторно використовує VPC з уроку 5.
- `modules/ecr/`: Створює репозиторій ECR для образу Django.
- `modules/eks/`: Створює кластер EKS та групу вузлів.
- `charts/django-app/`: Helm-чарт для розгортання Django-додатку з Deployment, Service, ConfigMap та HPA.

## Передумови
- Встановлені інструменти: AWS CLI, Terraform, Helm, `kubectl`.
- Користувач IAM `terraform-user-1` з дозволами для S3, DynamoDB, VPC, EC2, ECR та EKS.
- Існуючий бакет S3 `lesson-5-terraform-state-bucket-1234` та таблиця DynamoDB `terraform-locks`.

## Інструкції з налаштування

1. **Застосування конфігурації Terraform**:
   ```bash
   terraform init
   terraform apply
   ```

2. **Завантаження образу Django в ECR**:
   ```bash
   aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-west-2.amazonaws.com
   docker tag my-django-app:latest <account-id>.dkr.ecr.us-west-2.amazonaws.com/lesson-7-django:latest
   docker push <account-id>.dkr.ecr.us-west-2.amazonaws.com/lesson-7-django:latest
   ```

3. **Налаштування kubectl**:
   ```bash
   aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks-cluster
   kubectl edit configmap aws-auth -n kube-system
   ```
   Додайте `terraform-user-1` до `mapUsers` з групою `system:masters`.

4. **Розгортання Helm-чарту**:
   ```bash
   cd charts
   helm install django-app ./django-app --set image.repository=<account-id>.dkr.ecr.us-west-2.amazonaws.com/lesson-7-django
   ```

5. **Доступ до додатку**:
   ```bash
   kubectl get svc
   ```
   Використовуйте зовнішню IP-адресу LoadBalancer для доступу до Django-додатку.

6. **Очищення**:
   ```bash
   helm uninstall django-app
   terraform destroy
   ```

## Модулі
- **s3-backend**: Керує зберіганням стану Terraform.
- **vpc**: Повторно використовує VPC з уроку 5 з публічними та приватними підмережами.
- **ecr**: Створює репозиторій ECR (`lesson-7-django`) для образу Django.
- **eks**: Створює кластер EKS з групою вузлів у існуючій VPC.