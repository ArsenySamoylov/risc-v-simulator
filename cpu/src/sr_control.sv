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

`include "sr_cpu.svh"

module sr_control
(
    input        [ 6:0] cmdOp,
    input        [ 2:0] cmdF3,
    input        [ 6:0] cmdF7,
    input               aluZero,
    input               aluSlt,
    output              pcSrc,
    output logic        regWrite,
    output logic        aluSrc,
    output logic        wdSrc,
    output logic [ 2:0] aluControl
);
    logic          branch;
    logic          branchCond;
    assign pcSrc = branch & branchCond;

    always_comb
    begin
        branch      = 1'b0;
        branchCond  = 1'b0;
        regWrite    = 1'b0;
        aluSrc      = 1'b0;
        wdSrc       = `SAVE_ALU_RES;
        aluControl  = `ALU_ADD;

        casez ({ cmdF7, cmdF3, cmdOp })
            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD  } : begin regWrite = 1'b1; aluControl = `ALU_ADD;  end
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR   } : begin regWrite = 1'b1; aluControl = `ALU_OR;   end
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL  } : begin regWrite = 1'b1; aluControl = `ALU_SRL;  end
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU } : begin regWrite = 1'b1; aluControl = `ALU_SLTU; end
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB  } : begin regWrite = 1'b1; aluControl = `ALU_SUB;  end

            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; end
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI  } : begin regWrite = 1'b1; wdSrc = `SAVE_IMM; end

            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ  } : begin 
                                                        branch = 1'b1; 
                                                        branchCond =  aluZero; 
                                                        aluControl = `ALU_SUB; 
                                                     end

            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNE  } : begin 
                                                        branch = 1'b1;
                                                        branchCond = !aluZero;
                                                        aluControl = `ALU_SUB; 
                                                      end

                                                                  { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ  } : begin 
                                                        branch = 1'b1; 
                                                        branchCond =  aluZero; 
                                                        aluControl = `ALU_SUB; 
                                                     end

            { `RVF7_ANY,  `RVF3_BLT,  `RVOP_BLT  } : begin 
                                                        branch = 1'b1;
                                                        branchCond =  aluSlt;
                                                        aluControl = `ALU_SLT; 
                                                      end

            { `RVF7_ANY,  `RVF3_BGE,  `RVOP_BGE  } : begin 
                                                        branch = 1'b1;
                                                        branchCond =  !aluSlt;
                                                        aluControl = `ALU_SLT; 
                                                      end

            { `RVF7_ANY,  `RVF3_BLTU, `RVOP_BLTU } : begin 
                                                        branch = 1'b1;
                                                        branchCond =  aluSlt;
                                                        aluControl = `ALU_SLTU; 
                                                      end

            { `RVF7_ANY,  `RVF3_BGEU, `RVOP_BGEU } : begin 
                                                        branch = 1'b1;
                                                        branchCond =  !aluSlt;
                                                        aluControl = `ALU_SLTU; 
                                                      end    

            { `RVF7_ANY,  `RVF3_ANY, `RVOP_JAL  } : begin 
                                                        branch     =  1;
                                                        branchCond =  1;
                                                        regWrite   =  1;
                                                        wdSrc      = `SAVE_NEXT_PC;
                                                      end      
        endcase
    end

endmodule
