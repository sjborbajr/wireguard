#!/bin/bash
sysctl -w net.ipv4.ip_forward=1 >/dev/null

nft add table ip nat
nft add chain ip nat prerouting  '{ type nat hook prerouting priority -100; }'
nft add chain ip nat postrouting '{ type nat hook postrouting priority 100; }'

if [ -n "$SHADOW_SUBNET" ] && [ "$SHADOW_SUBNET" != "$REAL_LAN_SUBNET" ]; then
  SHADOW_NET=$(echo "$SHADOW_SUBNET" | cut -d/ -f1)
  REAL_NET=$(echo "$REAL_LAN_SUBNET" | cut -d/ -f1)
  MASK_INV="0.0.0.255"
  nft add rule ip nat prerouting iifname "wg0" ip daddr "$SHADOW_SUBNET" \
    dnat ip to ip daddr and $MASK_INV or $REAL_NET
fi

EGRESS_IF="${EGRESS_IF:-$(ip route show default | awk '/default/ {print $5; exit}')}"
nft add rule ip nat postrouting oifname "$EGRESS_IF" masquerade
