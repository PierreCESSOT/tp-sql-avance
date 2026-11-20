PARTIE C

Question 7

La requête ne renvoie rien à cause de Claire Moreau. Elle n'a pas de manager, donc sa case manager_id est vide (NULL).

Quand on écrit NOT IN avec une liste qui contient NULL, SQL ne sait plus répondre. Il ne dit ni oui ni non, il dit "je ne sais pas". Du coup, aucune ligne n'est gardée.

Pour corriger, on utilise NOT EXISTS. Il ne se trompe pas avec les cases vides :

SELECT e.id, e.nom FROM employes e WHERE NOT EXISTS (SELECT 1 FROM employes s WHERE s.manager_id = e.id);

Question 8

Pour montrer le problème, j'utilise deux sessions en même temps, T1 et T2, sur la table des comptes.

Avec READ COMMITTED : T1 lit le solde du compte 1, il voit 15000. Ensuite T2 enlève 1000 et valide. Quand T1 relit le même compte, il voit 14000. Il a lu deux fois la même chose et a eu deux résultats différents. C'est un Non-Repeatable Read.

Avec REPEATABLE READ : je refais pareil, mais T1 voit 15000 les deux fois. Le problème est réglé, car T1 garde la même vue de la base pendant toute sa transaction.

Le WAL est un journal. Avant de modifier les données, la base écrit d'abord ce qu'elle va faire dans ce journal. Si le serveur s'arrête en plein virement, la base relit le journal au redémarrage. Si le virement n'était pas terminé, elle l'annule, donc l'argent n'est pas perdu. Si le virement était déjà validé, elle le garde.

Question 9

J'utilise trois bases différentes, une pour chaque besoin.

(a) Le suivi GPS : 30 000 véhicules qui envoient leur position toutes les 3 secondes, ça fait environ 10 000 écritures par seconde. J'utilise Cassandra, qui est faite pour écrire énormément de données très vite. Si une position arrive avec un petit retard, ce n'est pas grave. Elle choisit donc la disponibilité et la vitesse (AP, et PA/EL en PACELC).

(b) La facturation : on ne peut pas se tromper avec l'argent. J'utilise PostgreSQL, qui garantit que les paiements sont corrects (transactions ACID). En cas de panne, il préfère s'arrêter plutôt que de facturer deux fois. Il choisit donc la cohérence (CP, et PC/EC en PACELC).

(c) Les amis communs à 3 degrés : ce sont des liens entre des personnes. J'utilise Neo4j, une base de graphe, qui suit ces liens directement.

Les 4 critères de choix :

La cohérence : très importante pour l'argent, moins pour le GPS.
La taille des données : énormément d'écritures pour le GPS, normal pour la facturation.
La forme des données : des mesures, des tableaux, et des liens entre personnes.
La façon de les lire : écrire beaucoup (GPS), faire des paiements fiables (facturation), suivre des liens (amis).