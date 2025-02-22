# Import des données

Cette boite de dialogue permet de réaliser un **import de données EDIGEO et MAJIC**.

![alt](../media/cadastre_import_dialog.png)


## Principe

Le plugin permet l'import de données **MAJIC de 2012 à 2021 et des données EDIGEO**. Il est possible 
d'importer des données de manière incrémentale, **étape par étape**, ou bien d'importer **en une seule fois**.

Le plugin utilise pour cela la notion de **lot**. Un lot regroupe un **ensemble de données cohérent** pour 
votre utilisation. Par exemple, le lot peut être le code d'une commune, ou l'acronyme d'une communauté de 
commune. C'est une chaîne de 10 caractères maximum. Vous pouvez utiliser des chiffres ou des lettres.

Vous pouvez par exemple importer les données dans cet ordre :

* données EDIGEO de la commune A, lot "com_a"
* données EDIGEO de la commune B, lot "com_b"
* données MAJIC de la commune A, lot "com_a"
* données EDIGEO de la commune A, lot "com_a" (ré-import et écrasement des données précédentes)
* données EDIGEO de la commune C, lot "com_c"

Il est donc important de conserver une liste des lots définis pendant les imports successifs, pour savoir 
ensuite quel lot utiliser si on souhaite écraser des données. Une version prochaine du plugin pourra intégrer
un tableau récapitulatif des imports effectués dans une base de données pour faciliter le suivi des imports 
réalisés.


> Il est conseillé d'importer des données de millésime différents dans des bases de données ou des schémas 
> PostGreSQL différents, car la structure peut changer d'un millésime à l'autre (ajout de colonnes, 
> modification de longueur de champs, etc).

## Bases de données

Deux **Systèmes de Gestion de Bases de Données** (SGBD) sont supportés par le plugin Cadastre :

* **PostGreSQL** et son extension spatiale **PostGIS**
* **SQLite** et son extension spatiale **Spatialite**

Nous conseillons d'utiliser PostGreSQL pour des données volumineuses et pour gérer des accès multiples à la 
base de données.

Pour les bases de données **PostGIS**, il faut :

* avoir créé **une base de données** sur laquelle on a les droits en écriture, et activer l'extension PostGIS.
* avoir créé au préalable **une connexion QGIS** via le menu **Couches > Ajouter une couche PostGIS** vers 
  cette base de données

Pour les bases de données **Spatialite**, l'interface d'import permet de créer une base de données vide et la 
connexion QGIS liée si nécessaire.

### Remarque sur les contraintes

Il n'existe actuellement aucune contrainte de clés étrangères sur les tables du schéma cadastre. Nous 
proposerons à l'avenir un script qui permettra de les créer, lorsque les données le permettent (ce qui n'est 
pas toujours le cas, comme des voies non référencées dans `voie` mais référencées dans `parcelle`).

## Les étapes d'importation

Pour lancer l'importation, il faut bien avoir au préalable configuré les noms des fichiers MAJIC via le menu 
**Configurer le plugin**. Ensuite, on ouvre la boite de dialogue

* via la **barre d'outil Cadastre**, icône base de données
* via le menu **Cadastre > Importer des données**

On configure ensuite les options :

* Choisir **le type de base de données** : PostGIS ou Spatialite
* Choisir **la connexion**

    - Pour Postgis, on peut ensuite **choisir un schema**, ou en **créer un nouveau**
    - Pour Spatialite, on peut **créer une nouvelle base de données**

* Choisir le répertoire contenant les **fichiers EDIGEO** :

 - On peut sélectionner le **répertoire parent** qui contient l'ensemble des sous-répertoires vers les 
   communes : le plugin ira chercher les fichiers de manière récursive.
 - Seuls les fichiers **zip** et **tar.bz2** sont pour l'instant gérés

* Choisir la **projection source** des fichiers EDIGEO et la **projection cible** désirée

* Choisir le **numéro du Département**, par exemple : 80 pour la Somme
* Choisir le **numéro de la Direction**, par exemple : 0

* Choisir le répertoire contenant **les fichiers MAJIC**

    - Comme pour EDIGEO, le plugin ira chercher les fichiers dans les répertoires et les sous-répertoires et 
      importera l'ensemble des données.
    - Si vous ne possédez pas les données FANTOIR dans votre jeu de données MAJIC, nous conseillons vivement 
      de les télécharger et de configurer le plugin pour donner le bon nom au fichier FANTOIR : 
      https://www.collectivites-locales.gouv.fr/competences/la-mise-disposition-gratuite-du-fichier-des-voies-et-des-lieux-dits-fantoir

* Choisir la **version du format** en utilisant les flèches haut et bas

    - Seuls les formats de 2012 à 2021 sont pris en compte

* Choisir le **millésime des données**, par exemple 2021

* Choisir le **Lot** : utilisez par exemple le code INSEE de la commune.

* Activer ou désactiver la case à cocher **Corriger les géométries invalides** selon la qualité de votre jeu 
  de données EDIGEO.

* Utiliser la barre de défilement de la fenêtre pour aller tout en bas et afficher tout le bloc texte de log 
  situé sous la barre de progression.

* Lancer l'import en cliquant sur le bouton **Lancer l'import**


Le déroulement de l'import est écrit dans le bloc texte situé en bas de la fenêtre.

> Pendant l'import, il est conseillé de ne pas déplacer ou cliquer dans la fenêtre. Pour l'instant, le plugin
> n'intègre pas de bouton pour annuler un import en cours.


## Projections IGNF

Si votre donnée EDIGEO est en projection IGNF, par exemple pour la Guadeloupe, IGNF:GUAD48UTM20 (Guadeloupe 
Ste Anne), et que vous souhaitez importer les données dans PostgreSQL, il faut au préalable ajouter dans votre
table public.spatial_ref_sys la définition de la projection IGNF. Si vous utilisez à la place l'équivalent 
EPSG (par exemple ici EPSG:2970), vous risquez un décalage des données lors de la reprojection.

Vous pouvez ajouter dans votre base de données la définition via une requête, par exemple avec la requête 
suivante pour IGNF:GUAD48UTM20:

```
INSERT INTO spatial_ref_sys values (
    998999,
    'IGNF',
    998999,
    'PROJCS["Guadeloupe Ste Anne",GEOGCS["Guadeloupe Ste Anne",DATUM["Guadeloupe St Anne",SPHEROID["International-Hayford 1909",6378388.0000,297.0000000000000,AUTHORITY["IGNF","ELG001"]],TOWGS84[-472.2900,-5.6300,-304.1200,0.4362,-0.8374,0.2563,1.898400],AUTHORITY["IGNF","REG425"]],PRIMEM["Greenwich",0.000000000,AUTHORITY["IGNF","LGO01"]],UNIT["degree",0.01745329251994330],AXIS["Longitude",EAST],AXIS["Latitude",NORTH],AUTHORITY["IGNF","GUAD48GEO"]],PROJECTION["Transverse_Mercator",AUTHORITY["IGNF","PRC0220"]],PARAMETER["semi_major",6378388.0000],PARAMETER["semi_minor",6356911.9461],PARAMETER["latitude_of_origin",0.000000000],PARAMETER["central_meridian",-63.000000000],PARAMETER["scale_factor",0.99960000],PARAMETER["false_easting",500000.000],PARAMETER["false_northing",0.000],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["IGNF","GUAD48UTM20"]]',
    '+init=IGNF:GUAD48UTM20'
);
```

Attention, il est important d'utiliser un code qui est <= 998999, car PostGIS place des contraintes sur le 
SRID. Nous avons utilisé ici 998999, qui est le maximum possible.
La liste des caractéristiques des projections peut être trouvée à ce lien : 
http://librairies.ign.fr/geoportail/resources/IGNF-spatial_ref_sys.sql (voir discussion Géorézo : https://georezo.net/forum/viewtopic.php?pid=268134).
Attention, il faut extraire de ce fichier la commande INSERT qui correspond à votre code IGNF, et remplacer le
SRID par 998999.

Ensuite, dans la projection source, vous pouvez utiliser IGNF:GUAD48UTM20 au lieu du code EPSG correspondant.
