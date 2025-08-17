# ITMO Ratings Secrets

На данный момент мы не разобрались, как автоматизировать работу с секретами. Поэтому необходимо вручную создать файл, применить его к кластеру и запустить cron.

Пример манифеста для секрета:

```yaml
apiVersion: v1
kind: Secret
metadata:
    name: itmo-ratings-secrets
    namespace: itmo-ratings
    annotations:
        argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
        argocd.argoproj.io/compare-options: IgnoreExtraneous
type: Opaque
stringData:
    telegram-api-token: "telegram-token"
    program-id: "program_id"
    student-id: "student_id"
    telegram-user-id: "telegram_iser_id"
```

### Шаги:
1. Создайте файл с указанным содержимым.
2. Примените его к кластеру с помощью команды:
     ```bash
     kubectl apply -f <имя_файла>
     ```
3. Запустите cron вручную.