# -------- blt (signed) --------

# eq: a0 == t0 
    li a0, 5
    li t0, 5
    blt a0, t0, fail

# neq: a0 < t0
    li a0, -5
    li t0, 0
    blt a0, t0, gs
    beqz zero, fail

gs: # a0 < t0 (signed)
    li a0, -1
    li t0, 1
    blt a0, t0, success
    beqz zero, fail

success:
    nop

fail:
    # invalid instruction
