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
    
    echo -e "			<tr>
				<td>$lineno</td>
				<td>$line</td>
				<td>$http_code</td>
				<td>$encoding</td>
				<td>$nbmots</td>
				<td>$nboccurrence</td>
				<td><a href=\"../aspirations/en-$lineno.html\">$lineno.html</a></td>
				<td><a href=\"../dump-text/en-$lineno.txt\">$lineno.txt</a></td>
				<td><a href=\"../contextes/en-$lineno.txt\">$lineno.txt</a></td>
			</tr>"
    
    
    lineno=$(expr $lineno + 1)
done < $fichier_urls

echo -e "		</table>
	</body>
</html>"
} > "tableaux/en.html"
