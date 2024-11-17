### Enable IPv4/IPv6 Forwarding
sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1

### Firewall disabling
sudo ufw disable

### Add NAT Rule
sudo iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
sudo ip6tables -t nat -A POSTROUTING -s 2001:db8:cafe::/48 ! -o ogstun -j MASQUERADE

### amf
sudo ip addr add 192.168.53.5/24 dev wlp2s0
### upf
sudo ip addr add 192.168.53.7/24 dev wlp2s0
