.data
filename: .asciz "input.txt"   # file name to open
yesmsg: .asciz "Yes\n"         # output if palindrome
nomsg: .asciz "No\n"           # output if not palindrome
buf: .space 1                 # buffer for left character
buf2: .space 1                # buffer for right character
.text
.globl main
main:
#opening the file
    # openat(AT_FDCWD, "input.txt", O_RDONLY)
    li a0, -100 # AT_FDCWD (current directory)
    la a1, filename # pointer to filename
    li a2, 0 # O_RDONLY (read only)
    li a7, 56 # syscall for openat
    ecall
    mv s0, a0 # save file descriptor in s0
    #get file size
    #lseek(fd,0,seek_end)
     mv a0, s0 # file descriptor
    li a1, 0# offset = 0
    li a2, 2 # SEEK_END
    li a7, 62 # syscall: lseek
    ecall
    mv s1, a0# s1 = file size
    #initializing pointers
    #left=0,right=size-1
    li t0, 0            # left index
    addi t1, s1, -1     # right index
    #remove trailing newlines
fix_loop:
    # move file pointer to position t1
    mv a0, s0
    mv a1, t1
    li a2, 0  # SEEK_SET
    li a7, 62
    ecall
    mv a0, s0
    la a1, buf
    li a2, 1
    li a7, 63 # read syscall
    ecall
    # load that byte into t3
    la t2, buf
    lbu t3, 0(t2)
    # check if it is '\n' (ASCII 10)
    li t4, 10
    beq t3, t4, dec1
    # check if it is '\r' (ASCII 13)
    li t4, 13
    beq t3, t4, dec1
    # if not newline then done
    j loop_start

dec1:
    addi t1, t1, -1     # move right pointer left
    j fix_loop          # repeat until no newline
#main loop
loop_start:
loop:
    # if left >= right then palindrome
    bge t0, t1, yes
    # reset file pointer to start (important!)
    mv a0,s0
    li a1,0
    li a2,0
    li a7,62
    ecall
    # move to position t0
    mv a0,s0
    mv a1,t0
    li a2,0
    li a7,62
    ecall
    # read 1 byte
    mv a0, s0
    la a1, buf
    li a2, 1
    li a7, 63
    ecall
    # load left char into t3
    la t2, buf
    lbu t3, 0(t2)
    # reset file pointer again
    mv a0,s0
    li a1,0
    li a2,0
    li a7,62
    ecall
    # move to position t1
    mv a0,s0
    mv a1,t1
    li a2,0
    li a7,62
    ecall
    # read 1 byte
    mv a0, s0
    la a1, buf2
    li a2, 1
    li a7, 63
    ecall
    # load right char into t4
    la t2, buf2
    lbu t4, 0(t2)
    bne t3, t4, no # if not equal → not palindrome
    # move inward
    addi t0, t0, 1 # left++
    addi t1, t1, -1 # right--
    j loop
yes:
    li a0, 1 # stdout
    la a1, yesmsg
    li a2, 4 # length of "Yes\n"
    li a7, 64 # write syscall
    ecall
    j exit
no:
    li a0, 1
    la a1, nomsg
    li a2, 3 # length of "No\n"
    li a7, 64
    ecall
exit:
    li a7, 93# exit syscall
    li a0, 0
    ecall
    


