# Урок 9: Вивчення Agro CD + CD

Цей проєкт реалізує повний CI/CD-пайплайн для Django-застосунку, розгорнутого на кластері Amazon EKS. Пайплайн використовує Terraform для створення інфраструктури, Jenkins для побудови та публікації Docker-образів у Amazon ECR, Helm для керування розгортаннями в Kubernetes та Argo CD для автоматичної синхронізації застосунку з Git-репозиторію.

## Структура проєкту

```
my-microservice-project/
│
├── main.tf                  # Основний файл Terraform для оркестрації модулів
├── backend.tf               # Налаштування бекенду для стану Terraform (S3 + DynamoDB)
├── outputs.tf               # Виведення ресурсів (VPC, EKS, ECR тощо)
│
├── modules/
│   ├── s3-backend/          # Модуль для S3-бакета та DynamoDB
│   ├── vpc/                 # VPC, підмережі та маршрутизація
│   ├── ecr/                 # Репозиторій Amazon ECR для Django-образу
│   ├── eks/                 # Кластер EKS та група вузлів
│   ├── jenkins/             # Встановлення Jenkins через Helm
│   ├── argo_cd/             # Встановлення Argo CD через Helm та Application
│
├── charts/
│   └── django-app/          # Helm-чарт для Django-застосунку
```

## Передумови

- **AWS CLI**: Налаштований з обліковими даними для користувача `terraform-user-1`.
- **Terraform**: Версія 1.5.0 або новіша.
- **Docker**: Встановлений і запущений (Docker Desktop на macOS).
- **kubectl**: Для взаємодії з кластером EKS.
- **Helm**: Для керування Helm-чартами.
- **Git**: Для роботи з репозиторіями.
- **Jenkins**: Встановлюється через Helm (налаштовано в `modules/jenkins`).
- **Argo CD**: Встановлюється через Helm (налаштовано в `modules/argo_cd`).

## Інструкції з налаштування

### 1. Ініціалізація та застосування Terraform
1. **Перейдіть до директорії проєкту**:


2. **Ініціалізуйте Terraform**:
   ```bash
   terraform init
   ```

3. **Застосуйте конфігурацію Terraform**:
   ```bash
   terraform apply
   ```
   - Це створює:
     - S3-бакет (`lesson-5-terraform-state-bucket-anatolii`) та таблицю DynamoDB (`terraform-locks`) для керування станом.
     - VPC з публічними та приватними підмережами.
     - Репозиторій ECR (`lesson-7-django`).
     - Кластер EKS (`lesson-7-eks-cluster`) та групу вузлів.
     - Jenkins та Argo CD через Helm-релізи.

4. **Перевірте виведення**:
   ```bash
   terraform output ecr_repository_url
   terraform output eks_cluster_name
   terraform output jenkins_url
   terraform output argo_cd_url
   ```

### 2. Побудова та публікація Docker-образу Django
1. **Побудуйте образ**:
   ```bash
   cd my-django-project
   docker build -t my-django-app:latest .
   ```

2. **Позначте та відправте до ECR**:
   ```bash
   docker tag my-django-app:latest 471754640546.dkr.ecr.us-west-2.amazonaws.com/lesson-7-django:latest
   aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 471754640546.dkr.ecr.us-west-2.amazonaws.com
   docker push 471754640546.dkr.ecr.us-west-2.amazonaws.com/lesson-7-django:latest
   ```

3. **Перевірте образ у ECR**:
   ```bash
   aws ecr describe-images --repository-name lesson-7-django --region us-west-2
   ```

### 3. Налаштування Jenkins-пайплайну
1. **Доступ до Jenkins**:
   - Отримайте URL та пароль адміністратора:
     ```bash
     terraform output jenkins_url
     terraform output jenkins_admin_password
     ```
   - Для локального доступу використовуйте port-forward:
     ```bash
     kubectl port-forward svc/jenkins -n jenkins 8080:8080
     ```
   - Увійдіть за адресою `http://localhost:8080` з логіном `admin` та паролем.

2. **Налаштуйте облікові дані ECR**:
   ```bash
   kubectl create secret docker-registry regcred \
     --docker-server=471754640546.dkr.ecr.us-west-2.amazonaws.com \
     --docker-username=AWS \
     --docker-password=$(aws ecr get-login-password --region us-west-2) \
     -n jenkins
   ```

3. **Налаштуйте облікові дані Git**:
   - У Jenkins перейдіть до **Manage Jenkins** > **Manage Credentials** > **Add Credentials**.
   - Додайте облікові дані типу `Username with Password` для вашого GitHub-репозиторію (ID: `git-credentials`).

4. **Створіть пайплайн**:
   - Створіть новий пайплайн у Jenkins.
   - Вкажіть репозиторій вашого Django-проєкту (наприклад, `https://github.com/your-repo/my-django-project.git`) та вкажіть `Jenkinsfile`.

### 4. Налаштування Argo CD
1. **Доступ до Argo CD**:
   - Отримайте URL та пароль адміністратора:
     ```bash
     terraform output argo_cd_url
     kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
     ```
   - Для локального доступу:
     ```bash
     kubectl port-forward svc/argo-cd-argocd-server -n argocd 8080:443
     ```
   - Увійдіть за адресою `https://localhost:8080` з логіном `admin` та паролем.

2. **Перевірте Application**:
   ```bash
   kubectl -n argocd get applications
   ```
   - Переконайтеся, що застосунок `django-app` синхронізований і має статус Healthy.

### 5. Розгортання Django-застосунку
1. **Оновіть Helm-чарт**:
   - Переконайтеся, що `lesson-7/charts/django-app/values.yaml` посилається на образ ECR:
     ```yaml
     image:
       repository: "471754640546.dkr.ecr.us-west-2.amazonaws.com/lesson-7-django"
       tag: "latest"
       pullPolicy: IfNotPresent
     ```

2. **Розгорніть через Helm** (за потреби вручну):
   ```bash
   cd lesson-7/charts
   helm install django-app ./django-app
   ```

3. **Перевірте розгортання**:
   ```bash
   kubectl -n default get pods
   kubectl -n default get svc
   ```
   - Отримайте URL LoadBalancer:
     ```bash
     kubectl -n default get svc django-app -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
     ```
   - Відкрийте Django-застосунок за адресою `http://<loadbalancer-url>`.

### 6. Робота CI/CD-пайплайну
1. **Jenkins-пайплайн**:
   - `Jenkinsfile` у репозиторії `my-django-project`:
     - Будує Docker-образ із тегом (наприклад, `BUILD_NUMBER`).
     - Відправляє його до `471754640546.dkr.ecr.us-west-2.amazonaws.com/lesson-7-django:BUILD_NUMBER`.
     - Оновлює `values.yaml` у репозиторії Helm-чарту (`https://github.com/SerAnatolii/my-microservice-project/tree/main/charts`).
     - Пушить зміни до гілки `main`.

2. **Синхронізація Argo CD**:
   - Argo CD відстежує `https://github.com/SerAnatolii/my-microservice-project/tree/main/charts`.
   - Автоматично синхронізує Helm-чарт `django-app` після оновлення `values.yaml`.
   - Перевірте розгортання в кластері EKS.

