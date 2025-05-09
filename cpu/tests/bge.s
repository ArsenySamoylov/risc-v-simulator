# eq: a0 == t0
    li a0, 5
    li t0, 5
    bge a0, t0, neq
    beqz zero, fail

neq:
# neq: a0 < t0
    li a0, -2
    li t0, 3
    bge a0, t0, fail

# gs: a0 > t0 (signed)
    li a0, 10
    li t0, -10
    bge a0, t0, success
    beqz zero, fail

success:
    nop

fail:
    # invalid instruction
