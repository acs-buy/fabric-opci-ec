# 1. Pourquoi cette solution existe

## La solution n'est pas partie d'un outil

Beaucoup d'outils de cabinet commencent par une technologie et cherchent ensuite à quoi elle
pourrait servir. Celui-ci est parti de deux personnes et de ce qui leur manquait.

Le réviseur voulait savoir où en est sa mission sans rouvrir chaque dossier : il a fallu un écran
qui lit la base en direct et dit ce qui reste ouvert. Le client, lui, voulait comprendre son
véhicule sans attendre un rendez-vous : il a fallu huit pages qu'il ouvre lui-même, sur une donnée
que le cabinet a visée.

La base de données, les fonctions et les contrôles sont venus après. Ils ont été choisis parce que
ces deux besoins les exigeaient.

---

## Le premier utilisateur : le réviseur

### Ce qu'il fait aujourd'hui sans la solution

Vous tenez l'avancement de vos missions dans un classeur, ou dans votre tête. Le classeur est à
jour le jour où vous l'avez rempli. Pour savoir si un dossier est prêt, vous l'ouvrez.

### Les quatre questions auxquelles il doit répondre

Piloter une mission ne tient pas à une seule information. Il y en a quatre, et elles n'appellent
pas les mêmes décisions.

| La question | La décision qu'elle commande |
|---|---|
| **Où en est le planning ?** | Faut-il relancer le client, ou décaler l'arrêté |
| **Qui est affecté, et est-ce suffisant ?** | Faut-il désigner quelqu'un, ou en changer |
| **Combien de travail reste-t-il ?** | Faut-il prévoir des jours supplémentaires |
| **La qualité est-elle tenue ?** | Faut-il revoir un travail avant de le viser |

L'écran de conduite répond aux quatre, et c'est pour cela qu'il affiche autant d'indicateurs.

[Le détail de ce que l'écran montre pour chacune](02-ce-que-voit-le-reviseur.md)

### La trace que la norme professionnelle demande

La mission de présentation relève de la norme professionnelle NP 2300. Un outil ne rend pas une
mission conforme : la conformité s'apprécie, et cette appréciation reste au professionnel. Ce que
la solution fait, c'est enregistrer la trace au fil du travail, au lieu de vous la faire
reconstituer le jour où quelqu'un la demande.

- chaque réponse d'acceptation est horodatée et attribuée à son auteur ;
- chaque pièce justificative est enregistrée avec sa nature, sa date de dépôt et le nom de celui
  qui l'a déposée, plus une empreinte numérique qui prouve qu'elle n'a pas changé ;
- un retrait de pièce exige un motif, et se refuse si la pièce fonde une donnée ;
- l'approbation d'un visa est refusée à la personne qui l'a soumis.

Ce dernier refus est écrit dans la base de données, pas dans l'écran. Quelqu'un qui contournerait
l'écran, en appelant directement la fonction, se le verrait opposer de la même façon. Le bouton
grisé prévient l'utilisateur plus tôt, voilà tout.

---

## Le second utilisateur : le client

### Ce qu'il vit aujourd'hui sans la solution

Il reçoit ses comptes annuels quelques mois après la clôture. Entre deux arrêtés, il appelle pour
savoir où en sont les choses, et la réponse part par courriel, dans un tableau refait pour
l'occasion.

### Ce dont il a besoin

Un porteur de parts, une société de gestion ou un directeur financier ne pilotent pas un OPCI une
fois l'an. Il leur faut :

1. **La valeur**, à l'arrêté qui les intéresse. Le dernier arrêté publié ne répond pas à leur
   question.
2. **L'explication de la variation**, cause par cause. Constater qu'elle a eu lieu ne leur apprend
   rien.
3. **Le patrimoine et les participations**, avec ce qui fonde chaque valeur.
4. **Les ratios réglementaires**, et ce que le calcul retient.
5. **La distribution**, avec l'obligation minimale et le plafond.

[Le détail des huit pages](03-ce-que-voit-le-client.md)

### Pourquoi le client ne lit jamais une donnée non visée

Beaucoup d'outils branchent un tableau de bord directement sur une base et annoncent du « temps
réel ». Le client y lit une donnée que personne n'a revue.

Ici, rien n'arrive sur l'écran du client tant que le cabinet n'a pas visé. C'est plus lent qu'un
branchement direct, et c'est assumé : le client sait que ce qu'il lit a été revu, et par qui.

### Ce que l'écran déplace dans la relation

Un client qui lit ses ratios, sa variation de valeur liquidative et son plafond distribuable ne
demande plus où en sont les comptes. Il demande ce que ces chiffres impliquent. La conversation
passe de la production au conseil, c'est-à-dire au terrain où l'expert-comptable apporte le plus
et qu'il a le moins le temps d'occuper.

---

## Comment les deux besoins se rejoignent

Les deux écrans lisent la même base, et personne ne saisit deux fois.

```
le réviseur saisit et vise  ->  la base  ->  l'écran du client
```

Il en découle trois choses.

1. **Le cabinet ne refait rien en aval.** La restitution du client sort de la mission elle-même,
   il n'y a pas de livrable à fabriquer après coup.
2. **Les deux écrans ne peuvent pas se contredire**, puisqu'ils lisent la même donnée.
3. **Le cabinet garde la main** sur ce qui est publié, et sur le moment où ça l'est.

---

## Ce que cette conception coûte

Elle a un prix, et mieux vaut le connaître avant de commencer.

Sous une capacité F64, chaque lecteur côté client doit être licencié : voir
[les licences](05-les-licences.md).

Tant qu'un dossier n'est pas visé, l'écran du client reste vide. C'est voulu, mais il faut le dire
au client.

L'installation se fait en trois couches, et la synchronisation ne suffit pas : voir
[les trois couches](06-les-trois-couches.md).

---

Suite : [2. Ce que voit le réviseur](02-ce-que-voit-le-reviseur.md)

[Revenir au sommaire](../../README.md) · [Les douze étapes](../faire/etape-01-ouvrir-la-capacite.md)
