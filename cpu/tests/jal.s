    jal ra, target
    li  ra, -1
    li  ra, -1
    li  ra, -1

target:
    li  t0, 4 # 4 - return addr
    bne ra, t0, fail

    jal t0, next_target
    li  t0, -1
    li  t0, -1

next_target:
    li ra, 28
    bne t0, ra, fail

success:
    nop

fail:
    # invalid instruction