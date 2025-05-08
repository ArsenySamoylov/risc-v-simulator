# RISC-V fibonacci program
#
# Stanislav Zhelnio, 2020
# Amended by Yuri Panchul, 2024

fibonacci:

        mv      a0, zero
        li      t0, 1

loop:   add     t1, a0, t0
        mv      a0, t0
        mv      t0, t1
        beqz    zero, loop


