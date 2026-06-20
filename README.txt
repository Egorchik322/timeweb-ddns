Timeweb DDNS

Docker service for automatic update of A record vpn.eegoo.ru via Timeweb Cloud API.

What it does:
- Detects current public IPv4 address.
- Reads DNS records from Timeweb Cloud API.
- Updates A record for vpn.eegoo.ru if public IP changed.
- Runs in Docker Compose.
- Keeps state in ./state/current-ip.

Domain settings:
DOMAIN=eegoo.ru
SUBDOMAIN=vpn
FQDN=vpn.eegoo.ru
TTL=600
INTERVAL=300

Files:
Dockerfile
docker-compose.yml
timeweb-ddns.sh
.env.example
.gitignore
README.txt

Local secret file:
.env

The .env file is not stored in git because it contains Timeweb API token.

Example .env:

TIMEWEB_CLOUD_TOKEN=PASTE_TIMEWEB_CLOUD_API_TOKEN_HERE
DOMAIN=eegoo.ru
SUBDOMAIN=vpn
TTL=600
INTERVAL=300

Start service:

docker compose up -d --build

Show logs:

docker logs --tail=50 timeweb-ddns
docker logs -f timeweb-ddns

Check DNS:

dig +short A vpn.eegoo.ru @ns1.timeweb.ru
dig +short A vpn.eegoo.ru @1.1.1.1
dig +short A vpn.eegoo.ru @8.8.8.8

Update after changes:

docker compose up -d --build

Check that .env is ignored by git:

git check-ignore -v .env

Current deployment location on docker01:

/opt/docker/timeweb-ddns
