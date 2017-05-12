`include "opcodes.v"
`include "states.v"

module Control_unit (
  input wire [3:0] opcode,
  input wire [5:0] funct,
  input wire CLK,
  input wire reset_n,
  output [1:0] PCSrc,
  output [3:0] ALUOp,
  output ALUSrcB,
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

reg[4:0] state;
reg[4:0] next_state;
reg[4:0] ROM_input;

ROM rom(.ROM_input(ROM_input), .PCSrc(PCSrc), .ALUOp(ALUOp), .ALUSrcB(ALUSrcB), .ALUSrcA(ALUSrcA), .RegWrite(RegWrite), .RegDst(RegDst), .PCWriteCond(PCWriteCond), .PCWrite(PCWrite), .IorD(IorD), .ReadM(ReadM), .WriteM(WriteM), .MemtoReg(MemtoReg), .IRWrite(IRWrite));

// check reset_n
always @(negedge reset_n) begin
       state <= `RESET;
       next_state <= `IF;
end

// whenever CLK is posedge, update state.
always @(posedge CLK) begin
    if(reset_n==1)  begin
        state = next_state;
        if(state==`I_EX) begin
            case(opcode)
                4'd4, 4'd7, 4'd8:   ROM_input=`ADI_EX;
                4'd5:   ROM_input=`ORI_EX;
                4'd6:   ROM_input=`LHI_EX;
            endcase
        end
        else if(state==`B_EX2) begin
            case(opcode)
                4'd0:   ROM_input=`BNE_EX2;
                4'd1:   ROM_input=`BEQ_EX2;
                4'd2:   ROM_input=`BGZ_EX2;
                4'd3:   ROM_input=`BLZ_EX2;
            endcase
        end
        else    ROM_input=state;
    end
end

// calculate next_state
always @(state or opcode or funct) begin
    case(state)
        // IF
        `IF: next_state=`ID;
        // ID
        `ID: begin
            case(opcode)
                4'd15:  begin
                    case(funct)
                        6'd25:                  next_state=`JPR_EX;
                        6'd26:                  next_state=`JRL_EX;
                        6'd28:                  next_state=`WWD_EX;
                        6'd29:                  next_state=`HLT;
                        default:                next_state=`R_EX; 
                    endcase
                end
                4'd4, 4'd5, 4'd6, 4'd7, 4'd8:   next_state=`I_EX;   // 4:ADI, 5:ORI, 6:LHI, 7:LWD, 8:SWD
                4'd0, 4'd1, 4'd2, 4'd3:         next_state=`B_EX1;  // 0:BNE, 1:BEQ, 2:BGZ, 3:BLZ
                4'd9:                           next_state=`J_EX;
                4'd10:                          next_state=`JAL_EX;
            endcase
        end
        // EX
        `R_EX:  next_state=`R_WB;
        `I_EX: begin
            case(opcode)
                4'd7:       next_state=`ML_MEM; //LWD
                4'd8:       next_state=`MS_MEM; //SWD
                default:    next_state=`I_WB;
            endcase
        end
        `B_EX1:  next_state=`B_EX2;
        // MEM
        `ML_MEM: next_state=`ML_WB;
        // finished state
        `J_EX,      `JAL_EX,    `JRL_EX,    `JPR_EX,    `WWD_EX, 
        `B_EX2,     `MS_MEM,    `R_WB,      `I_WB,      `ML_WB:     next_state=`IF;
        // HLT
        `HLT:     next_state=`HLT;
    endcase
end

endmodule