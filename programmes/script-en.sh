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
        <title>Tableau</title>
	</head>

	<body>
		<div class=\"content has-text-inherit\">
            <div class=\"has-background-primary navbar\">
                <a href=\"../index.html\" class=\"title is-2 mt-4 ml-4\">\"Regard\" sur Internet</a>
                    <div class=\"navbar-end mr-4\">
                        <div class=\"navbar-item has-dropdown is-hoverable\">
                            <a class=\"navbar-link\">Tableaux</a>
                            <div class=\"navbar-dropdown\">
                                <a href=\"\" class=\"navbar-item\">Français</a>
                                <a href=\"../tableaux/en.html\" class=\"navbar-item\">Anglais</a>
                                <a href=\"\" class=\"navbar-item\">Arabe</a>
                            </div>
                        </div>
                    <a class=\"navbar-item\">Scripts</a>
                    <a class=\"navbar-item\">Résultats</a>
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
	nboccurrence=$(cat ./.data.tmp | lynx -dump -nolist -stdin | grep -oiw "gaze" | wc -l)
    
    curl -s -i -L $line > "aspirations/en-$lineno.html"
    lynx -dump -nolist $line > "dump-text/en-$lineno.txt"
    egrep -i -C 4 "gaze" "dump-text/en-$lineno.txt" > "contextes/en-$lineno.txt"
    
    echo -e "<tbody>
                <tr>
                    <td>$lineno</td>
                    <td>$line</td>
                    <td>$http_code</td>
                    <td>$encoding</td>
                    <td>$nbmots</td>
                    <td>$nboccurrence</td>
                    <td><a class=\"has-text-inherit is-underlined\" href=\"../aspirations/en-$lineno.html\">$lineno.html</a></td>
                    <td><a class=\"has-text-inherit is-underlined\" href=\"../dump-text/en-$lineno.txt\">$lineno.txt</a></td>
                    <td><a class=\"has-text-inherit is-underlined\" href=\"../contextes/en-$lineno.txt\">$lineno.txt</a></td>
                </tr>
            </tbody>"
    
    
    lineno=$(expr $lineno + 1)
done < $fichier_urls

echo -e "</table>
        </div>
    </body>
</html>"
} > "tableaux/en.html"
