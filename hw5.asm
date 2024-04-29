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
    lw $s0, 0($sp)	# take out the address of the array
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
    # a0: record a1 = table a2 = table_size
    
    move $t1, $a1	# t1 becomes the table 
    move $t2, $a2	# t2 becomes the tablesize

    # Calculate the array index
    lw $t8, 0($a0)
    srl $t8, $t8, 10   # get id
    div $t8, $t2       # div by size
    mfhi $t0           # get the index
    
    li $t3,0		# counter = 0
    li $t5,0		# counts how many times has looped
    li $t6,2		# forces fail calse
    
    li $t7,-1		# 5d chess
    

    big_looopy:
    	bge $t3,$t2, reset_to_start		# this resets it to start
 	blt $t3, $t0 moving_to_correct_index	#this gets to the correct index of the array and then move the two in lockstep
 	beq $t3, $t0 check_my_index		# this now goes to the check index section
 	
 	moving_to_correct_index:
 		addi $t1, $t1, 4		# INCREMENT ARRAY
 		addi $t3,$t3,1			# INCREMENT COUNTER
 	j big_looopy				# get back to beggning
 	
 	check_my_index:				#where the magic happens
 		lw $t9, 0($t1)
 		beq $t9, $t7, success_condtion	#if tombstone
 		beq $t9, $zero,success_condtion	#if emptey
 		addi $t1, $t1, 4		# else : INCREMENT ARRAY
 		addi $t3,$t3,1			# Ielse : INCREMENT COUNTER
 		addi $t0,$t0,1			# else : INCREMENT COUNTER
 	j big_looopy
 		
 	reset_to_start:
 		addi $t5, $t5, 1		# increment the fial controlla
 		beq $t5,$6 fail_condtion	# checks how many times it has gone through for fail contion on full array
 		li $t0, 0			# resets counter
 		li $t3, 0			# reset this thing?
    		move $t1, $a1			# reset array postion
 	j big_looopy
 
    fail_condtion:
        li $v0, -1	# fail 
        jr $ra		#return

    success_condtion:
        move $v0, $t0	# winner!!
        sw $a0, 0($t1)
        jr $ra		# return

search: # $a0 is id, #a1 is table, $a2 is table size
	move $t0, $a0	# t0 is id
	move $s0, $a0	# constant
	move $t1, $a1	# t1 is table array
	move $t2, $a2	# t2 is table size
	li $t9, 0
	li $t7, 0
	li $t3, 0	# counter = 0
	li $t4, -1	# negitive 1
	
	li $t5,0		# counts how many times has looped
    	li $t6,2		# forces fail calse
	
	div $t0, $t2       # div by size
    	mfhi $t0           # id is now the index
	
	loop:
	bge $t3,$t2, reset_to_start_search		# this resets it to start
 	blt $t3, $t0 moving_to_correct_index_search	#this gets to the correct index of the array and then move the two in lockstep
 	beq $t3, $t0 check_my_index_search		# this now goes to the check index section
 	
 	moving_to_correct_index_search:
 		addi $t1, $t1, 4		# INCREMENT ARRAY
 		addi $t3,$t3,1			# INCREMENT COUNTER
 	j loop				# get back to beggning
 	
 	check_my_index_search:			#where the magic happens
 		lw $t9, 0($t1)			# load addy
 		
 		beq $t9, $t4, skip	#if tombstone
 		beq $t9, $zero,skip	#if emptey
 		
 		lw $t7, 0($t9)			#its 1am
 		srl $t7, $t7, 10		# skim it
 		
 		beq $a0, $t7 success_condtion_search
 		#b success_condtion_search
 		skip:
 		addi $t1, $t1, 4		# else : INCREMENT ARRAY
 		addi $t3,$t3,1			# Ielse : INCREMENT COUNTER
 		addi $t0,$t0,1			# else : INCREMENT COUNTER
 	j loop
 		
 	reset_to_start_search:
 		addi $t5, $t5, 1		# increment the fial controlla
 		beq $t5,$6 fail_condtion_search	# checks how many times it has gone through for fail contion on full array
 		li $t0, 0			# resets counter
 		li $t3, 0			# reset this thing?
    		move $t1, $a1			# reset array postion
 	j loop
	
	fail_condtion_search:
        move $v0, $zero	# fail 
        move $v1, $t4
        jr $ra		#return

    	success_condtion_search:
    	lw $v0, 0($t1)
        move $v1, $t0	# winner!!
        jr $ra		# return

delete:
	jr $ra
