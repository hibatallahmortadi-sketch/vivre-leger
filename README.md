# Vivre Léger 🌿

Site web statique de coaching de vie pour Hibatallah Mortadi.

---

## Sommaire
- [Structure du projet](#structure-du-projet)
- [Option 1 : Déploiement sur GitHub Pages (Recommandé & Gratuit)](#option-1--déploiement-sur-github-pages)
- [Option 2 : Déploiement sur Oracle Cloud (Always Free VM)](#option-2--déploiement-sur-oracle-cloud-always-free)
- [Mise à jour du site](#mise-à-jour-du-site)

---

## Structure du projet

- `index.html` : Page d'accueil
- `programme.html` : Présentation du programme de coaching
- `a-propos.html` : Page À propos
- `guide.html` : Guide gratuit
- `style.css` : Feuilles de style
- `script.js` : Scripts d'animation et de navigation
- `setup-oracle.sh` : Script d'installation automatique pour VM Oracle Linux/Ubuntu
- `.github/workflows/pages.yml` : Workflow de déploiement automatique sur GitHub Pages
- `.github/workflows/deploy.yml` : Workflow de déploiement SSH vers Oracle Cloud

---

## Option 1 : Déploiement sur GitHub Pages

GitHub Pages permet d'héberger ce site statique sans aucun serveur à gérer, avec HTTPS automatique.

### Activer GitHub Pages sur le dépôt :
1. Rendez-vous sur votre dépôt : `https://github.com/hibatallahmortadi-sketch/vivre-leger`
2. Cliquez sur l'onglet **Settings** (Paramètres).
3. Dans le menu de gauche, cliquez sur **Pages**.
4. Sous **Build and deployment** > **Source** :
   - Choisissez **GitHub Actions** (le fichier `.github/workflows/pages.yml` s'occupera du déploiement à chaque `git push`).
   - *(Ou bien sélectionnez **Deploy from a branch**, branche `main`, dossier `/ (root)` et cliquez sur **Save**)*.
5. Si le dépôt est **privé**, assurez-vous d'avoir GitHub Pro, ou passez le dépôt en **Public** dans **Settings > General > Danger Zone > Change repository visibility**.
6. Votre site sera disponible à l'adresse :
   ```
   https://hibatallahmortadi-sketch.github.io/vivre-leger/
   ```

---

## Option 2 : Déploiement sur Oracle Cloud (Always Free)

### 1. Créer la machine virtuelle sur Oracle Cloud
1. Connectez-vous à la [Console Oracle Cloud (OCI)](https://cloud.oracle.com).
2. Rendez-vous dans **Compute > Instances > Create Instance**.
3. Choisissez une image : **Ubuntu 22.04 LTS** ou **Ubuntu 24.04**.
4. Shape :
   - **VM.Standard.E2.1.Micro** (AMD, 1 OCPU, 1 Go RAM) ou
   - **VM.Standard.A1.Flex** (Ampere ARM, jusqu'à 4 OCPU et 24 Go RAM).
5. Dans la section **Networking** :
   - Assurez-vous que **Assign a public IPv4 address** est activé.
6. Dans **Add SSH Keys** :
   - Ajoutez votre clé publique SSH (`id_rsa.pub` ou `id_ed25519.pub`).
7. Cliquez sur **Create**.

### 2. Ouvrir les ports 80 (HTTP) et 443 (HTTPS) dans la console Oracle
1. Sur la page de votre instance, cliquez sur le nom du sous-réseau (**Subnet**).
2. Cliquez sur votre **Default Security List**.
3. Cliquez sur **Add Ingress Rules** et remplissez :
   - **Source CIDR** : `0.0.0.0/0`
   - **IP Protocol** : `TCP`
   - **Destination Port Range** : `80,443`
   - **Description** : `HTTP and HTTPS`
4. Cliquez sur **Add Ingress Rules**.

### 3. Installer et lancer le site sur la VM
Connectez-vous à votre instance en SSH :
```bash
ssh ubuntu@<IP_PUBLIQUE_DE_VOTRE_VM>
```

Lancez simplement le script de configuration automatique :
```bash
curl -fsSL https://raw.githubusercontent.com/hibatallahmortadi-sketch/vivre-leger/main/setup-oracle.sh | bash
```

Le script va :
- Installer Nginx, Git et iptables-persistent.
- Ouvrir les ports 80 et 443 dans le pare-feu `iptables`.
- Télécharger le site dans `/var/www/vivre-leger`.
- Configurer et démarrer Nginx.

Votre site sera immédiatement en ligne sur : `http://<IP_PUBLIQUE_DE_VOTRE_VM>`.

### 4. Configurer un nom de domaine et le SSL (Let's Encrypt)
Sur votre VM en SSH :
```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d votre-domaine.com -d www.votre-domaine.com
```

### 5. Déploiement automatique continu via GitHub Actions (Optionnel)
Pour mettre à jour automatiquement la VM Oracle à chaque `push` :
1. Dans GitHub, allez dans **Settings > Secrets and variables > Actions > New repository secret**.
2. Créez les secrets suivants :
   - `ORACLE_HOST` : Adresse IP publique de la VM.
   - `ORACLE_USER` : `ubuntu`.
   - `ORACLE_SSH_KEY` : Contenu complet de votre clé privée SSH.

---

## Mise à jour du site

Pour modifier le site en local et publier les changements :
```bash
git add .
git commit -m "Description des modifications"
git push origin main
```
Le site se mettra automatiquement à jour sur GitHub Pages (et sur Oracle Cloud si vous avez configuré les secrets).
