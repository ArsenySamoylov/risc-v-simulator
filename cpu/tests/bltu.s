# eq: a0 == t0
    li a0, 100
    li t0, 100
    bltu a0, t0, fail

# neq: a0 < t0 (unsigned)
    li a0, 50
    li t0, 200
    bltu a0, t0, gu
    beqz zero, fail

gu: # a0 < t0 (unsigned)
    li a0, 100
    li t0, -1             # t0 = 0xFFFFFFFF (unsigned: 4294967295)
    bltu a0, t0, success
    beqz zero, fail

success:
    nop

fail:
    # invalid instruction
