# v180105

#########################################
# Vorgabe: find_str
#########################################
# $a0: haystack
# $a1: len of haystack
# $a2: needle
# $a3: len of needle
# $v0: relative position of needle, -1 if not found

find_str:
    # save $ra on stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # save beginning of haystack
    move $t5, $a0
    # save len of needle
    move $t4, $a3

    # calc end address of haystick and needle
    add $a1, $a1, $a0
    add $a3, $a3, $a2

haystick_loop:
    bge $a0, $a1, haystick_loop_end

    move $t6, $a0
    move $t7, $a2
needle_loop:
    # load char from haystick
    lbu $t0, 0($t6)
    # load char from needle
    lbu $t1, 0($t7)

    bne $t0, $t1, needle_loop_end

    addi $t6, $t6, 1
    addi $t7, $t7, 1

    # reached end of needle
    bge $t7, $a3, found_str

    # reached end of haystick
    bge $t6, $a1, found_nostr

    j needle_loop
needle_loop_end:

    addi $a0, $a0, 1
    j haystick_loop
haystick_loop_end:

found_nostr:
    # prepare registers so found_str: produces -1
    li $t6, 0
    li $t5, 0
    li $t4, 1

found_str:
    sub $v0, $t6, $t5
    sub $v0, $v0, $t4


    # restore $ra from stack
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

#########################################
# Aufgabe 2: Spamfilter
#########################################
# $v0: Spamscore

spamfilter:
    ### Register gemaess Registerkonventionen sichern
	
	#addi $sp, $sp, -12
	#sw $ra, 0($sp)
	move $fp, $ra
    
	### Badwords liegen im Puffer badwords_buffer
    ### Der Text der E-Mail liegt im Puffer email_buffer
   
    ### Schleife ueber Bad words (wort1,gewicht1,wort2,gewicht2,...)
	la $a0, badwords_buffer
	lw $a1, badwords_size
	
	bigfor:
		move $s7, $a1			# Aktuelle Laenge der Liste sichern
	
		bltz $s7, endbigfor		# Wenn Badwordlistenlaenge -1 (=passiert nach dem letzten Wort, weil kein Komma am Ende der Liste), Schleife abbrechen
				
		la $a2, badwords_sep	# Trennzeichen ist immer Komma
		li $a3, 1				# Kommalaenge ist immer 1
		
		### lese ein Wort
		jal find_str			# Komma finden, Position in $v0
		move $s1, $v0			# Needlelaenge sichern
		move $t8, $a0
		
		### lese und konvertiere Gewicht
		addi $a0, 1
		move $a1, $s7
		sub $a1, $a1, $s1
		la $a2, badwords_sep	# Trennzeichen ist immer Komma
		li $a3, 1	
		jal find_str
		move $t7, $v0
				move $a0, $t7
				li $v0, 1
				syscall
				
				la $a0, badwords_sep
				li $v0, 4
				syscall		
		move $v0, $t7
		
		li $t9, 1
		bgt $v0, $t9, zweistellig
		
		move $a0, $t8
		lb $s2, 1($a0)
		addi $s2, -48 			# in int umrechnen
		j weiter
		
		zweistellig:
			move $a0, $t8
			lb $s2, 1($a0)
			addi $s2, -48 			# in int umrechnen
			li $t9, 10
			mult $s2, $t9
			mflo $s2
			
			lb $t9, 2($a0)
			addi $t9, -48
			
				move $a0, $t9
				li $v0, 1
				syscall
				
				la $a0, badwords_sep
				li $v0, 4
				syscall
			
			
			#add $s2, $s2, $t9
		weiter:
		
		
		
		move $a0, $t8
		
		### suche alle Vorkommen des Wortes im Text der E-Mail und addiere Gewicht
		sub $a0, $a0, $s1		# Adresse in $a0 wieder auf Anfang schieben 
		move $s4, $a0			# Adresse von Needle fuer Schleife speichern
		
		la $a0, email_buffer	# Adresse von E-Mail
		lw $a1, size			# Laenge von E-Mail
		move $a2, $s4			# Adresse der Needle
		move $a3, $s1			# Laenge von Needle
		
		for:
			move $s5, $a0			# Neue Startadresse sichern
			move $s6, $a1			# Neue Laenge sichern

			jal find_str			# Nach Badword suchen
			
			bltz $v0, endfor		# Wenn keins gefunden, abbrechen
			
			add $s3, $s3, $s2		# Sonst Gewicht addieren
			
			move $a0, $s5			# Letzte Startadresse laden
			add $a0, $a0, $v0		# Dazu ueberlesene Textlaenge addieren
			addi $a0, 1				# +1, um nicht das gefundene Wort wieder zu finden
			
			move $a1, $s6			# Letzte Textlaenge laden
			sub $a1, $a1, $v0		# Davon die ueberlesene Textlaenge abziehen
			addi $a1, -1			# -1 wegen der +1 oben
			
			move $a2, $s4			# Adresse der Needle
			move $a3, $s1			# Laenge der Needle
			
			j for
		endfor:
		
		move $a0, $s4			# Adresse des letzten Wortes einlesen
		add $a0, $a0, $s1		# Wortlaenge dazuaddieren
		li $s6, 3				# Komma, Zahl, Komma = 3 Stellen
		add $a0, $a0, $s6		#  und diese dazuaddieren
		
		move $a1, $s7			# Letzte Listenlaenge laden
		sub $a1, $a1, $s1		# Davon die Wortlaenge abziehen
		sub $a1, $a1, $s6		# Und nochmal 3 abziehen; Komma,Zahl,Komma
		
		j bigfor
	endbigfor:	
		
	### Rueckgabewert setzen
	move $v0, $s3
		
    ### Register wieder herstellen
    move $ra, $fp
	
	jr $ra

	
#########################################
#

#
# data
#

.data

email_buffer: .asciiz "Hochverehrte Empfaenger,\n\nbei dieser E-Mail handelt es sich nicht um Spam sondern ich moechte Ihnen\nvielmehr ein lukratives Angebot machen: Mein entfernter Onkel hat mir mehr Geld\nhinterlassen als in meine Geldboerse passt. Ich muss Ihnen also etwas abgeben.\nVorher muss ich nur noch einen Spezialumschlag kaufen. Senden Sie mir noch\nheute BTC 1,000 per Western-Union und ich verspreche hoch und heilig Ihnen\nalsbald den gerechten Teil des Vermoegens zu vermachen.\n\nHochachtungsvoll\nAchim Mueller\nSekretaer fuer Vermoegensangelegenheiten\n"

size: .word 538

badwords_buffer: .asciiz "Spam,5,Geld,1,ROrg,10,lukrativ,3,Kohlrabi,1,Weihnachten,3,Onkel,7,Vermoegen,2,Brief,4,Lotto,3"
badwords_size: .word 92

badwords_sep: .asciiz ","

spamscore_text: .asciiz "Der Spamscore betraegt: "

#
# main
#

.text
.globl main

main:
    # Register sichern
    addi $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s0, 4($sp)


    jal spamfilter
    move $s0, $v0


    li $v0, 4
    la $a0, spamscore_text
    syscall
    move $a0, $s0
    li $v0, 1
    syscall

    li $v0, 11
    li $a0, 10
    syscall


    # Register wieder herstellen
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    addi $sp, $sp, 8
    jr $ra

#
# end main
#
