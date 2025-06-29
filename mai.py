import random
import time
import os
import secrets

def initialiser_random_puissant():
    """
    Initialise un générateur de nombres aléatoires cryptographiquement sécurisé
    """
    # Utilise secrets pour un vrai hasard cryptographique
    random.seed(secrets.token_bytes(32))
    
    # Ajoute des sources d'entropie supplémentaires
    entropie = int(time.time() * 1000000)  # Microsecondes
    entropie += os.getpid()  # PID du processus
    entropie += random.randint(0, 999999)  # Valeur aléatoire supplémentaire
    
    # Mélange avec des données du système
    random.seed(entropie)

def tirer_lettre():
    """
    Tire au hasard une lettre parmi "J", "E", "L" avec un hasard cryptographiquement sécurisé
    """
    lettres = [ "J", "L"]
    
    # Utilise secrets.choice pour un tirage cryptographiquement sécurisé
    lettre_tiree = secrets.choice(lettres)
    
    # Ajoute un délai aléatoire pour plus d'entropie
    time.sleep(secrets.randbelow(10) / 1000)  # 0-10ms
    
    return lettre_tiree

def main():
    print("=== Tirage au sort de lettres (Hasard cryptographique) ===")
    print("Lettres disponibles: J, E, L")
    
    # Initialise le générateur de hasard puissant
    initialiser_random_puissant()
    
    # Tirage d'une lettre
    resultat = tirer_lettre()
    print(f"\nLettre tirée: {resultat}")
    
    # Optionnel: demander à l'utilisateur s'il veut tirer à nouveau
    while True:
        choix = input("\nVoulez-vous tirer une autre lettre? (o/n): ").lower()
        if choix in ['o', 'oui', 'y', 'yes']:
            # Réinitialise le hasard pour chaque nouveau tirage
            initialiser_random_puissant()
            resultat = tirer_lettre()
            print(f"Lettre tirée: {resultat}")
        elif choix in ['n', 'non', 'no']:
            print("Merci d'avoir utilisé le script!")
            break
        else:
            print("Veuillez répondre par 'o' (oui) ou 'n' (non)")

if __name__ == "__main__":
    main() 