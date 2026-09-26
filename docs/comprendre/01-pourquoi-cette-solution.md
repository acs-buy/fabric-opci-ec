# 1. Pourquoi cette solution existe

Cette page explique d'où part la solution. Elle ne contient aucune manipulation : c'est la partie
qu'on lit avant de commencer, ou le soir où l'on se demande pourquoi telle étape existe.

---

## La solution n'est pas partie d'un outil

Beaucoup d'outils de cabinet commencent par une technologie, puis cherchent à quoi elle pourrait
servir. Celui-ci est parti de deux personnes et de ce qui leur manquait.

| L'utilisateur | Ce qui lui manquait | Ce qu'il fallait construire |
|---|---|---|
| Le réviseur | Savoir où en est sa mission sans rouvrir chaque dossier | Un écran qui lit la base en direct et dit ce qui reste ouvert |
| Le client | Comprendre son véhicule sans attendre un rendez-vous | Huit pages qu'il ouvre lui-même, sur une donnée que le cabinet a visée |

Tout le reste découle de là. La base de données, les fonctions, les contrôles : ce sont des moyens,
et ils ont été choisis parce que ces deux besoins l'exigeaient.

---

## Le premier utilisateur : le réviseur

### Ce qu'il fait aujourd'hui sans la solution

Il tient l'avancement de ses missions dans un classeur, ou dans sa tête. Le classeur est à jour le
jour où il l'a rempli. Pour savoir si un dossier est prêt, il l'ouvre.

### Les quatre questions auxquelles il doit répondre

Un réviseur ne pilote pas une mission avec une seule information. Il en manipule quatre, et elles
n'appellent pas les mêmes décisions.

| La question | La décision qu'elle commande |
|---|---|
| **Où en est le planning ?** | Faut-il relancer le client, ou décaler l'arrêté |
| **Qui est affecté, et est-ce suffisant ?** | Faut-il désigner quelqu'un, ou en changer |
| **Combien de travail reste-t-il ?** | Faut-il prévoir des jours supplémentaires |
| **La qualité est-elle tenue ?** | Faut-il revoir un travail avant de le viser |

Un outil qui ne répond qu'à la première ne sert qu'à moitié. L'écran de conduite répond aux quatre,
et c'est pour cela qu'il porte autant d'indicateurs.

[Le détail de ce que l'écran montre pour chacune](02-ce-que-voit-le-reviseur.md)

### La trace que la norme professionnelle demande

La mission de présentation relève de la norme professionnelle NP 2300.

**Disons-le sans exagérer :** un outil ne rend pas une mission conforme. La conformité s'apprécie,
et cette appréciation reste au professionnel. Ce que la solution apporte, c'est la **trace**, et
elle l'apporte automatiquement plutôt qu'à la demande :

- chaque réponse d'acceptation est horodatée et attribuée à son auteur ;
- chaque pièce justificative porte sa nature, sa date de dépôt et son déposant, plus une empreinte
  numérique qui prouve qu'elle n'a pas changé ;
- un retrait de pièce exige un motif, et se refuse si la pièce fonde une donnée ;
- l'approbation d'un visa est refusée à la personne qui l'a soumis.

**Ce dernier point mérite d'être compris.** La séparation des fonctions est portée par la base de
données, non par l'écran. Un utilisateur qui contournerait l'écran, par exemple en appelant
directement une fonction, se verrait opposer le même refus. Griser un bouton est une courtoisie ;
le refus, lui, est dans la base.

---

## Le second utilisateur : le client

### Ce qu'il vit aujourd'hui sans la solution

Il reçoit ses comptes annuels quelques mois après la clôture. Entre deux arrêtés, il appelle pour
demander où en sont les choses. La réponse arrive par courriel, dans un tableau refait pour
l'occasion.

### Ce dont il a besoin

Un porteur de parts, une société de gestion ou un directeur financier ne pilotent pas un OPCI une
fois l'an. Il leur faut :

1. **La valeur**, à l'arrêté qui les intéresse, et non au dernier arrêté publié ;
2. **L'explication de la variation**, cause par cause, et non le seul constat qu'elle a eu lieu ;
3. **Le patrimoine et les participations**, avec ce qui fonde chaque valeur ;
4. **Les ratios réglementaires**, avec ce que le calcul retient ;
5. **La distribution**, avec l'obligation minimale et le plafond.

[Le détail des huit pages](03-ce-que-voit-le-client.md)

### La différence entre un tableau de bord et une restitution professionnelle

Beaucoup d'outils branchent un tableau de bord directement sur une base et le disent « en temps
réel ». Le client y lit alors une donnée que personne n'a revue.

**Ici, rien n'arrive sur l'écran du client sans être passé par le visa du cabinet.** C'est plus lent
qu'un branchement direct, et c'est voulu. Le client sait que ce qu'il lit a été revu, et par qui.

C'est la différence entre une donnée brute et une donnée qualifiée. Elle change la nature de la
conversation.

### Ce que l'écran déplace dans la relation

Un client qui lit ses ratios, sa variation de valeur liquidative et son plafond distribuable ne
demande plus où en sont les comptes. Il demande ce que ces chiffres impliquent.

**L'écran déplace la conversation de la production vers le conseil**, qui est le terrain où
l'expert-comptable apporte le plus, et celui qu'il a le moins le temps d'occuper.

---

## Comment les deux besoins se rejoignent

Le point de conception qui tient tout : **une seule base, une seule saisie**.

```
le réviseur saisit et vise  ->  la base  ->  l'écran du client
```

Trois conséquences, et ce sont elles qui font la valeur.

1. **Le cabinet ne refait rien en aval.** La restitution du client n'est pas un livrable à produire
   après la mission : elle est produite par la mission.
2. **Les deux écrans ne peuvent pas se contredire**, puisqu'ils lisent la même donnée.
3. **Le cabinet garde la main** sur ce qui est publié, et sur quand.

---

## Ce que cette conception coûte

Soyons complets : ce choix a un prix, et il vaut mieux le connaître avant.

| Le coût | Ce qu'il implique |
|---|---|
| Le client a besoin d'une licence | Sous une capacité F64, chaque lecteur client doit être licencié. Voir [les licences](05-les-licences.md) |
| La donnée doit être visée pour apparaître | Un dossier non visé laisse l'écran client vide. C'est voulu, mais il faut le dire au client |
| L'installation se fait en trois couches | La synchronisation ne suffit pas. Voir [les trois couches](06-les-trois-couches.md) |

---

Suite : [2. Ce que voit le réviseur](02-ce-que-voit-le-reviseur.md)

[Revenir au sommaire](../../README.md) · [Les douze étapes](../faire/etape-01-ouvrir-la-capacite.md)
