`include "ALU.v"
`include "im.v"
`include "dm.v"
`include "RegFile.v"
`include "pc.v"
`include "npc.v"
module datapath(
    input clk,
    input rst,
    input[3:0] Branch,
    input Jump,
    input RegDst,
    input ALUsrc_A,
    input ALUsrc_B,
    input[3:0] ALUctr,
    input[1:0] MemtoReg,
    input RegWr,
    input MemWr,
    input PCWr,
    input ExtOp,
    input Var,
    input[1:0] Set,
    input[1:0] lbyte,
    input sbyte,
    input ra,
    input Jreg,
    output[31:0] instr
);

//取指令
wire[31:0] instr_addr,next_pc;
PC pc(clk,rst,PCWr,next_pc,instr_addr);
im_4k IM(instr_addr[11:2],instr);

//译码,取数
wire[31:0] busA,busB,busW;
wire[4:0] Rtemp,Rw;
mux2_X_5 m1(instr[20:16],instr[15:11],RegDst,Rtemp);
mux2_X_5 m13(Rtemp,5'b11111,ra,Rw);
RegFile RF(clk,rst,RegWr&(~Overflow),instr[25:21],instr[20:16],Rw,busW,busA,busB);
wire[31:0] Bsrc,imm;
extender16_32 Ext(instr[15:0],ExtOp,imm);
mux2_X_32 m2(busB,imm,ALUsrc_B,Bsrc);

wire[4:0] shamt_;
wire[31:0] Asrc,shamt;
mux2_X_5 m7(instr[10:6],busA[4:0],Var,shamt_);
extender5_32 Ext_s(shamt_,1'b0,shamt);
mux2_X_32 m6(busA,shamt,ALUsrc_A,Asrc);

//npc
wire[31:0] pc_add4;//jal,jalr 将pc_add4作为busW写回im[31]
npc NPC(instr_addr,instr,busA,Branch,Jump,Zero,Jreg,next_pc,pc_add4);

//Ex
wire Zero,Sign,Overflow,Carryflag,Sctr;
wire[31:0] ALU_res,st,rb;
ALU alu(Asrc,Bsrc,ALUctr,Zero,Sign,Overflow,Carryflag,ALU_res);
mux2_X_1 m8(Sign,Carryflag,Set[1],Sctr);
mux2_X_32 m9(32'h00000000,32'h00000001,Sctr,st);
mux2_X_32 m10(ALU_res,st,Set[0],rb);

//访存写回
wire[31:0] data_out,ext_byte,mb,data_out_updated,data_in;
wire[7:0] byte;
mux4_X_8 m17(data_out[31:24],data_out[23:16],data_out[15:8],data_out[7:0],ALU_res[1:0],byte);
mux4_X_32 m16({data_out[31:8],busB[7:0]},{data_out[31:16],busB[7:0],data_out[7:0]},{data_out[31:24],busB[7:0],data_out[15:0]},{busB[7:0],data_out[23:0]},ALU_res[1:0],data_out_updated);
mux2_X_32 m15(busB,data_out_updated,sbyte,data_in);
dm_4k DM(ALU_res[11:2],data_in,clk,MemWr,data_out);
extender8_32 Ext_byte(byte,lbyte[1],ext_byte);
mux2_X_32 m11(data_out,ext_byte,lbyte[0],mb);
mux4_X_32 m12(rb,{instr[15:0],16'h0000},pc_add4,mb,MemtoReg,busW);


endmodule