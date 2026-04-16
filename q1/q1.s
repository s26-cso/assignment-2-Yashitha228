.data
.text
.globl make_node
.globl insert
.globl get
.globl getAtMost
# struct layout
.equ val,0 #int val
.equ left,8 #pointer to left
.equ right,16 #pointer to right

#make_node function
make_node:
    addi sp,sp,-8
    sd ra,0(sp)

    #a0=val
    #allocate 24 bytes for struct Node
    mv t0,a0
    li a0,24
    jal malloc #malloc(size),returns pointer in a0
    beq a0,x0,done #if malloc returns NULL,just return NULL
    sw t0,0(a0) #store val that is newnode->val=val;
    sd x0,8(a0) #set left as NULL
    sd x0,16(a0) #set right as NULL

done:
    ld ra,0(sp)
    addi sp,sp,8
    ret

insert:
    addi sp,sp,-16
    sd ra,8(sp)
    sd s1,0(sp)

    #a0=root,a1=val
    beq a0,x0,create_node #if root==NULL do make_node(val)
    lw t0,0(a0) #load root->val into t0
    blt a1,t0,insert_go_left #if val<root->val then go left
    bgt a1,t0,insert_go_right #if val>root->val then go right
    j return_root #if equal then return root

insert_go_left:
     ld t1,8(a0) #load root->left
     mv s1,a0 #root is in s1 now
     mv a0,t1 #arg0=root->left
     jal insert #recursive call
     sd a0,8(s1)#root->left=result
     mv a0,s1 #return root
     j insert_end

insert_go_right:
    ld t1,16(a0) #load root->right
    mv s1,a0 #save root in s1
    mv a0,t1 #arg0=root->right
    jal insert #recursive call
    sd a0,16(s1) #root->right=result
    mv a0,s1 #return root
    j insert_end

create_node:
    mv a0,a1 #pass val in a0
    jal make_node
    j insert_end

return_root:
    j insert_end

insert_end:
    ld s1,0(sp)
    ld ra,8(sp)
    addi sp,sp,16
    ret

get:
    addi sp,sp,-8
    sd ra,0(sp)

    #a0=root,a1=val
    beq a0,x0,null #if root is null then return null
    lw t0,0(a0) #load root->val into t0
    beq a1,t0,found #if val==root->val then return root
    blt a1,t0,get_go_left #if val<root->val then search left
    bgt a1,t0,get_go_right#if val>root->val then search right

get_go_left:
    ld t1,8(a0) #load t1 with root->left
    mv a0,t1 #arg0=root->left
    jal get #recursive call
    j get_end

get_go_right:
    ld t1,16(a0) #load t1 with root->right
    mv a0,t1 #arg0=root->right
    jal get #recursive call
    j get_end

found:
    j get_end #return root in a0

null:
    li a0,0 #return NULL

get_end:
    ld ra,0(sp)
    addi sp,sp,8
    ret
#getAtMost:
    #a0=val,a1=root
   # li t0,-1 #result=-1
getAtMost:
    li a0,-1   # always return -1
    ret
    


loop:
    beq a1,x0,donee #exit if root==NULL
    lw t1,0(a1) #load root->val into t1
    ble t1,a0,left_case #case when root->val<=val
    ld a1,8(a1)
    j loop

left_case:
    mv t0,t1 #result=root->val
    ld a1,16(a1) #root=root->right
    j loop

donee:
    mv a0,t0 #return result
    ret
    
