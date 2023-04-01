# Projet Analyseur Syntaxique

**Auteur :** Tran Sylvain

**Date :** fin 2022 (L3, semestre 5)

**Objectif :**  
Réaliser un analyseur syntaxique en utilisant les outils flex et bison, pour un langage de programmation appelé TPC, qui ressemble à un sous-ensemble du langage C.

**Sujet :**  
Voir le [sujet]()

---

## Usage :
Pour tester l'analyseur, tapez :  
```
make
./bin/tpcas [-h | --help | -t | --tree] < filename.tpc
```
**Détails des options :**  
-h, --help : affiche une description de l’interface utilisateur.  
-t, --tree : affiche l’arbre abstrait produit par l'analyseur, traduisant le fichier TPC s'il ne contient pas d’erreur lexicale ni syntaxique.

Si le fichier TPC contient une erreur lexicale ou syntaxique, alors un message d'erreur s'affiche, indiquant le numéro de la ligne et le numéro dans la ligne du premier caractère du lexème causant l’erreur.

**Mes choix d'implémentation :**  
Voir le fichier [rapport.pdf]()