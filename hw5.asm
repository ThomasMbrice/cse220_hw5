.data
    space_macro: .asciiz " "
    nextline_macro: .asciiz "\n"
    copy_string_space: .space 128    
.text

init_student: # a0 is id, a1 is credits, a2 is name, a3 is record
    sll $a0, $a0, 10    # Shift student id by 22 bits
    andi $a1, $a1, 0x3FF
    or $a0, $a0, $a1   # Combine student id and credits
    sw $a0, 0($a3)     # Store id and credit in the record
    sw $a2, 4($a3)     # Store name pointer in record
    
    li $s5, 8		# misc

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
    move $t0, $a0       # $t0 is num students
    move $t1, $a1       # $t1 is id list
    move $t2, $a2       # $t2 is credit list
    move $t3, $a3       # $t3 is name list
    li $t4, 0           # $t4 is i = 0
    move $s1, $s0	# copy starting pos of array

    addi $sp, $sp, -4	# save return
    sw $ra, 0($sp)

    main_while_loop:
        bge $t4, $t0, end_main     # Exit loop if i >= num_students

        lw $a0, 0($t1)     # Load ID
        lw $a1, 0($t2)     # Load credits
	la $t6, copy_string_space	# laod space into temp varrible
	
	        move $a2, $t3  # loads string to arguement
	
        find_name:		# uses t6 and t7 as temporary values
		lbu $t7, 0($t3)             # load character to temp
		sb  $t7, 0($t6)			# load bit to space
		addi $t3, $t3, 1               # increment
		addi $t6, $t6, 1
		beq $t7, $zero, end_name_loop     # exit loop on 0
		j find_name                    # jump
        end_name_loop:


        move $a3, $s0            # load array
        jal init_student         # call
	

	
        addi $t4, $t4, 1         # i+=1
        addi $t1, $t1, 4         # id+4
        addi $t2, $t2, 4         # credit+=4
        addi $s0, $s0, 8         # record next slot

        j main_while_loop        

    end_main:
        lw $ra, 0($sp)		# load original return 
        addi $sp, $sp, 4
	move $s0, $s1 #reset the postiion of s0
        jr $ra

insert:
    jr $ra


search:
	jr $ra



delete:
	jr $ra
