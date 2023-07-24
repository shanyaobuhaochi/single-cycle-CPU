`include "adder.v"
`include "extender.v"
`include "mux.v"
module npc(
    input[31:0] pc,
    input[31:0] instr,
    input[31:0] busA,
    input[3:0] Branch,
    input Jump,
    input Zero,
    input Jreg,
    output[31:0] next_pc,
    output[31:0] pc_add4
);
wire[5:0] op;
assign op=instr[31:26];
wire[31:0] pc_add4_imm,Btarget,Jtarget,t_pc;
adder a1(pc,32'h00000004,pc_add4);
wire[29:0] imm_;
extender16_30 Ext_(instr[15:0],1'b1,imm_);
adder a2(pc,{imm_,2'b00},pc_add4_imm);

wire beq,bne,bgtz,bgez,bltz,blez;
assign beq=Zero&&(~Branch[3])&&(~Branch[2])&&(~Branch[1])&&Branch[0];
assign bne=(~Zero)&&(~Branch[3])&&(~Branch[2])&&Branch[1]&&Branch[0];
assign bgtz=(busA!=0&&!busA[31])&&(~Branch[3])&&Branch[2]&&(~Branch[1])&&Branch[0];
assign bgez=(busA==0|!busA[31])&&(~Branch[3])&&Branch[2]&&Branch[1]&&Branch[0];
assign bltz=(busA!=0&&busA[31])&&Branch[3]&&(~Branch[2])&&(~Branch[1])&&Branch[0];
assign blez=(busA==0|busA[31])&&Branch[3]&&(~Branch[2])&&Branch[1]&&Branch[0];

mux2_X_32 m3(pc_add4,pc_add4_imm,beq|bne|bgtz|bgez|bltz|blez,Btarget);
assign Jtarget={pc[31:28],instr[25:0],{2'b00}};
mux2_X_32 m4(Btarget,Jtarget,Jump,t_pc);
mux2_X_32 m14(t_pc,busA,Jreg,next_pc);
endmodule