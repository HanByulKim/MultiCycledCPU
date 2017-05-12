`timescale 1ns / 1ps

module ALUctrl_unit(
    input [3:0] ALUOp,
    input [5:0] funct,
    output reg [3:0] ALUCtrl
    );
    always @(*) begin
        case(ALUOp)
            4'd15: begin
                case(funct)
                    4'd0:  ALUCtrl=4'b0000; //ADD
                    4'd1:  ALUCtrl=4'b0001; //SUB
                    4'd2:  ALUCtrl=4'b0010; //AND
                    4'd3:  ALUCtrl=4'b0011; //ORR
                    4'd4:  ALUCtrl=4'b0100; //NOT
                    4'd5:  ALUCtrl=4'b0101; //TCP
                    4'd6:  ALUCtrl=4'b0110; //SHL
                    4'd7:  ALUCtrl=4'b0111; //SHR
                endcase
            end
                    4'd4: ALUCtrl = 4'b0000; //ADI
                    4'd5: ALUCtrl = 4'b0011; //ORI            
                    4'd6: ALUCtrl = 4'b1000; //LHI
                    4'd1: ALUCtrl = 4'b0001; //BEQ
                    4'd0: ALUCtrl = 4'b1001; //BNE
                    4'd2: ALUCtrl = 4'b1010; //BGZ
                    4'd3: ALUCtrl = 4'b1011; //BLZ
                    4'd7: ALUCtrl = 4'b1100; //JPR or JRL
                    4'd14: ALUCtrl = 4'b1101;//WWD
                    4'd13: ALUCtrl = 4'b1111;//HLT
        endcase
    end
    
endmodule
