#!/usr/bin/env bash
set -euo pipefail

: "${TIMEWEB_CLOUD_TOKEN:?TIMEWEB_CLOUD_TOKEN is required}"
: "${DOMAIN:?DOMAIN is required}"
: "${SUBDOMAIN:?SUBDOMAIN is required}"

TTL="${TTL:-600}"
INTERVAL="${INTERVAL:-300}"
API="https://api.timeweb.cloud/api/v1"
FQDN="${SUBDOMAIN}.${DOMAIN}"
STATE_FILE="/state/current-ip"

mkdir -p /state

get_public_ipv4() {
  for url in \
    "https://api.ipify.org" \
    "https://ipv4.icanhazip.com" \
    "https://checkip.amazonaws.com"
  do
    ip="$(curl -4fsS --max-time 10 "$url" | tr -d '[:space:]' || true)"
    if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
      printf '%s\n' "$ip"
      return 0
    fi
  done

  return 1
}

update_dns() {
  current_ip="$(get_public_ipv4)"

  records_json="$(
    curl -fsS \
      -H "Authorization: Bearer ${TIMEWEB_CLOUD_TOKEN}" \
      -H "Accept: application/json" \
      "${API}/domains/${FQDN}/dns-records?limit=100&offset=0"
  )"

  record_id="$(
    jq -r '
      (.dns_records // [])
      | map(select(.type == "A"))
      | .[0].id // empty
    ' <<<"$records_json"
  )"

  old_ip="$(
    jq -r '
      (.dns_records // [])
      | map(select(.type == "A"))
      | .[0].data.value // empty
    ' <<<"$records_json"
  )"

  if [[ "$old_ip" == "$current_ip" ]]; then
    echo "$(date -Is) IP unchanged: ${FQDN} -> ${current_ip}"
    printf '%s\n' "$current_ip" >"$STATE_FILE"
    return 0
  fi

  payload="$(
    jq -cn \
      --arg ip "$current_ip" \
      --argjson ttl "$TTL" \
      '{type:"A",value:$ip,ttl:$ttl}'
  )"

  if [[ -n "$record_id" ]]; then
    curl -fsS -X PATCH \
      -H "Authorization: Bearer ${TIMEWEB_CLOUD_TOKEN}" \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      -d "$payload" \
      "${API}/domains/${FQDN}/dns-records/${record_id}" >/dev/null

    echo "$(date -Is) Updated ${FQDN}: ${old_ip:-none} -> ${current_ip}"
  else
    curl -fsS -X POST \
      -H "Authorization: Bearer ${TIMEWEB_CLOUD_TOKEN}" \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      -d "$payload" \
      "${API}/domains/${FQDN}/dns-records" >/dev/null

    echo "$(date -Is) Created ${FQDN} -> ${current_ip}"
  fi

  printf '%s\n' "$current_ip" >"$STATE_FILE"
}

while true; do
  update_dns || echo "$(date -Is) DDNS update failed"
  sleep "$INTERVAL"
done
