.data
.text
.globl make_node
.globl insert
.globl get
.globl getAtMost

# Dummy implementations to disable Q1 safely

make_node:
    li a0,0        # return NULL
    ret

insert:
    li a0,0        # return NULL root
    ret

get:
    li a0,0        # return NULL
    ret

getAtMost:
    li a0,-1       # return -1
    ret
    