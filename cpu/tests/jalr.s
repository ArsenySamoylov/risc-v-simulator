    li      t0, 20          # target addr       
    jalr    ra, t0, 0
    li  ra, -1
    li  ra, -1
    li  ra, -1

target:
    li      t2, 8           # return addr of jalr
    bne     ra, t2, fail

done:
    nop

fail:
    # invalid instruction