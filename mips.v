`include "control_unit.v"
`include "datapath.v"
module mips(
  input clk,
  input rst
);
wire[31:0] instr;
wire Jump,RegDst,ALUsrc_A,ALUsrc_B,RegWr,MemWr,PCWr,ExtOp,Var,ra,Jreg,sbyte;
wire[1:0] Set,lbyte,MemtoReg;
wire[3:0] ALUctr,Branch;
control_unit CU(instr[31:26],instr[20:16],instr[5:0],Branch,Jump,RegDst,ALUsrc_A,ALUsrc_B,ALUctr,MemtoReg,RegWr,MemWr,PCWr,ExtOp,Var,Set,lbyte,sbyte,ra,Jreg);
datapath DP(clk,rst,Branch,Jump,RegDst,ALUsrc_A,ALUsrc_B,ALUctr,MemtoReg,RegWr,MemWr,PCWr,ExtOp,Var,Set,lbyte,sbyte,ra,Jreg,instr);

always @(instr) begin
  if(instr==32'hfc000000)begin
    $finish;
  end
end
endmodule