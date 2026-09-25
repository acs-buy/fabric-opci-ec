# 4. Après la synchronisation : ce qui est là, et ce qui ne marche pas encore

## Ramener les éléments

Dans le panneau de contrôle de source de votre espace de travail, cliquez sur **Mettre à jour
tout**. Fabric crée les éléments de la solution dans votre espace.

![Le panneau de contrôle de source](../../captures/controle-de-source.png)

*Le panneau s'ouvre par le bouton **Source control** du bandeau. Il affiche la branche connectée et
les éléments à ramener.*

## Ce que vous devez voir

| Élément | Type | Ce qu'il porte |
|---|---|---|
| Coffre | Lakehouse | Les pièces justificatives et les gabarits |
| DossierOPCI | Base de données SQL | Les tables, vues, procédures et contrôles |
| fn_ecran_client | Fonctions | Ce que les boutons de l'écran de conduite appellent |
| fn_ecran_revision | Fonctions | Ce que les boutons de l'écran de révision appellent |
| conduite_de_mission | Modèle sémantique | Les 72 tables et les mesures de l'écran de travail |
| Conduite de mission | Rapport | L'écran de travail du cabinet |
| restitution_client | Modèle et rapport | L'écran remis au client |

## À ce stade, rien ne fonctionne, et c'est normal

C'est le moment où l'on croit que l'installation a échoué. Elle n'a pas échoué : elle n'est pas
finie. Voici précisément où en sont les choses.

**La base existe mais elle est vide.** Ses tables, ses vues et ses procédures sont là, mais aucune
donnée. L'éditeur l'écrit : « Git Integration re-creates item definitions only and does not restore
item data. » Les données arrivent à l'étape 5.

**Le modèle interroge encore la base d'origine.** Si vous l'ouvrez maintenant, il ne s'actualisera
pas. C'est attendu, et c'est réparé à l'étape 6.

**Les boutons appellent encore les fonctions d'origine.** Si vous ouvrez le rapport et cliquez, il
ne se passera rien. C'est attendu, et c'est réparé à l'étape 6 également.

**Les fonctions n'ont pas encore le droit de parler à la base.** Leur connexion se pose à la main,
à l'étape 5.

## Ce que vous pouvez vérifier utilement dès maintenant

Ouvrez la base `DossierOPCI` et lancez cette requête dans une nouvelle requête :

```sql
SELECT type_desc, COUNT(*) AS nb
  FROM sys.objects
 WHERE is_ms_shipped = 0
 GROUP BY type_desc
 ORDER BY type_desc;
```

Vous devez y trouver des tables, des vues, des procédures stockées et des déclencheurs. Si la
requête ne rend rien, la synchronisation n'a pas abouti : reprenez l'étape 3 et vérifiez le
répertoire `fabric`.

Suite : [5. Charger les données](etape-07-charger-les-donnees.md)
