# Timeweb DDNS

Docker-сервис для автоматического обновления DNS A-записи `vpn.eegoo.ru` через Timeweb Cloud API.

Сервис полезен для домашнего сервера с динамическим публичным IP: он периодически проверяет текущий внешний IPv4 и обновляет DNS-запись, если IP изменился.

## Что Делает

- Определяет текущий публичный IPv4.
- Получает DNS-записи через Timeweb Cloud API.
- Обновляет A-запись для `vpn.eegoo.ru`.
- Работает в Docker Compose.
- Автоматически перезапускается через `restart: unless-stopped`.

## DNS-Схема

| Параметр | Значение |
|---|---|
| Домен | `eegoo.ru` |
| Поддомен | `vpn` |
| FQDN | `vpn.eegoo.ru` |
| Тип записи | `A` |
| TTL | `600` |
| Интервал проверки | `300` секунд |

## Файлы

| Файл | Назначение |
|---|---|
| `Dockerfile` | Образ на базе Alpine с `bash`, `curl`, `jq` |
| `docker-compose.yml` | Описание Docker Compose сервиса |
| `timeweb-ddns.sh` | Основной DDNS-скрипт |
| `.env.example` | Пример переменных окружения |
| `.gitignore` | Исключает секреты и runtime state |
| `README.md` | Документация проекта |

## Настройка

Создайте файл `.env` рядом с `docker-compose.yml`:

```env
TIMEWEB_CLOUD_TOKEN=PASTE_TIMEWEB_CLOUD_API_TOKEN_HERE
DOMAIN=eegoo.ru
SUBDOMAIN=vpn
TTL=600
INTERVAL=300
```

Описание переменных:

| Переменная | Описание |
|---|---|
| `TIMEWEB_CLOUD_TOKEN` | API-токен Timeweb Cloud |
| `DOMAIN` | Основной домен |
| `SUBDOMAIN` | Поддомен для DDNS |
| `TTL` | TTL DNS-записи в секундах |
| `INTERVAL` | Интервал проверки IP в секундах |

## Запуск

```bash
docker compose up -d --build
```

## Просмотр Логов

Последние строки:

```bash
docker logs --tail=50 timeweb-ddns
```

Логи в реальном времени:

```bash
docker logs -f timeweb-ddns
```

Пример нормального лога:

```text
2026-06-20T18:50:00+00:00 IP unchanged: vpn.eegoo.ru -> 89.109.48.106
```

## Проверка DNS

Проверка через NS Timeweb:

```bash
dig +short A vpn.eegoo.ru @ns1.timeweb.ru
```

Проверка через публичные DNS:

```bash
dig +short A vpn.eegoo.ru @1.1.1.1
dig +short A vpn.eegoo.ru @8.8.8.8
dig +short A vpn.eegoo.ru @77.88.8.8
```

Ожидаемый результат:

```text
89.109.48.106
```

## Обновление После Изменений

```bash
docker compose up -d --build
```

## Безопасность

Файл `.env` содержит API-токен и не должен попадать в git.

Проверить, что `.env` игнорируется:

```bash
git check-ignore -v .env
```

Проверить, какие файлы попадут в репозиторий:

```bash
git ls-files
```

В списке не должно быть:

```text
.env
state/current-ip
```

## Размещение

Текущий путь на сервере:

```text
/opt/docker/timeweb-ddns
```

## Лицензия

Проект используется для личной домашней инфраструктуры.
