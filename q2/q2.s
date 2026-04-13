.data            #tells assembler everything below is data not code
buffer: .space 32 #It is a label a name of this memory address
                 #.space32 reserves 32 bytes of memory
.text   #code section
.globl main #makes main visible to the linker entry point
main:
    addi s0,a0,-1 #argc includes the program name also so number of inputs n=argc-1
    li   t0,2048 #load 2048 into t0
    sub  sp,sp,t0 #stack grows downward
    mv   s1,sp    #s1 points to the start of arr[]
                  #arr[0] is at sp+0,arr[1] is at sp+4,arr[i] at sp+(i*4)
    addi s2,s1,256 #stk[] starts 256 bytes after arr[]
    addi s3,s2,256 #res[] starts 256 bytes after stk[]
    li t0,0        #i=0,loop counter
parse_loop:
    bge t0,s0,parse_done #if i>=n all arguments parsed jump to parse_done
    addi t1,t0,1         #argv index=i+1
    slli t1,t1,3         #argv[]=(i+1)*8 because each pointer is 8 bytes
    add t2,a1,t1         #t2=&argv[i+1] address of pointer to string
    ld a0,0(t2)          #a0=argv[i+1] a0 points to actual string
    li t6,0              #for atoi to build the integer digit by digit
atoi_loop:
    lbu t5,0(a0)         #zero-extended byte at memory[a0]
    beqz t5, atoi_done    #branch if t5==0 that is if string reaches a null terminator
    addi t5,t5,-48       #convert ascii digit to numeric value
    li   t4,10
    mul  t6,t6,t4        #shift accumulator left by one decimal place
    add  t6,t6,t5        #join a new digit
    addi a0,a0,1         #advance string pointer to the next character
    j atoi_loop          #unclonditional jump
atoi_done:
    slli t3,t0,2         #we store integers as 4 byte byteoffset=i*4
    add  t4,s1,t3        #t4=&arr[i]
    sw   t6,0(t4)        #memory[t4+i*4]=t6
    addi t0,t0,1         #i++
    j parse_loop
parse_done:
    li s4,-1            #stack top=-1
    addi t0,s0,-1       #i=n-1 start from right most element
nge_loop:
    blt t0,x0,nge_done  #if i<0 we have processed all elements
    slli t1,t0,2        #load arr[i] into t3
    add  t2, s1, t1
    lw   t3, 0(t2)      #t3=arr[i]
pop_loop:
    blt s4,x0,pop_done #top<0 stack empty stop popping
    slli t4, s4, 2
    add  t5, s2, t4
    lw   t6, 0(t5)     #t6=stk[top]
    blt  t6, x0, pop_done
    bge  t6, s0, pop_done #safety checks
    slli t4, t6, 2
    add  t5, s1, t4
    lw   t4, 0(t5)  #t4=arr[stack[top]]
    bgt  t4,t3,pop_done #arr[stack[top]]>arr[i] then stop
    addi s4,s4,-1       #decrement top pointer
    j pop_loop
pop_done:
    slli t1,t0,2
    add t2,s3,t1 #t2=&res[i]
    blt s4,x0,store_neg1 #if stack is empty no nge exists so store -1
    slli t4, s4, 2
    add  t5, s2, t4
    lw   t6, 0(t5)       #if stack not empty stack[top]=NGE index
    sw   t6,0(t2)        #result[i]=NGE_index
    j do_push
store_neg1:
    li t6,-1
    sw t6,0(t2) #res[i]=-1
do_push:
    addi s4,s4,1 #increment top pointer
    slli t4,s4,2
    add  t5,s2,t4
    sw   t0,0(t5) #stack[top]=i
    addi t0,t0,-1 #logic is i-- move to next element
    j nge_loop
nge_done:
li t0,0
print_loop:
    bge t0,s0,print_done #if i>=n printing done
    slli t1, t0, 2
    add  t2, s3, t1
    lw   a0, 0(t2)#a0=res[i] load result to print
    call print_int
    li a0,32 #for printing a space character after each number
    la a1,buffer #store address of label into a1=address of buffer
    sb a0,0(a1)  #buffer[0]=space character
    li a0,1      #1=stdout
    li a7,64     #linux syscall number=64
    la a1,buffer #what to write
    li a2,1      #number of bytes to write
    ecall
    addi t0,t0,1
    j print_loop
print_done:
    # print newline at end
    li   a0, 10            # ASCII 10 = newline '\n'
    la   a1, buffer
    sb   a0, 0(a1)
    li   a0, 1
    li   a7, 64
    la   a1, buffer
    li   a2, 1
    ecall
#restore stack and exit
    li   t0, 2048
    add  sp, sp, t0
    li   a0, 0             # exit code 0 = success
    li   a7, 93            # Linux syscall 93 = exit
    ecall
print_int:
    addi sp, sp, -32      #grow down by 32 bytes for saved registers
    sd   ra,24(sp)
    sd   t0, 16(sp)       #save them internally to not corrupt caller values
    sd   t1,  8(sp)
    sd   t2,  0(sp)
    li   t6, -1
    bne  a0, t6, pi_positive #if a0!=-1 handle as positive number
    la a1,buffer
    li t4,'-'
    sb t4,0(a1) #write '-' character into buffer[0]
    li   t4, '1'   #write 1 into buffer[1],together buffer="-1"
    sb   t4, 1(a1)
    li   a0, 1             # stdout
    li   a7, 64            # write syscall
    li   a2, 2             # write 2 bytes: '-' and '1'
    ecall
    j pi_exit
pi_positive:
    la t0,buffer
    addi t1,t0,31#t1 points to buffer[31] last byte
    li   t2, 10
    sb   zero, 0(t1)#write null byte at buffer[31] as safety terminator
    addi t1,t1,-1#t1 points to buffer[30]
    mv t3,a0     #t3 is the copy of number to print
    beqz t3,pi_zero #if number is exactly zero handle seperately
pi_digit_loop:
    rem t4,t3,t2
    addi t4,t4,48
    sb   t4,0(t1)
    div t3,t3,t2
    addi t1,t1,-1
    bnez t3,pi_digit_loop
    addi t1,t1,1
    j pi_write
pi_zero:
    li t4,'0'
    sb t4,0(t1)
pi_write:
    la t0,buffer
    addi t0,t0,31
    sub a2,t0,t1
    mv a1,t1
    li a0,1
    li a7,64
    ecall
pi_exit:
    ld   ra, 24(sp)
    ld   t0, 16(sp)
    ld   t1,  8(sp)
    ld   t2,  0(sp)
    addi sp,sp,32
    ret

    


