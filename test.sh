#!/bin/bash

echo "=========================================="
echo "  TEST DE PERFORMANCE DES ALGORITHMES KEX"
echo "=========================================="
echo ""

# Configuration
SERVER="192.168.56.102"
USER="serveur"
ITERATIONS=10

# Liste des algorithmes à tester
KEX_ALGOS=(
    "diffie-hellman-group14-sha256"
    "curve25519-sha256"
    "ecdh-sha2-nistp256"
)

echo "Serveur : $SERVER"
echo "Utilisateur : $USER"
echo "Itérations par algorithme : $ITERATIONS"
echo ""
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
        
        ssh -o KexAlgorithms=$kex \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o ConnectTimeout=10 \
            -i ~/.ssh/id_lab \
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
        
        # Petite pause
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
        echo "  ❌ Aucune connexion réussie"
    fi
    
    echo ""
done

echo "=========================================="
echo "  FIN DES TESTS"
echo "=========================================="
