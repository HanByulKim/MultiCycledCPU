`include "states.v"
module ROM(
    input [4:0] ROM_input,
    output [1:0] PCSrc,
    output [3:0] ALUOp,
    output [1:0] ALUSrcB,
    output ALUSrcA,
    output RegWrite,
    output [1:0] RegDst,
    output PCWriteCond,
    output PCWrite,
    output IorD,
    output ReadM,
    output WriteM,
    output MemtoReg,
    output IRWrite
);

    reg [17:0] rom [0:22];
// 18 control signals 
// 보고서에 표로 수록함
// PCSrc[1], PCSrc[0], ALUOp[3], ALUOp[2], ALUOp[1], ALUOp[0], ALUSrcB, ALUSrcA, RegWrite, 
// RegDst[1], RegDst[0], PCWriteCond, PCWrite, IorD, ReadM, WriteM, MemtoReg, IRWrite
    initial begin
         rom[`RESET] =      18'bxx0100xx0xx00x00x0;
         rom[`IF] =         18'bxx0100x10xx00010x1;
         rom[`ID] =         18'b000111000xx00x00x0;
         rom[`R_EX] =       18'bxx1111010xx00x00x0;
         rom[`R_WB] =       18'bxxxxxx0110100x0000;
         rom[`ADI_EX] =     18'bxx0100110xx00x00x0;
         rom[`ORI_EX] =     18'bxx0101110xx00x00x0;
         rom[`LHI_EX] =     18'bxx0110110xx00x00x0;
         rom[`I_WB] =       18'bxxxxxx1110001x0000;
         rom[`ML_MEM] =     18'bxxxxxx110xx00110x0;
         rom[`ML_WB] =      18'bxxxxxx1110000x0010;
         rom[`MS_MEM] =     18'bxxxxxx110xx00101x0;
         rom[`B_EX1] =      18'bxx0100100xx00x00x0;
         rom[`BEQ_EX2] =    18'b010001010xx10x00x0;
         rom[`BNE_EX2] =    18'b010000010xx10x00x0;
         rom[`BGZ_EX2] =    18'b010010010xx10x00x0;
         rom[`BLZ_EX2] =    18'b010011010xx10x00x0;
         rom[`J_EX] =       18'b10xxxx100xx01x00x0;
         rom[`JAL_EX] =     18'b10xxxx1011001x0000;
         rom[`JRL_EX] =     18'b0001111111001x0000;
         rom[`JPR_EX] =     18'b000111110xx01x00x0;
         rom[`WWD_EX] =     18'bxx1110x10XX00X00X0;
         rom[`HLT] =        18'bxx1101x10XX00X00X0;
     end

    assign PCSrc =      rom[ROM_input][17:16];
    assign ALUOp =      rom[ROM_input][15:12];
    assign ALUSrcB =    rom[ROM_input][11];
    assign ALUSrcA =    rom[ROM_input][10];
    assign RegWrite =   rom[ROM_input][9];
    assign RegDst =     rom[ROM_input][8:7];
    assign PCWriteCond= rom[ROM_input][6];
    assign PCWrite =    rom[ROM_input][5];
    assign IorD =       rom[ROM_input][4];
    assign ReadM =      rom[ROM_input][3];
    assign WriteM =     rom[ROM_input][2];
    assign MemtoReg =   rom[ROM_input][1];
    assign IRWrite =    rom[ROM_input][0];
    
endmodule
