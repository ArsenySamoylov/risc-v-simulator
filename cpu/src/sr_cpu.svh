//
//  schoolRISCV - small RISC-V CPU
//
//  Originally based on Sarah L. Harris MIPS CPU
//  & schoolMIPS project.
//
//  Copyright (c) 2017-2020 Stanislav Zhelnio & Aleksandr Romanov.
//
//  Modified in 2024 by Yuri Panchul & Mike Kuskov
//  for systemverilog-homework project.
//

`ifndef SR_CPU_SVH
`define SR_CPU_SVH

// Control 

// what to save in regfile
`define SAVE_ALU_RES 2'b00
`define SAVE_IMM     2'b01
`define SAVE_NEXT_PC 2'b10

// what is next pc
`define PC_PLUS_4       2'b00
`define PC_IMMJ         2'b01
`define PC_IMMB         2'b10
`define PC_REG_PLUS_IMM 2'b11


// ALU commands

`define ALU_ADD     3'b000
`define ALU_OR      3'b001
`define ALU_SRL     3'b010
`define ALU_SLTU    3'b011
`define ALU_SLT     3'b101
`define ALU_SUB     3'b100

// Instruction opcode

`define RVOP_ADDI   7'b0010011

`define RVOP_BEQ    7'b1100011
`define RVOP_BNE    7'b1100011
`define RVOP_BLT    7'b1100011
`define RVOP_BGE    7'b1100011
`define RVOP_BLTU   7'b1100011
`define RVOP_BGEU   7'b1100011

`define RVOP_JAL    7'b1101111
`define RVOP_JALR   7'b1100111

`define RVOP_LUI    7'b0110111
`define RVOP_ADD    7'b0110011
`define RVOP_OR     7'b0110011
`define RVOP_SRL    7'b0110011
`define RVOP_SLTU   7'b0110011
`define RVOP_SLT    7'b0110011
`define RVOP_SUB    7'b0110011
`define RVOP_MUL    7'b0110011

// Instruction funct3

`define RVF3_ADDI   3'b000

`define RVF3_BEQ    3'b000
`define RVF3_BNE    3'b001
`define RVF3_BLT    3'b100
`define RVF3_BGE    3'b101
`define RVF3_BLTU   3'b110
`define RVF3_BGEU   3'b111

`define RVF3_JALR   3'b000

`define RVF3_ADD    3'b000
`define RVF3_OR     3'b110
`define RVF3_SRL    3'b101
`define RVF3_SLTU   3'b011
`define RVF3_SLT    3'b010
`define RVF3_SUB    3'b000
`define RVF3_ANY    3'b???

// Instruction funct7

`define RVF7_ADD    7'b0000000
`define RVF7_OR     7'b0000000
`define RVF7_SRL    7'b0000000
`define RVF7_SLTU   7'b0000000
`define RVF7_SLT    7'b0000000
`define RVF7_SUB    7'b0100000
`define RVF7_ANY    7'b???????

`endif  // `ifndef SR_CPU_SVH
