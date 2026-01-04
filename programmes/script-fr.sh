#!/usr/bin/env bash

if [ $# -ne 1 ]
then
	echo "Le script attend exactement un argument"
	exit 1
fi

fichier_urls=$1

{
echo -e "<html>
	<head>
		<meta charset=\"UTF-8\">
		<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css\" />
        <title>Tableau français</title>
	</head>

	<body>
		<div class=\"content has-text-inherit\">
            <div class=\"navbar is-primary\">
                <a href=\"../index.html\" class=\"title is-2 mt-4 ml-4\">\"Regard\" sur Internet</a>
                    <div class=\"navbar-end mr-4\">
                        <div class=\"navbar-item has-dropdown is-hoverable\">
                            <a class=\"navbar-link\">Tableaux</a>
                            <div class=\"navbar-dropdown\">
                                <a href=\"../tableaux/fr.html\" class=\"navbar-item\">Français</a>
                                <a href=\"../tableaux/en.html\" class=\"navbar-item\">Anglais</a>
                                <a href=\"../tableaux/ar.html\" class=\"navbar-item\">Arabe</a>
                            </div>
                        </div>
                    <a href=\"../HTML/script.html\" class=\"navbar-item\">Scripts</a>
                    <div class=\"navbar-item has-dropdown is-hoverable\">
                    <a href=\"../HTML/resultats.html\" class=\"navbar-link\">Résultats</a>
                    <div class=\"navbar-dropdown\">
                        <a href=\"../HTML/resultats-fr.html\" class=\"navbar-item\">Français</a>
                        <a href=\"../HTML/resultats-en.html\" class=\"navbar-item\">Anglais</a>
                        <a href=\"../HTML/resultats-ar.html\" class=\"navbar-item\">Arabe</a>
                    </div>
                </div>
                </div>
            </div>
                    <table class=\"table is-bordered is-hoverable m-6\">
                        <thead class=\"has-background-warning\">
                            <tr>
                                <th>N°</th>
                                <th>URL</th>
                                <th>Code</th>
                                <th>Encodage</th>
                                <th>Nombre de mots</th>
                                <th>Nombre d'occurrence du mot</th>
                                <th>HTML</th>
                                <th>Dump</th>
                                <th>Contexte</th>
                                <th>Concordancier</th>
                            </tr>
                        </thead>"

ligne=1

while read -r line
do
    data=$(curl -s -i -L -w "%{http_code}\n%{content_type}" -o ./.data.tmp $line)
	http_code=$(echo "$data" | head -1)
	encoding=$(echo "$data" | tail -1 | grep -Po "charset=\S+" | cut -d"=" -f2)
	nbmots=$(cat ./.data.tmp | lynx -dump -nolist -stdin | wc -w)
	nboccurrence=$(cat ./.data.tmp | lynx -dump -nolist -stdin | grep -oiw "regard" | wc -l)

    if [ -z "${encoding}" ]
	then
		encoding="N/A"
	fi

    #Aspiration
    curl -s -i -L $line > "aspirations/fr-$ligne.html"

    #Dump
    lynx -dump -nolist $line > "dump-text/fr-$ligne.txt"

    #Contexte sur 4 lignes avant et après le mot
    egrep -i -C 4 "regard" "dump-text/fr-$ligne.txt" > "contextes/fr-$ligne.txt"

    #Concordancier
    mot="[Rr]egard"
    echo -e "<html>
	<head>
		<meta charset=\"UTF-8\">
		<link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css\" />
        <title>Concordancier</title>
	</head>

    <body>
		<div class=\"content has-text-inherit\">
            <div class=\"navbar is-primary\">
                <a href=\"../index.html\" class=\"title is-2 mt-4 ml-4\">\"Regard\" sur Internet</a>
                    <div class=\"navbar-end mr-4\">
                        <div class=\"navbar-item has-dropdown is-hoverable\">
                            <a class=\"navbar-link\">Tableaux</a>
                            <div class=\"navbar-dropdown\">
                                <a href=\"../tableaux/fr.html\" class=\"navbar-item\">Français</a>
                                <a href=\"../tableaux/en.html\" class=\"navbar-item\">Anglais</a>
                                <a href=\"../tableaux/ar.html\" class=\"navbar-item\">Arabe</a>
                            </div>
                        </div>
                    <a href=\"../HTML/script.html\" class=\"navbar-item\">Scripts</a>
                    <div class=\"navbar-item has-dropdown is-hoverable\">
                    <a href=\"../HTML/resultats.html\" class=\"navbar-link\">Résultats</a>
                    <div class=\"navbar-dropdown\">
                        <a href=\"../HTML/resultats-fr.html\" class=\"navbar-item\">Français</a>
                        <a href=\"../HTML/resultats-en.html\" class=\"navbar-item\">Anglais</a>
                        <a href=\"../HTML/resultats-ar.html\" class=\"navbar-item\">Arabe</a>
                    </div>
                </div>
                </div>
            </div>
                <table class=\"table is-bordered is-hoverable m-6\">
                    <thead class=\"has-background-warning\">
                        <tr>
                            <th>Contexte gauche</th>
                            <th>Cible</th>
                            <th>Contexte droit</th>
                        </tr>" > ./concordances/fr-$ligne.html

    grep -o -E ".{0,60}$mot.{0,60}" "./dump-text/fr-$ligne.txt" | \
    sed -E "s/(.*)($mot)(.*)/<tbody><tr><td>\1<\/td><td>\2<\/td><td>\3<\/td><\/tr><\/tbody>/" >> ./concordances/fr-$ligne.html
    echo "</table></div></body></html>" >> ./concordances/fr-$ligne.html

    #Remplissage du tableau
    echo -e "<tbody>
                <tr>
                    <td>$ligne</td>
                    <td>$line</td>
                    <td>$http_code</td>
                    <td class=\"is-uppercase\">$encoding</td>
                    <td>$nbmots</td>
                    <td>$nboccurrence</td>
                    <td><a class=\"has-text-inherit is-underlined\" href=\"../aspirations/fr-$ligne.html\">$ligne.html</a></td>
                    <td><a class=\"has-text-inherit is-underlined\" href=\"../dump-text/fr-$ligne.txt\">$ligne.txt</a></td>
                    <td><a class=\"has-text-inherit is-underlined\" href=\"../contextes/fr-$ligne.txt\">$ligne.txt</a></td>
                    <td><a class=\"has-text-inherit is-underlined\" href=\"../concordances/fr-$ligne.html\">$ligne.html</a></td>
                </tr>
            </tbody>"


    ligne=$(expr $ligne + 1)
done < $fichier_urls

echo -e "</table>
        </div>
    </body>
</html>"
} > "tableaux/fr.html"
