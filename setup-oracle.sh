#!/usr/bin/env bash
set -e

echo "=== 1. Mise à jour du système et installation des paquets ==="
sudo apt update
sudo apt install -y nginx git iptables-persistent

echo "=== 2. Ouverture des ports 80 et 443 dans iptables ==="
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT 2>/dev/null || sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT 2>/dev/null || sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
sudo netfilter-persistent save

echo "=== 3. Clonage / Mise à jour du site ==="
SITE_DIR="/var/www/vivre-leger"
if [ ! -d "$SITE_DIR/.git" ]; then
    sudo mkdir -p "$SITE_DIR"
    sudo chown -R "$USER:$USER" "$SITE_DIR"
    git clone https://github.com/hibatallahmortadi-sketch/vivre-leger.git "$SITE_DIR"
else
    cd "$SITE_DIR"
    git fetch origin main
    git reset --hard origin/main
fi

sudo chown -R www-data:www-data "$SITE_DIR"
sudo chmod -R 755 "$SITE_DIR"

echo "=== 4. Configuration Nginx ==="
sudo tee /etc/nginx/sites-available/vivre-leger > /dev/null <<'EOF'
server {
    listen 80;
    listen [::]:80;

    server_name _;

    root /var/www/vivre-leger;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff2?)$ {
        expires 7d;
        add_header Cache-Control "public, no-transform";
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/vivre-leger /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t
sudo systemctl reload nginx

echo "=== Déploiement terminé avec succès ! ==="
echo "Accédez au site via : http://$(curl -s ifconfig.me)"
