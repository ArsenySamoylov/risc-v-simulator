# eq: a0 == t0
    li a0, 100
    li t0, 100
    bgeu a0, t0, neq
    beqz zero, fail

neq:
# neq: a0 < t0 (unsigned)
    li a0, 50
    li t0, 200
    bgeu a0, t0, fail

# gu: a0 > t0 (unsigned)
    li a0, -1             # a0 = 0xFFFFFFFF (unsigned: 4294967295)
    li t0, 100
    bgeu a0, t0, success
    beqz zero, fail

success:
    nop

fail:
    # invalid instruction
