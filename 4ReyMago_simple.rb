#!/usr/bin/ruby
require 'digest'

TEMPLATE = "template.tex"



#######################################
#######################################
###### PROCESAMIENTO PREVIO ###########
#######################################
#######################################

def readGroup(groupFile)
	group=[]
	File.foreach(groupFile) {|x| 
		group << x.chomp(",\n")
	}
	return group
end

# Lee restricciones bidireccionales. A no regala a B ni viceversa. 
# 1 restricción por linea en el archivo.

def readRestrictions(restFile)
	restrictions = {}
	File.foreach(restFile) {|x| 
		r = x.chomp("\n").split(",")
		for i in 0..1
			if restrictions[r[i]] == nil
				restrictions[r[i]] = Array.new(1,r[(i+1)%2])
				
			else
				restrictions[r[i]] << r[(i+1)%2]
			end
		end
	}
	return restrictions
end


#######################################
#######################################
###########     SORTEO      ###########
#######################################
#######################################


def escribirDocumento(regalador,regalado,outputDir)
	towrite = File.open(outputDir + "/" + regalador + ".tex" ,"w")

	File.foreach( TEMPLATE ) do |line|
		tow = line.sub('Regalador',regalador)
  		tow = tow.sub('Regalado',regalado)
  		towrite.puts tow
	end	
	towrite.close
end


def sorteo(chavales,outputDir)
	n = chavales.size
	msg = "%s \& %s \\\\ \n"
	regalados=0
	regaladores=0

	output = "
\\documentclass{article}
\\usepackage[utf8]{inputenc}
\\begin{document}

\\begin{tabular}{ll}\n\\textbf{Eres} & \\textbf{Regalas a}\\\\ \\hline\n"
	for i in 0..n-1
		regalador = chavales[i]
		regalado = chavales[(i+1)%n]

		if (chavales.include? regalado)
			regalados+=1
		else
			print regalado," no pertenece a chavales\n"
		end
		if (chavales.include? regalador)
			regaladores+=1
		else
			print regalador," no pertenece a chavales\n"
		end

		#print
		p = sprintf msg,regalador,regalado
		escribirDocumento(regalador,regalado,outputDir)
		output.concat p
		#print p

	end
	output.concat "\\end{tabular}\\end{document}"

	
	return output
end

# Devuelve OK si está OK, false si hay que rehacer.
def comprobarRestricciones(chavales,restricciones)
	n = chavales.size
	for i in 0..n-1
		if (restricciones[chavales[i]] != nil)
			if (restricciones[chavales[i]].include?(chavales[(i+1)%n]))
				return false;
			end
		end
	end
	return true
end

def creacionFicheros(grupo,fichero,restricciones,outputDir)
	chavales = grupo.shuffle

	while (not comprobarRestricciones(chavales,restricciones))
		print "Rehaciendo grupos por restricciones\n"
		chavales = grupo.shuffle
	end

	toprint = sorteo(chavales,outputDir)
	file = File.open(fichero,"w")	
	file.puts toprint.encode('utf-8')

	file.close
end


if ARGV.size < 4
	puts "ERROR. Número incorrecto de argumentos"
	puts "ruby 4ReyMago_simple.rb f_nombres f_restricciones f_output outDir"
	exit(-1)
else
	grupo = []
	ARGV[0].split(",").each {|group|
		grupo << readGroup(group)
	}

	restricciones = []
	ARGV[1].split(",").each {|rest|
		restricciones << readRestrictions(rest)
	}

	resumen = []
	ARGV[2].split(",").each {|resumenFile|
		resumen << resumenFile
	}

	if grupo.size != restricciones.size or  restricciones.size != resumen.size or resumen.size != grupo.size
		puts "ERROR. Tengo más grupos que restricciones. "
		exit(-1)
	end

	
	outputDir = ARGV[3]
	src = "".concat(outputDir) << "/tex/"
	system('mkdir '.concat src)

	for i in 0..(grupo.size-1)
		creacionFicheros(grupo[i],src + resumen[i],restricciones[i],outputDir)
	end

end

#creacionFicheros(grupoAna,f_grupoAna,restriccionesAna)
#creacionFicheros(grupoGuille,f_grupoGuille,restriccionesGuille)

