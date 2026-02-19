#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: ./scripts/new-project.sh nom-du-projet"
  exit 1
fi

PROJECT=$1
VPS_IP="72.61.116.114"

echo "🚀 Création du projet $PROJECT..."

# Créer le repo GitHub depuis ce template
gh repo create $PROJECT --public --template mlrdt/webapp-template --clone
cd $PROJECT

# Créer le dossier sur le VPS
ssh root@$VPS_IP "mkdir -p /var/www/$PROJECT && chown deploy:deploy /var/www/$PROJECT"
ssh deploy@$VPS_IP "cd /var/www/$PROJECT && git clone https://github.com/mlrdt/$PROJECT ."

# Ajouter les secrets GitHub de base
gh secret set VPS_HOST --body "$VPS_IP"
gh secret set VPS_USER --body "deploy"
gh secret set PROJECT_NAME --body "$PROJECT"
gh secret set VPS_SSH_KEY --body "$(cat /home/deploy/.ssh/github_actions)"

echo ""
echo "✅ Projet $PROJECT créé !"
echo ""
echo "Il te reste à ajouter les secrets Supabase :"
echo "  gh secret set NEXT_PUBLIC_SUPABASE_URL --body 'https://xxx.supabase.co'"
echo "  gh secret set NEXT_PUBLIC_SUPABASE_ANON_KEY --body 'eyJ...'"
echo "  gh secret set SUPABASE_SERVICE_ROLE_KEY --body 'eyJ...'"
echo ""
echo "Repo : https://github.com/mlrdt/$PROJECT"
