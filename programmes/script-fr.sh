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
	</head>

	<body>
		<table>
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
			</tr>"

ligne=1

while read -r line
do
    data=$(curl -s -i -L -w "%{http_code}\n%{content_type}" -o ./.data.tmp $line)
	http_code=$(echo "$data" | head -1)
	encoding=$(echo "$data" | tail -1 | grep -Po "charset=\S+" | cut -d"=" -f2)
	nbmots=$(cat ./.data.tmp | lynx -dump -nolist -stdin | wc -w)
	nboccurrence=$(cat ./.data.tmp | lynx -dump -nolist -stdin | grep -oiw "regard" | wc -l)

    curl -s -i -L $line > "aspirations/fr-$ligne.html"
    lynx -dump -nolist $line > "dump/fr-$ligne.txt"
    egrep -i -C 4 "regard" "dump/fr-$ligne.txt" > "contextes/fr-$ligne.txt"

    echo -e "			<tr>
				<td>$ligne</td>
				<td>$line</td>
				<td>$http_code</td>
				<td>$encoding</td>
				<td>$nbmots</td>
				<td>$nboccurrence</td>
				<td><a href=\"../aspirations/fr-$ligne.html\">$ligne.html</a></td>
				<td><a href=\"../dump/fr-$ligne.txt\">$ligne.txt</a></td>
				<td><a href=\"../contextes/fr-$ligne.txt\">$ligne.txt</a></td>
			</tr>"


    ligne=$(expr $ligne + 1)
done < $fichier_urls

echo -e "		</table>
	</body>
</html>"
} > "tableaux/fr.html"
