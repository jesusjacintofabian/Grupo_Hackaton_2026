# Módulo 01 — Redes y Protocolos

> **Categoría:** Fundamentos · **Prioridad:** Obligatorio · **Origen:** `devops-roadmap.html#s01`

## 1. Por qué importa

Un DevOps trabaja constantemente con aplicaciones, servidores y servicios conectados en red. Entender cómo fluye la información es la base de todo lo demás. En el contexto de Copa Airlines, las APIs de vuelo, datos meteorológicos y sistemas de reserva dependen enteramente de redes y protocolos bien comprendidos.

## 2. Objetivos de aprendizaje

- Modelar el tráfico de red en capas (OSI / TCP/IP)
- Calcular subredes y diseñar direccionamiento eficiente
- Diagnosticar problemas de red con herramientas estándar
- Aplicar medidas básicas de seguridad perimetral

## 3. Prerrequisitos

- Computadora con Linux/macOS o WSL2
- Permisos para instalar paquetes (`sudo`/`brew`)
- Acceso a una red local propia para practicar

## 4. Temas detallados

### 4.1 Modelo OSI y TCP/IP
- 7 capas OSI: Física, Enlace, Red, Transporte, Sesión, Presentación, Aplicación
- 4 capas TCP/IP: Acceso, Internet, Transporte, Aplicación
- Encapsulación y PDU (Protocol Data Unit)
- Mapping OSI ↔ TCP/IP

### 4.2 Direccionamiento IP
- IPv4 (32 bits, 4.3 mil millones de direcciones)
- IPv6 (128 bits)
- CIDR y subnetting
- Direccionamiento público vs privado

### 4.3 Protocolos clave
| Protocolo | Uso | Puerto |
|-----------|-----|--------|
| HTTP/HTTPS | Web y APIs | 80/443 |
| TCP/UDP | Transporte confiable vs rápido | — |
| SSH | Acceso remoto seguro | 22 |
| DNS | Resolución de nombres | 53 |
| DHCP | Asignación dinámica de IP | 67/68 |
| SMTP/FTP/SFTP | Correo y archivos | 25/20-21/22 |
| SNMP/NTP | Gestión y tiempo | 161/123 |

### 4.4 Seguridad de red
- Firewalls (iptables, nftables, Security Groups)
- NAT (Network Address Translation)
- VPN (túneles cifrados)
- Proxies y reverse proxies
- ACL (Access Control Lists)

### 4.5 Balanceo de carga
- Round Robin
- Sticky Sessions
- Health Checks
- L4 vs L7 load balancing

## 5. Herramientas

| Herramienta | Uso | Nivel | Instalación |
|-------------|-----|-------|-------------|
| Wireshark | Captura y análisis de paquetes en tiempo real | Intermedio | `apt install wireshark` |
| Nmap | Escaneo de puertos y descubrimiento de hosts | Básico | `apt install nmap` |
| tcpdump | Captura de paquetes vía CLI | Intermedio | `apt install tcpdump` |
| traceroute | Traza ruta de paquetes | Básico | `apt install traceroute` |
| netstat / ss | Conexiones activas y puertos en escucha | Básico | Preinstalado |

## 6. Proyecto 01 — Análisis de Red con Nmap y Wireshark

**Duración estimada:** 8-12 horas
**Entregable:** Diagrama de red documentado + scripts reutilizables

### Pasos

1. **Escaneo de red local con Nmap**
   ```bash
   nmap -sn 192.168.1.0/24         # descubrir hosts
   nmap -sV -O 192.168.1.0/24      # servicios y OS
   nmap -p- --open 192.168.1.10    # puertos abiertos
   ```
   Documentar: hosts, IPs, MAC, OS, puertos y servicios.

2. **Captura de tráfico HTTP con Wireshark**
   - Iniciar captura en interfaz activa
   - Visitar un sitio HTTP (no HTTPS) o `http://neverssl.com`
   - Filtro: `http.request.method == "GET"`
   - Analizar: SYN, SYN-ACK, ACK, request, response, FIN
   - Exportar captura `.pcap` con anotaciones

3. **Servidor DNS local con dnsmasq**
   ```bash
   sudo apt install dnsmasq
   # /etc/dnsmasq.conf
   address=/hackathon.local/192.168.1.50
   sudo systemctl restart dnsmasq
   dig hackathon.local @127.0.0.1
   ```

4. **Reglas de firewall con iptables**
   ```bash
   # Bloquear puerto 23 (telnet)
   sudo iptables -A INPUT -p tcp --dport 23 -j DROP
   # Permitir SSH solo desde tu IP
   sudo iptables -A INPUT -p tcp -s TU_IP --dport 22 -j ACCEPT
   sudo iptables -A INPUT -p tcp --dport 22 -j DROP
   sudo iptables -L -n -v
   ```

5. **Diagrama de red final**
   - Herramienta sugerida: draw.io, Mermaid o Excalidraw
   - Incluir: topología, subredes, IPs, servicios, gateways, firewalls

### Entregables
- [ ] `inventario-red.md` con tabla de hosts descubiertos
- [ ] `captura-http.pcap` con anotaciones
- [ ] `dnsmasq.conf` configurado
- [ ] `firewall-rules.sh` documentado
- [ ] `diagrama-red.png` exportado

## 7. Checklist de cierre del módulo

- [ ] Entiendo las 7 capas del modelo OSI y su función
- [ ] Puedo calcular subredes con CIDR (/24, /16, /8)
- [ ] Conozco la diferencia entre TCP y UDP
- [ ] Sé cómo funciona DNS y DHCP
- [ ] He usado Wireshark o tcpdump para capturar tráfico
- [ ] Proyecto 01 entregado y commiteado en repo del equipo

## 8. Recursos recomendados

- **Libro:** "Computer Networking: A Top-Down Approach" — Kurose & Ross
- **Curso:** Networking Fundamentals (Cisco NetAcad gratuito)
- **Docs:** https://www.cloudflare.com/learning/network-layer/what-is-the-network-layer/
- **Práctica:** https://www.packettracer.net/ (simulador)
- **Labs:** https://tryhackme.com (rutas de redes)

## 9. Conexión con el Hackathon

Para Copa Airlines — la optimización de rutas de vuelo, APIs de meteorología y sistemas de reserva se modelan como tráfico de red. Entender latencia, jitter y packet loss permite diseñar soluciones edge que respondan en tiempo real.

## 10. Siguiente módulo

→ [Módulo 02 — Linux](../02-linux/plan.md)
