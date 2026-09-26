# Étape 3. Créer l'espace de travail

Toute la solution tient dans un seul espace de travail Fabric. Vous n'en créerez pas d'autre.

## Le créer

1. Dans le menu de gauche de `app.fabric.microsoft.com`, cliquez sur **Espaces de travail**.
2. Cliquez sur **Nouvel espace de travail**.
3. Donnez-lui un nom. Le nom est libre : aucun script de ce dépôt n'en dépend.
4. Dépliez **Avancé**.
5. Dans **Licence**, choisissez votre capacité d'essai ou votre capacité F.

## Vérifier

Une fois l'espace créé, regardez son bandeau. Vous y retrouverez **Create app**, dont vous vous
servirez à l'étape 11, **Manage access** pour ajouter vos collaborateurs, et **Workspace settings**,
qui revient aux étapes 3 et 5.

![Le bandeau de l'espace de travail](../../captures/espace-bandeau.png)


Ouvrez ensuite **Paramètres de l'espace de travail**, onglet **Licence**, et lisez ce qui s'y
affiche. Si vous y voyez « Pro », les éléments Fabric autres que Power BI ne fonctionneront pas, et
aucun message d'erreur ne vous dira que la capacité est en cause : vous chercherez ailleurs. Ce que
vous devez lire, c'est le nom de votre capacité.

## Une règle à retenir dès maintenant

Une fois un élément de la solution installé, ne le renommez plus. Le rapport retrouve son modèle de
données par son nom, un renommage casse cette liaison, et l'erreur qui apparaît alors ne parle pas
du renommage.

L'espace de travail, lui, vous pouvez le nommer comme vous voulez et le renommer plus tard.

## Qui doit faire quoi

Vous êtes administrateur de l'espace que vous venez de créer, sans rien avoir à demander. C'est ce
rôle qui permet de connecter le dépôt Git à l'étape suivante.

Si plusieurs personnes doivent travailler dans la solution, ajoutez-les maintenant par **Gérer
l'accès**. Le rôle de contributeur suffit pour utiliser les écrans. Comme signalé à l'étape
précédente, sous une capacité F64, chacune de ces personnes a besoin d'une licence Power BI Pro.

---

Suite : [Étape 4. Copier ce dépôt sur votre compte GitHub](etape-04-copier-le-depot.md)

[Revenir au sommaire](../../README.md) · [Dépannage](depannage.md) · [Pièces et classeurs](pieces-et-classeurs.md)
