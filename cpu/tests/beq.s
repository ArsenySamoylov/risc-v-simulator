neq:
    li a0, 1
    li t0, 2
    beq a0, t0, fail

eq:

    li t0, 1
    beq a0, t0, succuess

succuess:
    nop

fail:
    # invalid instruction