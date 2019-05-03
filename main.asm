.data

# allocates 128 bytes for a card
card:	.space	128
card_number_list: .space 24

# prompts
start_game_prompt:      .asciiz	"Think of a number between 0 and 63. Press YES to continue or Cancel to Exit: "
start_game_prompt1:      .asciiz	"Think of a number between 0 and 63. Press YES to continue or Cancel to Exit: "
yes_no_prompt:  	.asciiz	"\nIs your number on the card below? "
play_again_prompt:      .asciiz	"\nDo you want to play again?: "

final_answer_prompt: 	.asciiz "\nThe number you picked is : "
Welcome:          .asciiz "Welcome friend, Alex and Samir are about to read your mind. Are you ready?"
Afraid:           .asciiz "We got a daddy`s girl or mommy`s boy in the house? Come back when you grow up"
bye:              .asciiz "\nYou have decided to exit the game, Thanks for playing. Good bye"   


# formatting tools
one_space:	.asciiz " "
two_spaces:	.asciiz "  "
new_line:	.asciiz "\n"

#Sound making items
pitch: .byte 15
duration: .word 10000
instrument: .byte 90
volume: .byte 127

.text
main:
     li $v0, 50
     la $a0, Welcome
     syscall
     beq $a0, 0, prompt_game_starter
     beq $a0, 1, A_fraid
     beq $a0, 2, Exit_game
     
    

prompt_game_starter:

	li $v0, 50
	la $a0, start_game_prompt1
	syscall
	beq $a0, 0, Initialize_Variables
	beq $a0, 1, good_bye 
	beq $a0, 2, good_bye  

	
Initialize_Variables:
        li $s0, 0                  # loop counter
        jal number_list            # Call number list to randomly display cards
	la $s1, card_number_list   # pointer to card_number_list
	li $s2, 0   		   # $s2 contains accumulated answer
	
Loop:	beq $s0, 6, Play_again_prompter
	
	# load card number from card_list to $a0
	lw $a0, 0($s1) 

	# generate contaent of card based on the card number, and print the card content
	jal Card_generator
	jal Print_card_content
	
	# prompt user's input of yes or no, returned value $v0 wil contain 1/0
	li $v0, 50
	la $a0, yes_no_prompt
	
	#la $a0, yes_no_prompt
	#li $v0, 4
	#syscall
	
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
	li $v0, 56
	la $a0, final_answer_prompt
	move $a1,$s2
	syscall
	
	
	# Ask whether user want to play again or not
	li $v0, 50
	la $a0, play_again_prompt
	syscall
	beq $a0, 0, prompt_game_starter
	beq $a0, 1, good_bye
	beq $a0, 2, good_bye   
	


#Return message dialog and exit program 
A_fraid:
     li $v0, 55
     la $a0, Afraid
     li $a1, 2
     syscall
     j Exit_game

#Exits program at user request     
good_bye:
     jal Sound_maker
     li $v0, 55
     la $a0, bye
     li $a1, 2
     syscall
     j Exit_game
       	
Exit_game:
	li $v0, 10
	syscall


.include "subroutines.asm"
