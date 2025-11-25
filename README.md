#!/usr/bin/env python3
from cryptography.hazmat.primitives.asymmetric import ed25519
from cryptography.hazmat.primitives import serialization
import base64

# Générer la paire de clés
private_key = ed25519.Ed25519PrivateKey.generate()
public_key = private_key.public_key()

# Sauvegarder la clé privée (format PEM)
private_pem = private_key.private_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PrivateFormat.OpenSSH,
    encryption_algorithm=serialization.NoEncryption()
)

# Sauvegarder la clé publique (format SSH)
public_ssh = public_key.public_bytes(
    encoding=serialization.Encoding.OpenSSH,
    format=serialization.PublicFormat.OpenSSH
)

# Écrire les fichiers
with open('/home/sihaaam/.ssh/id_ed25519_manual', 'wb') as f:
    f.write(private_pem)

with open('/home/sihaaam/.ssh/id_ed25519_manual.pub', 'wb') as f:
    f.write(public_ssh + b' manual@client\n')

print("Clés générées avec succès!")
print(f"Clé publique: {public_ssh.decode()}")
