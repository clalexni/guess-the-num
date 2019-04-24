.data

# allocates 128 bytes for a card
card:	.space	128

card_number_list: .word  1, 2, 3, 4, 5, 6

# prompts
start_game_prompt:      .asciiz	"\nThink of a number between 0 and 63. Press Enter (or any other key) to start: "
yes_no_prompt:  	.asciiz	"\nIs your number in the group of numbers? (y/n): "
play_again_prompt:      .asciiz	"\n\nDo you want to play again? (y/n): "
error_message_prompt:	.asciiz	"\nPlease enter either 'y' or 'n': "
final_answer_prompt: 	.asciiz "\nThe number you picked is : "

# formatting tools
one_space:	.asciiz " "
two_spaces:	.asciiz "  "
new_line:	.asciiz "\n"

.text
main:
	# prompt game starter
	li $v0, 4
	la $a0, start_game_prompt
	syscall
	
	# read any input to start
	li $v0, 12
	syscall
	
	# Initialize Variables
	li $s0, 0                  # loop counter
	la $s1, card_number_list   # pointer to card_number_list
	li $s2, 0   		   # $t2 contains accumulated answer
	
Loop:	beq $s0, 6, Play_again_prompter
	
	# load card number from card_list to $a0
	lw $a0, 0($s1) 

	# generate contaent of card based on the card number, and print the card content
	jal Card_generator
	jal Print_card_content
	
	# prompt user's input of yes or no, returned value $v0 wil contain 1/0
	la $a0, yes_no_prompt
	li $v0, 4
	syscall
	
	jal Yes_no_prompter
	
	# prepare to call Accumulator function
	lw $a0, 0($s1) 
	move $a1, $v0   # $a1 contains yes or no
	move $a2, $s2   # $a2 contains acummulated value
	
	jal Accumulator
	
	# move accumulated value back to $s2
	move $s2, $v0

	# increase loop counter by one and jump back to Loop
	addi $s1, $s1, 4
	addi $s0, $s0, 1
	
	j Loop
	
Play_again_prompter:
	
	# Display final answer
	li $v0, 4
	la $a0, final_answer_prompt
	syscall
	
	li $v0, 1
	move $a0, $s2 # s2 now contains final accumulated answer
	syscall
	
	# Ask whether user want to play again or not
	li $v0, 4
	la $a0, play_again_prompt
	syscall
	
	# call function Yes_no_prompter
	jal Yes_no_prompter
	
	# if answer is no, exit game. Else, jump back to main to restart the game
	beq $v0, 0, Exit_game
	j main
	
Exit_game:
	li $v0, 10
	syscall


.include "subroutines.asm"

	
