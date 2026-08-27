# wireguard
This docker image will maintain a tunnel back to a head end, everything is source NAT'd for return traffic and can optional destination nat to overcome overlapping subnets

# head end example config
/etc/wireguard/wg0.conf
[Interface]
PrivateKey = <local-private-key>
Address = 100.64.0.1/16
ListenPort = 51820

[Peer]
PublicKey = <remote-public-key>
AllowedIPs = 192.0.2.0/24,100.64.0.2/32

sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
