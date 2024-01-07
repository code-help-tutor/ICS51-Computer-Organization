WeChat: cstutorcs
QQ: 749389476
Email: tutorcs@163.com
jal main
#                                           ICS 51, Lab #2
# 
#                                          IMPORTATNT NOTES:
# 
#                       Write your assembly code only in the marked blocks.
# 
#                     DO NOT change anything outside the marked blocks.
# 
#                      Remember to fill in your name, student ID in the designated sections.
# 
#
j main
###############################################################
#                           Data Section
.data
# 
# Fill in your name, student ID in the designated sections.
# 
student_name: .asciiz "First and Last Name"
student_id: .asciiz "UCIID#"

new_line: .asciiz "\n"
space: .asciiz " "
gets: .asciiz " -> "
testing_label: .asciiz "Testing "
strlen_label: .asciiz "Strlen \n"
valid_id_label: .asciiz "Valid ID \n"
file_label: .asciiz "File read \n"
file:
	.asciiz	"lab2_data.dat"	# File name
	.word	0
buffer:
	.space	30			# Place to store character
num_tests: .word 4
test_1: .asciiz ""
test_2: .asciiz "Pr@p$r %unc&tuation"
test_3: .asciiz "$a&r()$o###ma"
test_4: .asciiz "{CASH}_R...ules_ever23ythi*ng ar( )ound me!."
input_data:
    .word test_1, test_2, test_3, test_4
test_1_out: .space 100
test_2_out: .space 100
test_3_out: .space 100
test_4_out: .space 100
output_data:
    .word test_1_out, test_2_out, test_3_out, test_4_out
###############################################################
#                           Text Section
.text

#                          Main Function
.globl main
main:

li $v0, 4
la $a0, student_name
syscall
la $a0, new_line
syscall  
la $a0, student_id
syscall 
la $a0, new_line
syscall

test_strlen:
lw $s1, num_tests
li $s0, 0
li $v0, 4
la $a0, testing_label
syscall
la $a0, strlen_label
syscall 

test1_loop:
beq $s0, $s1, test_valid_id

la $t0, input_data
sll $a0, $s0, 2
add $t0, $t0, $a0
lw $a0, ($t0)

sub $sp,$sp,4
sw $a0,($sp)

jal strlen

lw $a0,($sp)
addiu $sp,$sp,4

move $t0, $v0
li $v0, 4
syscall
la $a0, gets
syscall  

move $a0, $t0
li $v0, 1
syscall 
li $v0, 4
la $a0, new_line
syscall

addi $s0, $s0, 1
b test1_loop

test_valid_id:

li $v0, 4
la $a0, new_line
syscall
lw $s1, num_tests
li $s0, 0
li $v0, 4
la $a0, testing_label
syscall
la $a0, valid_id_label
syscall 

test2_loop:
beq $s0, $s1, test_file_read

la $t0, input_data
la $t1, output_data

sll $a0, $s0, 2
add $t0, $t0, $a0
lw $a0, ($t0)
sll $a1, $s0, 2
add $a1, $t1, $a1
lw $a1, ($t1)

sub $sp,$sp,4
sw $a0,($sp)
sub $sp,$sp,4
sw $a1,($sp)

jal valid_id

lw $a1,($sp)
addiu $sp,$sp,4
lw $a0,($sp)
addiu $sp,$sp,4

li $v0, 4
syscall
la $a0, gets
syscall 
move $a0, $a1 
syscall 

li $v0, 4
la $a0, new_line
syscall

addi $s0, $s0, 1
b test2_loop

test_file_read:
li $v0, 4
la $a0, new_line
syscall
li $s0, 0
li $v0, 4
la $a0, testing_label
syscall
la $a0, file_label
syscall 
jal file_read
end:
# end program
li $v0, 10
syscall


###############################################################
###############################################################
###############################################################
#                            PART 1 (Strlen)
# You are given a null-terminated strings ($a0). You need calculate its length and store in ($v0).
# Basically you should count number of characters before reaaching the character with value of 0.
# int strlen (str) {
#    int len = 0;
#    while (str[len] != 0)   // 0 != '0'
#        len++;
#    return len;
# }
strlen:
############################## Part 1: your code begins here ###
li $t0, 0
strlen_loop:
lb $t1, 0($a0)
beq $t1, $zero, strlen_loop_out
addi $t0, $t0, 1
addi $a0, $a0, 1
j strlen_loop
strlen_loop_out:
move $v0, $t0
############################## Part 1: your code ends here   ###
jr $ra
###############################################################
#                           PART 2 (Valid IDs)
#
# Takes a null terminated (C-Style) string and returns another C-style string only
# containing valid characters. Valid characters are defined to be alphanumeric characters (a-A,b-B,0-9)
# and "_" (underscore) character.
# $a0 : pointer to input string buffer
# $a1 : pointer to output string buffer (initially all zeros)
valid_id:
############################### Part 2: your code begins here ##
valid_id_loop:
lb $t0, 0($a0)
beq $t0, $zero, valid_id_loop_out
blt $t0, 48, invalid
ble $t0, 57, valid
blt $t0, 65, invalid
ble $t0, 90, valid
beq $t0, 95, valid
blt $t0, 97, invalid
ble $t0, 122, valid
j invalid

valid:
sb $t0, 0($a1)
addi $a1, $a1, 1

invalid:
addi $a0, $a0, 1
j valid_id_loop

valid_id_loop_out:
sb $zero 0($a1)

############################### Part 2: your code ends here  ##
jr $ra
###############################################################
#                           PART 3 (ReadFile)
#
# You will read characters (bytes) from a file (lab2_data.dat) and print them. Valid characters are only spaces (ASCII code 32), 
#Exclamation points (ASCII code 33), and uppercase letters (A-Z). 
#Lower case letters should be converted to uppercase and eveything else should be discarded
#The expected output should be in one line and read: THIS WAS A SUCCESS!
# $a1 : address of the input buffer
file_read:

# Open File

	li	$v0, 13			# 13=open file
	la	$a0, file		# $a2 = name of file to read
	add	$a1, $0, $0		# $a1=flags=O_RDONLY=0
	add	$a2, $0, $0		# $a2=mode=0
	syscall				# Open FIle, $v0<-file descriptor (fd)
	add	$s0, $v0, $0	# store fd in $s0
	
# Read file and store it in the buffer

	li	$v0, 14			# 14=read from  file
	add	$a0, $s0, $0	# $s0 contains fd
	la	$a1, buffer		# buffer to hold string
	li	$a2, 30		# Read 30 characters
	syscall


############################### Part 3: your code begins here ##
read_loop:
lb $t0, 0($a1)
beq $t0, $zero, read_loop_out
beq $t0, 32, print_char
beq $t0, 33, print_char

blt $t0, 65, read_loop_cont
ble $t0, 90, print_char

blt $t0, 97, read_loop_cont
ble $t0, 122, to_upper

j print_char

to_upper:
addi $t0, $t0, -32

print_char:
move $a0, $t0
li $v0, 11
syscall

read_loop_cont:
addi $a1, $a1, 1
j read_loop

read_loop_out:

############################### Part 3: your code ends here  ##
# Close File

done:
	li	$v0, 16			# 16=close file
	add	$a0, $s0, $0	# $s0 contains fd
	syscall				# close file

jr $ra
