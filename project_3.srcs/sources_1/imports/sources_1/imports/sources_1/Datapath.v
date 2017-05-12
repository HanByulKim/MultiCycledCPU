`define WORD_SIZE 16    // data and address word size

module Datapath (
  output wire readM,                       // read from memory  
  output wire writeM,                       // write from memory
  output wire [`WORD_SIZE-1:0] address,    // current address for data
  inout [`WORD_SIZE-1:0] data,        // data being input or output
  input inputReady,                   // indicates that data is ready from the input port
  input reset_n,                      // active-low RESET signal
  input clk,                          // clock signal
  
  // for debuging/testing purpose
  output reg [`WORD_SIZE-1:0] num_inst,   // number of instruction during execution
  output [`WORD_SIZE-1:0] output_port, // this will be used for a "WWD" instruction
  output is_halted                      // this means cpu is halted
  
);

// Control signal
wire [1:0] PCSrc; wire [3:0] ALUOp; wire ALUSrcB; wire ALUSrcA; wire RegWrite; wire [1:0] RegDst;
wire PCWriteCond; wire PCWrite; wire IorD; wire MemtoReg; wire IRWrite;
wire [3:0] ALUCtrl;             // ALU control signal

wire [3:0] opcode;              
wire [1:0] rs;
wire [1:0] rt;
wire [1:0] rd;
wire [5:0] funct;

wire [`WORD_SIZE-1:0] rsData;           //register file output for rs
wire [`WORD_SIZE-1:0] rtData;           //register file output for rt
wire [`WORD_SIZE-1:0] writeData;        //register write data

// sign-extended immediate
wire [`WORD_SIZE-1:0] Bimm;

// ALU input
wire [`WORD_SIZE-1:0] Aalu;
wire [`WORD_SIZE-1:0] Balu;

// ALU output
wire [`WORD_SIZE-1:0] C;
wire Zero; // branch taken => Zero=1

// temporary  registers
reg [`WORD_SIZE-1:0] Areg;      // register between register file and ALU
reg [`WORD_SIZE-1:0] Breg;      // register between register file and ALU
reg [`WORD_SIZE-1:0] ALUOut;    // ALU output register
reg [`WORD_SIZE-1:0] instreg;   // instruction register
reg [`WORD_SIZE-1:0] memreg;    // memory data register

reg [`WORD_SIZE-1:0] PC;        // PC


// Datapath module declaration
Control_unit ctrl_unit(.opcode(opcode), .funct(funct), .CLK(clk), .reset_n(reset_n), .PCSrc(PCSrc), .ALUOp(ALUOp), .ALUSrcB(ALUSrcB), .ALUSrcA(ALUSrcA), .RegWrite(RegWrite), .RegDst(RegDst), .PCWriteCond(PCWriteCond), .PCWrite(PCWrite), .IorD(IorD), .ReadM(readM), .WriteM(writeM), .MemtoReg(MemtoReg), .IRWrite(IRWrite));
ALUctrl_unit aluctrl_unit(.ALUOp(ALUOp), .funct(funct), .ALUCtrl(ALUCtrl));
Register register(.clk(clk), .write(RegWrite), .addr1(rs), .addr2(rt), .addr3(rd), .data3(writeData), .data1(rsData), .data2(rtData));
ALU alu(.A(Aalu), .B(Balu), .ALUCtrl(ALUCtrl), .C(C), .Zero(Zero), .output_port(output_port), .isHLT(is_halted));

assign address = (IorD==0) ? PC : ALUOut;       // address for memory access

// instruction register assignment
assign opcode = instreg[15:12];
assign rs=instreg[11:10];
assign rt=instreg[9:8];
assign funct = instreg[5:0];


// ALU input assignment
assign Bimm = (instreg[7] == 1) ? {8'b11111111,instreg[7:0]} : {8'b00000000,instreg[7:0]}; // sign-extend
assign Aalu = (ALUSrcA==0) ? PC : Areg;     // MUX
assign Balu = (ALUSrcB==0) ? Breg : Bimm;   // MUX

// Write Back assignment
assign writeData=((MemtoReg == 1) ? memreg : ALUOut); // MUX
assign rd=(RegDst[1:0] == 0) ? instreg[9:8] : ((RegDst[1:0] == 1) ? instreg[7:6] : 2); // MUX

// Memory access assignment
assign data=(writeM == 1) ? rtData : 16'bz;  // assign data to write when writeM signal equals to 1


// check reset_n
always @(negedge reset_n) begin
    num_inst<=-1;
    PC<=0;
end

// save values temporarily
always@(negedge clk) begin  // since control signal is synchronized with posedge, negedge is used here.
    Areg <= rsData;
    Breg <= rtData;
    ALUOut <= C;
    memreg <= data;
end

// write PC when jump or branch
always @(posedge PCWrite or posedge PCWriteCond) begin
    #5 // wait for Zero
    if(PCWrite == 1 || ((PCWriteCond == 1) && (Zero == 1))) begin
        case (PCSrc)
            2'b00: PC = C;                          // update PC with ALU result immediately 
            2'b01: PC = ALUOut;                     // update PC with saved ALU result
            2'b10: PC = {PC[15:12],instreg[11:0]};  // update PC with jump target address
        endcase
    end
end

// when data is ready to be read, update data and increase num_inst and PC 
always@(posedge inputReady) begin
    if(IRWrite==1) begin
        instreg[15:0] <= data[15:0];
        num_inst <= num_inst +1;
        PC <= PC+1;
    end
end
endmodule