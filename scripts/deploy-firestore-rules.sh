#!/bin/bash
# Script para deployar las reglas de seguridad de Firestore

echo "🔐 Deploying Firestore Security Rules..."
echo ""

# Verificar que firebase CLI esté instalado
if ! command -v firebase &> /dev/null
then
    echo "❌ Firebase CLI no está instalado."
    echo ""
    echo "Instálalo con:"
    echo "  npm install -g firebase-tools"
    echo ""
    exit 1
fi

# Verificar que estás logueado
echo "📋 Verificando autenticación..."
firebase login:list &> /dev/null
if [ $? -ne 0 ]; then
    echo "⚠️  No estás autenticado en Firebase."
    echo ""
    echo "Ejecuta: firebase login"
    echo ""
    exit 1
fi

echo "✅ Autenticación verificada"
echo ""

# Verificar que existe el archivo de reglas
if [ ! -f "firestore.rules" ]; then
    echo "❌ No se encuentra el archivo firestore.rules"
    exit 1
fi

echo "📄 Archivo de reglas encontrado"
echo ""

# Mostrar preview de las reglas
echo "📋 Preview de cambios:"
echo "-----------------------------------"
cat firestore.rules | head -n 20
echo "..."
echo "-----------------------------------"
echo ""

# Pedir confirmación
read -p "¿Deseas deployar estas reglas a Firestore? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "🚀 Deploying..."
    firebase deploy --only firestore:rules
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Reglas de Firestore deployadas exitosamente!"
        echo ""
        echo "🔍 Verifica en:"
        echo "   Firebase Console > Firestore Database > Rules"
        echo ""
    else
        echo ""
        echo "❌ Error al deployar las reglas"
        exit 1
    fi
else
    echo "❌ Deploy cancelado"
    exit 0
fi
