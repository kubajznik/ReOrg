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

	

	### lese ein Wort
	la $a0, badwords_buffer
	lw $a1, badwords_size
	la $a2, badwords_sep
	li $a3, 1	
	jal find_str				# Komma finden, Position in $v0
		
	sub $a0, $a0, $v0
	
	move $a2, $a0
	la $a0, email_buffer
	lw $a1, size
	move $a3, $v0
	
	jal find_str
	
		### lese und konvertiere Gewicht
		
		#addi $a0, 1
		
		#lb $t1, ($a0)			# Gewicht laden
				
		#addi $t1, -48		# In int umrechnen
				
		#sub $t2, $t2, $v0
		#addi $t2, -1
		#move $a1, $t2
		
        ### suche alle Vorkommen des Wortes im Text der E-Mail und addiere Gewicht
		
	#	bltz $v0, endfor
	#j for
	#endfor:
    #move $v0, $s5
	
	### Rueckgabewert setzen
	
	
	
    ### Register wieder herstellen
    
	#lw $ra, 0($sp)
	#addi $sp, $sp, 12
	
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

badwords_buffer: .asciiz "Spam,5,Geld,1,ROrg,0,lukrativ,3,Kohlrabi,10,Weihnachten,3,Onkel,7,Vermoegen,2,Brief,4,Lotto,3"
badwords_size: .word 93

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
