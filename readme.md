# EvilTwin-AP

Ce dépôt contient des scripts Bash pour réaliser une attaque Wi-Fi de type "Evil Twin", à des fins éducatives et de test de sécurité.

## Table des matières

* [Introduction](#introduction)
* [Scripts](#scripts)
* [Installation (Arch Linux)](#installation-arch-linux)
* [Utilisation](#utilisation)
* [Avertissement](#avertissement)

## Introduction

Une attaque Evil Twin consiste à créer un faux point d'accès Wi-Fi qui imite un réseau légitime. L'objectif est de tromper les utilisateurs pour qu'ils s'y connectent, permettant d'intercepter leur trafic ou de voler des identifiants.

Ce projet utilise `hostapd`, `dnsmasq` et `iptables` pour simuler cet environnement.

## Scripts

* **`demo_eviltwin.sh`** : Le script principal pour lancer le faux point d'accès. Il configure le réseau, démarre `dnsmasq` et `hostapd`, et affiche les identifiants capturés en temps réel. Il inclut une fonction de nettoyage automatique à la sortie.
* **`suivi_eviltwin.sh`** : Un script complémentaire pour surveiller en temps réel les clients connectés au faux point d'accès (adresses IP et MAC).

## Installation (Arch Linux)

1.  **Cloner le dépôt :**
    ```bash
    git clone [https://github.com/ecco2kfr/EvilTwin-AP.git](https://github.com/ecco2kfr/EvilTwin-AP.git)
    cd EvilTwin-AP
    ```

2.  **Installer les paquets nécessaires :**
    ```bash
    sudo pacman -Syu hostapd dnsmasq apache php php-apache
    ```

3.  **Activer et démarrer Apache :**
    ```bash
    sudo systemctl enable httpd
    sudo systemctl start httpd
    ```
    *Assurez-vous que PHP est correctement configuré dans `/etc/httpd/conf/httpd.conf` pour gérer les fichiers `.php` et que `mod_php` est activé.*

4.  **Préparer le répertoire web :**
    * Créez le dossier où sera votre fausse page de connexion :
        ```bash
        sudo mkdir -p /srv/http
        sudo chown -R http:http /srv/http/
        sudo chmod -R 755 /srv/http/
        ```
    * Placez votre fausse page (ex: `index.html`) et un script PHP pour la capture (`login.php` écrivant dans `/srv/http/log.txt`) dans `/srv/http/`.

5.  **Rendre les scripts exécutables :**
    ```bash
    chmod +x demo_eviltwin.sh suivi_eviltwin.sh
    ```

## Utilisation

**ATTENTION : Nécessite les privilèges root. À utiliser de manière responsable et légale.**

1.  Ouvrez deux terminaux.
2.  Dans le premier, lancez le point d'accès (vous serez invité à entrer le SSID) :
    ```bash
    sudo ./demo_eviltwin.sh
    ```
3.  Dans le second, surveillez les connexions :
    ```bash
    sudo ./suivi_eviltwin.sh
    ```
4.  Pour arrêter, faites `Ctrl+C` dans le terminal de `demo_eviltwin.sh`.

## Avertissement

Cet outil est destiné à des **fins éducatives et de tests de sécurité éthiques uniquement**. Je décline toute responsabilité en cas d'utilisation abusive. Utilisez-le uniquement sur des réseaux pour lesquels vous avez une autorisation explicite :D