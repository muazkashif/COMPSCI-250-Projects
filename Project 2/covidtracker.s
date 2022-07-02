.text
.align 2
.globl main

main:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

PromptLoop:
    # Print Ask Patient Prompt
	li $v0, 4
	la $a0, patient_prompt
	syscall

	# Take Input of the name and store in patient_input
	li $v0, 8
    la $a0, patient_input
    li $a1, 32
	syscall

    li $s0, 0        # Set index to 0
remove1:
    lb $a3, patient_input($s0)    # Load character at index
    addi $s0,$s0,1      # Increment index
    bnez $a3,remove1     # Loop until the end of string is reached
    beq $a1,$s0,skip1    # Do not remove \n when string = maxlength
    addiu $s0,$s0,-2     # If above not true, Backtrack index to '\n'
    sb $0, patient_input($s0)    # Add the terminating character in its place
skip1:
    
    la $a0, patient_input #checking if END of input reached
    la $a1, done_text

    addi $sp, $sp, -16
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    jal strcmp
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16

    beqz $v0, printList

    # Print Ask Infector Prompt
	li $v0, 4
	la $a0, infector_prompt
	syscall

    # Take Input of the name and store in infector_input
	li $v0, 8
    la $a0, infector_input
    li $a1, 32
	syscall

    li $s0,0        # Set index to 0
remove2:
    lb $a3, infector_input($s0)    # Load character at index
    addi $s0,$s0,1      # Increment index
    bnez $a3,remove2     # Loop until the end of string is reached
    beq $a1,$s0,skip2    # Do not remove \n when string = maxlength
    addiu $s0,$s0,-2     # If above not true, Backtrack index to '\n'
    sb $0, infector_input($s0)    # Add the terminating character in its place
skip2:
               
    bnez $t0, else      #check if head is null to BEGIN LIST
    #first add infector node
    li $v0, 9
    li $a0, 104
    syscall
    move $t0, $v0       #t0 now has head of list
    move $t1, $v0       #t1 contains tail (same node for now)

    move $a0, $t0
    la $a1, infector_input

    addi $sp, $sp, -16
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    jal strcpy
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16

    addi $a0, $t0, 32
    la $a1, patient_input
    
    addi $sp, $sp, -16
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    jal strcpy
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16

    li $t2, 1
    sw $t2, 96($t0)

    #now add infectee as second node
    li $v0, 9
    li $a0, 104
    syscall
    sw $v0, 100($t1)     #save address of second node at the end of first node
    move $t1, $v0       #tail = tail.next

    move $a0, $t1
    la $a1, patient_input    #save patient as infector for second node
    
    addi $sp, $sp, -16
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    jal strcpy
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16

    li $t2, 0
    sw $t2, 96($t1)  #save number infected to this node

    #clear buffers?

    j PromptLoop

else: 
      #make infectee as new node (always new person!)
    li $v0, 9
    li $a0, 104
    syscall
    sw $v0, 100($t1)     #save address of next node at the end of first node
    move $t1, $v0       #tail = tail.next

    move $a0, $t1
    la $a1, patient_input    #save patient as infector for second node
    
    addi $sp, $sp, -16
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    jal strcpy
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16

    li $t2, 0
    sw $t2, 96($t1) 

    #loop through existing list to check if infector exists
    move $t2, $t0    #ptr = head
InfectorCheck:
    beqz $t2, notSeen
    la $a0, 0($t2)       #checking if infector name seen
    la $a1, infector_input

    addi $sp, $sp, -16
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    jal strcmp
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16

    beqz $v0, Seen
    lw $t2, 100($t2)
    j InfectorCheck

Seen:
    lw $t3, 96($t2)   #loading number of infected
    beqz $t3, addFirst
AddSecond:    
    addi $a0, $t2, 64
    la $a1, patient_input

    addi $sp, $sp, -16
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    jal strcpy
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16

    li $t3, 2
    sw $t3, 96($t2) 

    j DoneAddingNode
addFirst:
    addi $a0, $t2, 32
    la $a1, patient_input    #save patient as infector for second node
    
    addi $sp, $sp, -16
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    jal strcpy
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16

    li $t3, 1
    sw $t3, 96($t2) 

    j DoneAddingNode

notSeen:     #add infector as new node
    li $v0, 9
    li $a0, 104
    syscall
    sw $v0, 100($t1)     #save address of next node at the end of first node
    move $t1, $v0       #tail = tail.next
    move $a0, $t1
    la $a1, infector_input

    addi $sp, $sp, -16
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    jal strcpy
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16 

    addi $a0, $t1, 32
    la $a1, patient_input  

    addi $sp, $sp, -16
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    jal strcpy
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16  

    li $t2, 1
    sw $t2, 96($t1) 

DoneAddingNode:
j PromptLoop

printList:
    addi $sp, $sp, -16
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    move $a0, $t0   #head and tail as arguments
    move $a1, $t1
    jal sortList
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16 


    move $t2, $t0    #ptr = head
    
printLoop:  
    beqz $t2, return

    lw $t3, 96($t2)
    beqz $t3, printZero

    addi $t3, $t3, -1
    beqz $t3, printOne

    li $v0, 4
	la $a0, 0($t2)
	syscall

    la $a0, add_space
	syscall

    #alphabetizing infectees

    la $a0, 32($t2)
    la $a1, 64($t2)

    addi $sp, $sp, -16
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    jal strcmp
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    addi $sp, $sp, 16

    bgtz $v0, switchNames

    li $v0, 4
	la $a0, 32($t2)
	syscall

    la $a0, add_space
	syscall

    li $v0, 4
	la $a0, 64($t2)
	syscall

    la $a0, new_line
	syscall
    
    lw $t2, 100($t2)
    j printLoop

    switchNames:
    li $v0, 4
	la $a0, 64($t2)
	syscall

    la $a0, add_space
	syscall

    li $v0, 4
	la $a0, 32($t2)
	syscall

    la $a0, new_line
	syscall
    
    lw $t2, 100($t2)
    j printLoop


    printOne:
    li $v0, 4
	la $a0, 0($t2)
	syscall
    la $a0, add_space
	syscall
    li $v0, 4
	la $a0, 32($t2)
	syscall
    la $a0, new_line
	syscall
    lw $t2, 100($t2)
    j printLoop

    printZero:
    li $v0, 4
	la $a0, 0($t2)
	syscall
    la $a0, new_line
	syscall
    lw $t2, 100($t2)
    j printLoop


return:
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    li $v0, 10
    syscall

# $a0 = dest, $a1 = src
strcpy:
	lb $t0, 0($a1)
	sb $t0, 0($a0)
    beq $t0, $zero, done_copying
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	j strcpy

	done_copying:
	jr $ra

# $a0, $a1 = strings to compare
# $v0 = result of strcmp($a0, $a1)
strcmp:
	lb $t0, 0($a0)
	lb $t1, 0($a1)

	bne $t0, $t1, done_with_strcmp_loop
	addi $a0, $a0, 1
	addi $a1, $a1, 1
	bnez $t0, strcmp
	li $v0, 0
	jr $ra
		

	done_with_strcmp_loop:
	sub $v0, $t0, $t1
	jr $ra

# $a0 = string buffer to be zeroed out
strclr:
	lb $t0, 0($a0)
	beq $t0, $zero, done_clearing
	sb $zero, 0($a0)
	addi $a0, $a0, 1
	j strclr

	done_clearing:
	jr $ra

sortList:
    #SAVE S REGISTERS
    addi $sp, $sp, -36
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)
    sw $s7, 28($sp)
    sw $ra, 32($sp)

    move $s0, $a0   #move head to $s0
    move $s1, $a1   #move tail to $s1

    MainLoop:
    beq $s0, $s1, doneSorting
    move $s2, $0  #s2 contains prev node
    move $s3, $s0 #s3 contains temp node (initialized with head)

    smallLoop:
    beq $s3, $s1, doneSmallLoop
    lw $s4, 100($s3) #s4 contains temp.next
    la $s5, 0($s3) #s5 contains infector name/and then numberinfected at temp node
    la $s6, 0($s4) #s6 contains infector name/and then numberinfected at temp.next node
    move $a0, $s5
    move $a1, $s6
    jal strcmp
    bltz $v0, skipSort

    #switch infector
    la $a0, temp_name
    la $a1, 0($s3)
    jal strcpy

    la $a0, 0($s3)
    la $a1, 0($s4)
    jal strcpy

    la $a0, 0($s4)
    la $a1, temp_name
    jal strcpy

    #switch infected1
    la $a0, temp_infected1
    la $a1, 32($s3)
    jal strcpy

    la $a0, 32($s3)
    la $a1, 32($s4)
    jal strcpy

    la $a0, 32($s4)
    la $a1, temp_infected1
    jal strcpy

    #switch infected2
    la $a0, temp_infected2
    la $a1, 64($s3)
    jal strcpy

    la $a0, 64($s3)
    la $a1, 64($s4)
    jal strcpy

    la $a0, 64($s4)
    la $a1, temp_infected2
    jal strcpy

    #switch number infected

    lw $s5, 96($s3) #s5 contains numberinfected at temp node
    lw $s6, 96($s4) #s6 contains numberinfected at temp.next node
    #move $s7, $s5   #s7 is temp number variable for switching
    sw $s5, 96($s4)
    sw $s6, 96($s3)

    #la $a0, temp_name
    #jal strclr
    #la $a0, temp_infected1
    #jal strclr
    #la $a0, temp_infected2
    #jal strclr

    skipSort:

    move $s2, $s3 #prev = temp
    move $s3, $s4 #temp = temp.next

    j smallLoop

    doneSmallLoop:

    move $s1, $s2

    j MainLoop
    
    doneSorting:

    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $s6, 24($sp)
    lw $s7, 28($sp)
    lw $ra, 32($sp)
    addi $sp, $sp, 36

    jr $ra

.data
patient_prompt: .asciiz "Please enter patient name: "
patient_input: .space 32
infector_prompt: .asciiz "Please enter infector name: "
infector_input: .space 32
add_space: .asciiz " "
done_text: .asciiz "DONE"
new_line: .asciiz "\n"
temp_name: .space 32
temp_infected1: .space 32
temp_infected2: .space 32