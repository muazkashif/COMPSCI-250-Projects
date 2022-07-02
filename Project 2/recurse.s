.text
.align 2
.globl main

main:
	# Print Ask Integer Prompt
	li $v0, 4
	la $a0, number_prompt
	syscall

	# Take Input of the number as an int and move the value to a0
	li $v0, 5
	syscall
	move $a0, $v0

    addi $sp, $sp, -4
    sw $ra, 0($sp)

    jal recurse

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    move $a0, $v0
    li $v0, 1
    syscall

recurse:
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $s0, 8($sp)
    
    bgt $a0, $0, else

    li $v0, -2
    j return

else:
    move $s0, $a0
    addi $a0, $a0, -1

    jal recurse

    li $t0, 3
    mul $t0, $t0, $s0

    li $t1, 2
    mul $t1, $t1, $v0

    add $t0, $t0, $t1
    addi $v0, $t0, -2

return:
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $s0, 8($sp)
    addi $sp, $sp, 12

    jr $ra

.data
number_prompt: .asciiz "Please enter an integer: "
