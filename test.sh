#!/bin/bash

echo "=========================================="
echo "  TEST DE PERFORMANCE DES ALGORITHMES KEX"
echo "  Port SSH : 2222"
echo "=========================================="
echo ""

# Configuration
SERVER="192.168.56.102"
PORT="2222"
USER="serveur"
KEY="~/.ssh/id_lab"
ITERATIONS=10

# Liste des algorithmes à tester
KEX_ALGOS=(
    "curve25519-sha256"
    "diffie-hellman-group14-sha256"
    "ecdh-sha2-nistp256"
    "ecdh-sha2-nistp384"
    "sntrup761x25519-sha512"
)

echo "Serveur : $SERVER:$PORT"
echo "Utilisateur : $USER"
echo "Clé : $KEY"
echo "Itérations : $ITERATIONS"
echo ""

# Test de connectivité préalable
echo "Test de connectivité..."
ssh -p $PORT -i $KEY -o ConnectTimeout=5 $USER@$SERVER "echo 'Connexion OK'" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Serveur accessible"
    echo ""
else
    echo "❌ Impossible de se connecter au serveur"
    echo "Vérifiez : ssh -p $PORT -i $KEY $USER@$SERVER"
    exit 1
fi

echo "Début des tests..."
echo ""

for kex in "${KEX_ALGOS[@]}"; do
    echo "=========================================="
    echo "Algorithme : $kex"
    echo "=========================================="
    
    total_time=0
    success_count=0
    
    for i in $(seq 1 $ITERATIONS); do
        echo -n "  Essai $i/$ITERATIONS... "
        
        # Mesurer le temps
        start=$(date +%s%N)
        
        ssh -p $PORT \
            -i $KEY \
            -o KexAlgorithms=$kex \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o ConnectTimeout=10 \
            $USER@$SERVER "exit" 2>/dev/null
        
        result=$?
        end=$(date +%s%N)
        
        if [ $result -eq 0 ]; then
            elapsed=$(( (end - start) / 1000000 ))
            total_time=$(( total_time + elapsed ))
            success_count=$(( success_count + 1 ))
            echo "${elapsed}ms ✅"
        else
            echo "ÉCHEC ❌"
        fi
        
        # Petite pause entre les tests
        sleep 0.3
    done
    
    if [ $success_count -gt 0 ]; then
        avg=$(( total_time / success_count ))
        echo ""
        echo "  📊 Résultats :"
        echo "  ├─ Réussis : $success_count/$ITERATIONS"
        echo "  ├─ Temps total : ${total_time}ms"
        echo "  └─ Temps moyen : ${avg}ms"
    else
        echo ""
        echo "  ❌ Aucune connexion réussie"
    fi
    
    echo ""
done

echo "=========================================="
echo "  RÉCAPITULATIF DES PERFORMANCES"
echo "=========================================="
echo ""

# Créer un fichier de résultats
cat > ~/kex_results_summary.txt << 'RESULTS'
Algorithme                          | Temps moyen (ms)
------------------------------------|------------------
RESULTS

echo "Résultats sauvegardés dans ~/kex_results_summary.txt"
