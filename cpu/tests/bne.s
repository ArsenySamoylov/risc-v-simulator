bne:
    li a0, 1
    li t0, 1
    bne a0, t0, fail
    
    li t0, 69
    bne a0, t0, succuess

succuess:
    nop

fail:
    # invalid Instruction