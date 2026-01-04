#!/usr/bin/env bash

if [ $# -ne 1 ]
then
    echo "Le script attend exactement un argument"
    exit 1
fi

fichier_urls=$1

{
echo "<html>
    <head>
        <meta charset=\"UTF-8\">
        <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.4/css/bulma.min.css\" />
        <title>Tableau Arabe</title>
    </head>

    <body>
        <div class=\"content has-text-inherit\">
            <div class=\"has-background-primary navbar\">
                <a href=\"../index.html\" class=\"title is-2 mt-4 ml-4\">\"Regard\" sur Internet (Arabe)</a>
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
                    </tr>
                </thead>"

lineno=1

while read -r line
do
    data=$(curl -s -i -L -w "%{http_code}\n%{content_type}" -o ./.data.tmp $line)
	http_code=$(echo "$data" | head -1)
	encoding=$(echo "$data" | tail -1 | grep -Po "charset=\S+" | cut -d"=" -f2)
	nbmots=$(cat ./.data.tmp | lynx -dump -nolist -stdin | wc -w)
	nboccurrence=$(cat ./.data.tmp | lynx -dump -nolist -stdin | grep -oiw "نظر" | wc -l)

    if [ -z "${encoding}" ]
	then
		encoding="N/A"
	fi

    #Aspiration
    curl -s -i -L $line > "aspirations/ar-$lineno.html"

    #Dump
    lynx -dump -nolist $line > "dump-text/ar-$lineno.txt"

    #Contexte sur 4 lignes avant et après le mot
    egrep -i -C 4 "نظر" "dump-text/ar-$lineno.txt" > "contextes/ar-$lineno.txt"

    #Concordancier
    mot="نظر"
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
                        </tr>" > ./concordances/ar-$lineno.html

    grep -o -E ".{0,60}$mot.{0,60}" "./dump-text/ar-$lineno.txt" | \
    sed -E "s/(.*)($mot)(.*)/<tbody><tr><td>\1<\/td><td>\2<\/td><td>\3<\/td><\/tr><\/tbody>/" >> ./concordances/ar-$lineno.html
    echo "</table></div></body></html>" >> ./concordances/ar-$lineno.html

    #Remplissage du tableau
    echo -e "<tbody>
                <tr>
                    <td>$lineno</td>
                    <td>$line</td>
                    <td>$http_code</td>
                    <td class=\"is-uppercase\">$encoding</td>
                    <td>$nbmots</td>
                    <td>$nboccurrence</td>
                    <td><a class=\"has-text-inherit is-underlined\" href=\"../aspirations/ar-$lineno.html\">$lineno.html</a></td>
                    <td><a class=\"has-text-inherit is-underlined\" href=\"../dump-text/ar-$lineno.txt\">$lineno.txt</a></td>
                    <td><a class=\"has-text-inherit is-underlined\" href=\"../contextes/ar-$lineno.txt\">$lineno.txt</a></td>
                    <td><a class=\"has-text-inherit is-underlined\" href=\"../concordances/ar-$lineno.html\">$lineno.html</a></td>
                </tr>
            </tbody>"


    lineno=$(expr $lineno + 1)
done < $fichier_urls

echo -e "</table>
        </div>
    </body>
</html>"
} > "tableaux/ar.html"
