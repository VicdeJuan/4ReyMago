#!/bin/zsh

ltxmk () {
	latexmk -shell-escape -synctex=1 -pdf -silent -interaction=nonstopmode $@
}



groupFile=$1   # Ficheros con los integrantes del grupo.
restFile=$2    # Ficheros de restricciones.
output=$3      # Nombre del fichero resumen.
outDir=$4      # Carpeta donde almacenar todo.
outputdir=$5   #.Carpeta resumen a comprimir.



echo "Limpiando..."
rm  -r $4/*
echo "Generando src..."
ruby 4ReyMago_simple.rb $@ || exit 1


cd $4
echo "Compilando..."
ltxmk >> "../.log"
echo "Mergeando..."
/usr/bin/convert *.pdf todos.pdf
echo "Procesado para imprimir:"
echo "   Separando pares e impares..."
pdftk todos.pdf cat 1-endeven output out.even.pdf
pdftk todos.pdf cat 1-endodd output out.odd.pdf
echo "   2 págnias por hoja"
pdfnup out.even.pdf
pdfnup out.odd.pdf
echo "   Burst..."
pdftk out.odd-nup.pdf burst output %04d_A.pdf
pdftk out.even-nup.pdf burst output %04d_B.pdf
echo "   Generando el pdf para dominarlos a todos..."
pdftk 0*_*.pdf cat output toprint$1.pdf

echo "   Clean..."
mkdir trash
mv 0*_*.pdf trash
mv out.*.pdf trash

cd ..
echo "Generando resúmenes..."
cd $4/tex
ltxmk >> ".log" 2&> /dev/null
cd ../..


mkdir $outputdir

cp $4/tex/*.pdf $outputdir
cp $4/toprint$1.pdf $outputdir

mkdir $outputdir/pdfsIndividuales

cp $4/*.pdf $outputdir/pdfsIndividuales
rm $outputdir/pdfsIndividuales/todos.pdf $outputdir/pdfsIndividuales/toprint$1.pdf


zip -rv $outputdir".zip" $outputdir

