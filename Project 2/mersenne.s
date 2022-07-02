.text
.align 2
.globl main

main:
	# Print Ask Integer Prompt
	li 		$v0, 4
	la		$a0, number_prompt
	syscall

	# Take Input of the number as an int and move the value to t5
	li		$v0, 5
	syscall
	move	$t5, $v0

    # initiate multiplication counter and value to return
    li      $t4, 0 #mult count
    li      $a0, 1 #return val

mersenne_calc:
    mul     $a0, $a0, 2
    addi    $t4, $t4, 1
    bne     $t4, $t5, mersenne_calc
    addi    $a0, $a0, -1

print_value:
    li 		$v0, 1
    syscall

end:
    jr $ra

.data
number_prompt: .asciiz "Please enter an integer: "
