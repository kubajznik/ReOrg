# v171213

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
# Vorgabe: read_email
#########################################
# $a0: buffer
# $v0: number of characters read

read_email:
    move $t0, $a0

    # read mail from disk
    li $v0, 13
    la $a0, input_file
    li $a1, 0
    li $a2, 0
    syscall

    # save fd
    move $t1, $v0

    # read to buffer
    li $v0, 14
    move $a0, $t1
    move $a1, $t0 # address of buffer
    li $a2, 4096
    syscall

    move $t0, $v0

    # close file
    li $v0, 16
    move $a0, $t1 # fd
    syscall

    move $v0, $t0

    jr $ra


#########################################
# Aufgabe 1: E-Mail parsen
#########################################
# v0: relative position of subject
# v1: relative begin of body

parse_email:
	
    ### Register gemass Konventionen sichern

	##move $s7, $ra # Ruecksprungadresse sichern
	
	addi $sp, $sp, -4
    sw $ra, 0($sp)
	
    ### E-Mail in Puffer einlesen (0.5 Punkte)
	
	la $a0, email_buffer
	jal read_email
	
    ### Position des Subjektes bestimmen (1 Punkt)
	
	la $a0, email_buffer			# Email laden
	move $a1, $a2					# Laenge der Email
	la $a2, header_subject			# zu suchenden String laden
	lw $a3, header_subject_length	# Laenge des zu suchenden String
	jal find_str 					# in $v0 kommt Position vom Subject
	addi $v0, $v0, 9 				# 9 Addieren wegen der Laenge des Suchkriteriums
	move $s8, $v0					# Ergebnis sichern wegen nochmaligem Aufruf von find_str

	### Position des Endes des Headers bestimmen (1 Punkt)
	
	la $a0, email_buffer		# Email neu laden
	la $a2, header_end			# zu suchenden String laden	
	lw $a3, header_end_length	# Länge des zu suchenden String
	jal find_str				# String suchen, kommt in $v0 zurueck
	addi $v0, $v0, 4			# 4 Addieren wg Laenge des Suchkriteriums
	
    ### Rueckgabewerte bereitstellen (0.5 Punkte)

	move $v1, $v0	# Letzte Ausgabe in $v0 ist Position vom Ende des Header
	move $v0, $s8	# in $s8 ist Position von Subject gespeichert
	
    ### Register wieder herstellen
	
	lw $ra, 0($sp)
    addi $sp, $sp, 4 

    jr $ra

#########################################
# Aufgabe 1 Ende
#########################################

#########################################
# data

.data

input_file: .asciiz "../email1"
email_buffer: .space 4096
size: .word 0

header_subject: .asciiz "Subject: "
header_subject_length: .word 9

header_end: .byte 13, 10, 13, 10
header_end_length: .word 4

subject_pos: .asciiz "Position Subjekt: "
text_pos: .asciiz "Position Text: "

#
# main
#

.text
.globl main

main:
    # Register sichern
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)

    jal parse_email

	# Position Subjekt sichern
    move $s0, $v0
    # Position Ende Header sichern
    move $s1, $v1

    # Ausgabe
    la $a0, subject_pos
    li $v0, 4
    syscall

    move $a0, $s0
    li $v0, 1
    syscall

    li $a0, 10
    li $v0, 11
    syscall

    la $a0, text_pos
    li $v0, 4
    syscall

    move $a0, $s1
    li $v0, 1
    syscall

    li $a0, 10
    li $v0, 11
    syscall
    
    # Register wieder herstellen
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra

#
# end main
#
