# Timeweb DDNS

Docker service for automatic DNS A-record updates via Timeweb Cloud API.

This service is useful for a home server with a dynamic public IP address. It periodically detects the current public IPv4 address and updates the configured DNS record if the IP has changed.

## Features

- Detects current public IPv4 address.
- Reads DNS records from Timeweb Cloud API.
- Updates configured A-record.
- Runs with Docker Compose.
- Restarts automatically with restart policy.

## DNS Logic

The target FQDN is built from environment variables:

FQDN = SUBDOMAIN.DOMAIN

Example:

DOMAIN=example.com
SUBDOMAIN=vpn
FQDN=vpn.example.com

DNS record type:

A

## Files

Dockerfile
docker-compose.yml
timeweb-ddns.sh
.env.example
.gitignore
README.md

## Configuration

Create .env file in the same directory as docker-compose.yml.

Example .env:

TIMEWEB_CLOUD_TOKEN=PASTE_TIMEWEB_CLOUD_API_TOKEN_HERE
DOMAIN=example.com
SUBDOMAIN=vpn
TTL=600
INTERVAL=300

Variables:

TIMEWEB_CLOUD_TOKEN - Timeweb Cloud API token.
DOMAIN - Base domain.
SUBDOMAIN - Subdomain for DDNS.
TTL - DNS record TTL in seconds.
INTERVAL - Public IP check interval in seconds.

## Start

docker compose up -d --build

## Logs

Show last log lines:

docker logs --tail=50 timeweb-ddns

Follow logs:

docker logs -f timeweb-ddns

Normal log example:

2026-06-20T18:50:00+00:00 IP unchanged: vpn.example.com -> 203.0.113.10

## DNS Check

Check via Timeweb nameserver:

dig +short A "vpn.example.com" @ns1.timeweb.ru

Check via public resolvers:

dig +short A "vpn.example.com" @1.1.1.1
dig +short A "vpn.example.com" @8.8.8.8
dig +short A "vpn.example.com" @77.88.8.8

Expected result:

Current public IPv4 address of your server.

## Update After Changes

docker compose up -d --build

## Security

The .env file contains API token and must not be committed to git.

Check that .env is ignored:

git check-ignore -v .env

Check tracked files:

git ls-files

The tracked files list must not contain:

.env
state/current-ip

## Deployment Path Example

/opt/docker/timeweb-ddns

## License

Personal infrastructure project.
