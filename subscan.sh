#!/bin/bash

# author R3DHULK
# records rius

# Membuat direktori sementara untuk menyimpan hasil scan
WORKDIR=$(mktemp -d)
cd "$WORKDIR"
echo "Berpindah ke direktori kerja sementara: $WORKDIR"

touch tmp.txt
echo " "
echo " #==================================#"
echo " #      __- SUBDOMAIN SCAN -__      #"
echo " #==================================#"
echo " "
echo " "
echo " [•] loading.."
echo " "
echo " " 

# Menjalankan proses pencarian subdomain
touch tmp.txt
curl --silent --insecure --tcp-fastopen --tcp-nodelay "https://rapiddns.io/subdomain/$1?full=1#result" | grep "<td><a" | cut -d '"' -f 2 | grep http | cut -d '/' -f3 | sed 's/#results//g' | sort -u >> tmp.txt &
curl --silent --insecure --tcp-fastopen --tcp-nodelay "http://web.archive.org/cdx/search/cdx?url=*.$1/*&output=text&fl=original&collapse=urlkey" | sed -e 's_https*://__' -e "s/\/.*//" | sort -u >> tmp.txt &
curl --silent --insecure --tcp-fastopen --tcp-nodelay https://crt.sh/?q=%.$1  | grep -oP "\<TD\>\K.*\.$1" | sed -e 's/\<BR\>/\n/g' | grep -oP "\K.*\.$1" | sed -e 's/[\<|\>]//g' | grep -o -E "[a-zA-Z0-9._-]+\.$1"  >> tmp.txt &

# Tunggu semua proses selesai
wait

# Menyimpan hasil ke file atau menampilkan di terminal
if [[ $# -eq 2 ]]; then
    cat tmp.txt | sed -e "s/\*\.$1//g" | sed -e "s/^\..*//g" | grep -o -E "[a-zA-Z0-9._-]+\.$1" | sort -u > $2
else
    cat tmp.txt | sed -e "s/\*\.$1//g" | sed -e "s/^\..*//g" | grep -o -E "[a-zA-Z0-9._-]+\.$1" | sort -u
fi

# Bersihkan direktori sementara
echo "Membersihkan direktori sementara..."
rm -rf "$WORKDIR"
echo " "
echo "gunakan tools ini dengan bijak!! "
echo " "
