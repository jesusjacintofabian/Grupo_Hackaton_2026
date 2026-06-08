#Reglas de Firewall

# Bloquear Telnet
iptables -A INPUT -p tcp --dport 23 -j DROP

# Permitir SSH local
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Mantener conexiones existentes
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
