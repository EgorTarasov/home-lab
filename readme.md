# Домашняя лаборатория

Этот репозиторий содержит настройки моей домашней лаборатории, которые можно воспроизвести с помощью предоставленных конфигураций и скриптов.
Включает следующие сервисы и приложения:
- **k3s**: Легковесный Kubernetes-кластер
- **cert-manager**: Автоматическое управление SSL-сертификатами через Let's Encrypt и Cloudflare DNS
- **Rancher**: Веб-интерфейс для управления Kubernetes
- **Cloudflare**: Управление DNS и проверка SSL-сертификатов
- **Pi-hole**: DNS-резолвер для локальной сети (планируется)
- **WireGuard**: VPN-сервер для безопасного удаленного доступа (планируется)
- **Стек мониторинга**: Prometheus и Grafana (планируется)
- **Terraform**: Код инфраструктуры для развертывания Argo CD и настройки провайдеров

## Текущая конфигурация
- **home-lab-node-1** (192.168.1.51) — узел управления k3s
  - Роль: control-plane
  - CPU: 16 ядер
  - Сеть: Flannel CNI (VXLAN)
  - Сервисы: k3s server, cert-manager, Rancher

## Конфигурация Terraform
Конфигурационные файлы находятся в каталоге `terraform/`:
- `0-provider.tf` — настройка провайдеров Terraform (Cloudflare, Kubernetes и т.д.)
- `1-argocd.tf` — развертывание Argo CD в k3s-кластере

Применение конфигурации:
```bash
cd terraform
terraform init
terraform apply
```

## Службы и компоненты

### 🔐 Управление SSL-сертификатами
- **cert-manager**: автоматическое получение сертификатов Let's Encrypt
- **DNS-01 Challenge**: проверка через Cloudflare API
- **Домены**: `*.k3s.larek.tech`
- **ClusterIssuer**: `cloudflare-clusterissuer`

### 🎛️ Управление кластером
- **Rancher UI**: веб-интерфейс Kubernetes
  - URL: `https://rancher.k3s.larek.tech`
  - SSL: из cert-manager
  - Пароль по умолчанию: admin

### 🌐 Сеть
- **Внутренняя сеть**: 192.168.1.0/24
- **Pod CIDR**: 10.42.0.0/24
- **Внешний домен**: `larek.tech` управляется Cloudflare
- **Поддомен K3s**: `*.k3s.larek.tech` для сервисов кластера

## Управление безопасностью и секретами

### Что безопасно коммитить:
- ✅ Локальные IP-адреса (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
- ✅ Внутренние DNS-имена и топология сети
- ✅ Шаблоны конфигураций (.env.example файлы)
- ✅ Номера портов для внутренних сервисов

### Что НИКОГДА не следует коммитить:
- ❌ API токены и ключи (Cloudflare, GitHub и т.д.)
- ❌ Публичные IP-адреса
- ❌ Пароли и учетные данные аутентификации
- ❌ SSL-сертификаты и закрытые ключи
- ❌ MAC-адреса (могут использоваться для отслеживания)

### Управление секретами:
- Используйте `.env.example` файлы в качестве шаблонов
- Храните реальные секреты в GitHub Secrets для CI/CD
- Используйте Kubernetes Secrets для конфигурации во время выполнения
- Рассмотрите возможность использования External Secrets Operator для продакшена


## Структура репозитория
```
├── clusters/                         # Конфигурации кластера k3s (gitignored)
│   ├── kubeconfig.yaml         # Конфигурация кластера K3s (gitignored)
│   └── .gitignore
├── configs/                          # Документация и шаблоны конфигураций
│   ├── network.md                        # Документация по сетевой конфигурации
│   ├── pi-hole/                          # Конфигурации Pi-hole (планируется)
│   └── wireguard/                        # Конфигурации WireGuard VPN (планируется)
├── environments/                     # Конфигурации окружений (dev, prod)
│   ├── dev/                               # Конфигурации для разработки
│   └── production/                         # Конфигурации для продакшена
├── k3s/                              # Скрипты и манифесты для k3s
│   ├── cluster-config/
│   │   ├── cert-manager/
│   │   │   ├── clusterissuer.yaml        # Cloudflare ClusterIssuer для Let's Encrypt
│   │   │   └── secret-cloudflare.yaml    # Секрет с токеном Cloudflare
│   │   └── rancher/
│   │       ├── certificate.yaml          # SSL-сертификат для Rancher UI
│   │       └── ui.sh                     # Скрипт установки Rancher
│   ├── ingress/                          # Конфигурации Ingress (планируется)
│   └── monitoring/                       # Стек мониторинга (планируется)
├── scripts/                          # Скрипты установки узлов
│   ├── master.sh                         # Скрипт настройки главного узла K3s
│   └── worker.sh                         # Скрипт настройки рабочего узла K3s
├── terraform/                        # Конфигурация Terraform
│   ├── 0-provider.tf
│   └── 1-argocd.tf
└── readme.md                         # Этот файл
```

## Быстрый старт

### 1. Настройка кластера k3s
```bash
# На главном узле
./scripts/master.sh

# На рабочих узлах (сначала установите переменные окружения)
export K3S_URL="https://192.168.1.51:6443"
export K3S_TOKEN="<токен-узла-с-главного>"
./scripts/worker.sh
```

### 2. Установка cert-manager
```bash
# Добавить репозиторий Jetstack
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Установить cert-manager
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.18.2 \
  --set crds.enabled=true

# Применить секрет Cloudflare (обновите своим токеном API)
kubectl apply -f k3s/cluster-config/cert-manager/secret-cloudflare.yaml

# Применить ClusterIssuer
kubectl apply -f k3s/cluster-config/cert-manager/clusterissuer.yaml
```

### 3. Установка Rancher UI
```bash
# Создать пространство имен
kubectl create namespace cattle-system

# Применить SSL-сертификат
kubectl apply -f k3s/cluster-config/rancher/certificate.yaml

# Установить Rancher
chmod +x k3s/cluster-config/rancher/ui.sh
./k3s/cluster-config/rancher/ui.sh
```

## Настройка DNS
Настройте следующие DNS-записи в Cloudflare:
```
Тип: A
Имя: *.k3s.larek.tech
Содержимое: <ваш-внешний-ip>
Прокси: Только DNS
```

## Отладка

### Распространенные проблемы
- **Сертификат не выдаётся**: проверьте DNS-запись `dig TXT _acme-challenge.rancher.k3s.larek.tech`
- **Rancher UI недоступен**: `kubectl get certificate -n cattle-system`
- **Проблемы с DNS**: убедитесь, что `*.k3s.larek.tech` указывает на ваш внешний IP

### Полезные команды
```bash
# Проверить статус кластера
kubectl get nodes -o wide

# Проверить статус cert-manager
kubectl get clusterissuer
kubectl get certificate -A

# Проверить развертывание Rancher
kubectl get pods -n cattle-system

# Просмотреть логи cert-manager
kubectl logs -n cert-manager deployment/cert-manager -f
```