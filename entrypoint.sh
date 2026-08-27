#!/bin/bash
set -e

KEYDIR=/keys
mkdir -p "$KEYDIR"

if [ ! -f "$KEYDIR/privatekey" ]; then
  wg genkey | tee "$KEYDIR/privatekey" | wg pubkey > "$KEYDIR/publickey"
  echo "Client pubkey (add to headend): $(cat "$KEYDIR/publickey")"
fi

PRIVKEY=$(cat "$KEYDIR/privatekey")

# base config
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = ${PRIVKEY}
Address = ${CLIENT_TUNNEL_IP}
PostUp = /usr/local/bin/setup-nat.sh
PostDown = /usr/local/bin/teardown-nat.sh

[Peer]
PublicKey = ${HEADEND_PUBKEY}
Endpoint = ${HEADEND_ENDPOINT}
AllowedIPs = ${HEADEND_ALLOWED_IPS}
PersistentKeepalive = 25
EOF

wg-quick up wg0
sleep infinity
