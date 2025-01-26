#!/bin/bash

echo "Aktualizacja pakietów"
apt-get update -y

echo "Instalacja narzędzi do analizy sieci"
apt-get install -y net-tools

echo "Czekam na zakończenie uruchamiania systemu..."
sleep 60

echo "Instalacja Nginx..."
apt-get install -y nginx

echo "OK" > /var/www/html/health

echo "Włączanie i uruchamianie Nginx..."
systemctl enable nginx
systemctl start nginx

echo "Nginx powinien teraz działać. Sprawdzanie statusu..."
systemctl status nginx
