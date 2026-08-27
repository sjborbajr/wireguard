# wireguard

Docker image that maintains a persistent WireGuard tunnel from a client site back to a head end.

All outbound-to-LAN traffic is source-NAT'd (masquerade) so the client's LAN devices need zero routing/config changes to reply. Destination NAT (subnet remap) is optional, for when a client's real LAN subnet collides with another client's.

## Head end setup

`/etc/wireguard/wg0.conf`:
```ini
[Interface]
PrivateKey = <local-private-key>
Address = 100.64.0.1/16
ListenPort = 51820

[Peer]
PublicKey = <remote-public-key>
AllowedIPs = 192.0.2.0/24,100.64.0.2/32
```

```bash
sudo systemctl enable --now wg-quick@wg0
sudo sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
```

One `[Peer]` block per client. `AllowedIPs` = that client's tunnel IP (`/32`) + its real LAN subnet, or its shadow subnet if remapped (see below).

## Client container

### Environment variables

| Variable | Description | Example |
|---|---|---|
| `HEADEND_PUBKEY` | Head end's WireGuard public key | `<headend-public-key>` |
| `HEADEND_ENDPOINT` | Head end reachable address:port | `headend.example.com:51820` |
| `HEADEND_ALLOWED_IPS` | Head end's own tunnel IP (what this client routes through the tunnel) | `100.64.0.1/32` |
| `CLIENT_TUNNEL_IP` | This container's tunnel address | `100.64.0.2/32` |
| `REAL_LAN_SUBNET` | Client's actual LAN subnet | `192.0.2.0/24` |
| `SHADOW_SUBNET` | *(optional)* Alternate subnet advertised to head end, used only if `REAL_LAN_SUBNET` collides with another. When set, the container DNATs inbound traffic to `SHADOW_SUBNET` back to `REAL_LAN_SUBNET`. Omit for a direct 1:1 mapping (no rewrite). | `198.51.100.0/24` |

On first boot, the container generates a WireGuard keypair under `/keys` (persist this volume) and prints its public key — add that as the head end's `PublicKey` for this client's `[Peer]` block.

If `SHADOW_SUBNET` is set, the head end's matching `[Peer]` `AllowedIPs` should use `SHADOW_SUBNET`, not `REAL_LAN_SUBNET`.

### compose.yml

```yaml
services:
