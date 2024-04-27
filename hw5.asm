.data
	space_macro: .asciiz " "
	nextline_macro: .asciiz "\n"
.text

init_student: # a0 is id, a1 is credits, a2 is name, a3 is record
    sll $a0, $a0, 10    # Shift student id by 10 bits
    andi $a1, $a1, 0x3FF # make sure credits isnt too long
    or $a0, $a0, $a1   # Combine student id and credits
    sw $a0, 0($a3)     # Store id and credit in the record
    sw $a2, 4($a3)     # Store name pointer in record

    jr $ra

print_student: # a0 has student record
    lw $t0, 0($a0)    # Load first word (student id and credits)
    lw $t1, 4($a0)    # Load the name pointer

    srl $t2, $t0, 10  # Shift right 10 to get credits
    andi $t0, $t0, 0x3FF  # Extract the credits

    li $v0, 1    # Print id
    move $a0, $t2
    syscall

    li $v0, 4    # Print space 
    la $a0, space_macro
    syscall

    li $v0, 1    # Print credits
    move $a0, $t0
    syscall

    li $v0, 4    # Print space 
    la $a0, space_macro
    syscall

    li $v0, 4    # Print name
    move $a0, $t1
    syscall 

    jr $ra
	
init_student_array:

    jr $ra                        

	
insert:
	jr $ra
	
search:
	jr $ra

delete:
	jr $ra
