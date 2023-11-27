#!/bin/bash

sudo apt update -y
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y
sudo apt install -y nginx
sudo apt install -y php7.4-common php7.4-fpm php7.4-json php7.4-mbstring php7.4-zip php7.4-cli php7.4-xml php7.4-tokenizer php7.4-curl php7.4-mysql
sudo apt install -y composer

echo "######################################################"

if [ -n "$1" ]; then
    web=$1
else
    read -p "Enter Website Name: " web
fi

sudo touch /etc/nginx/sites-available/$web.conf
sudo tee /etc/nginx/sites-available/$web.conf > /dev/null <<EOT
server {
    listen 80;
    server_name $web;

    root /var/www/$web/public;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOT

sudo ln -s /etc/nginx/sites-available/$web.conf /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

cd ~
composer create-project --prefer-dist laravel/laravel $web
sudo mv ~/$web /var/www/$web
sudo chown -R www-data:www-data /var/www/$web/storage
sudo chmod -R 775 /var/www/$web/storage
cd /var/www/$web
php artisan key:generate

echo "Laravel and Nginx installation complete."