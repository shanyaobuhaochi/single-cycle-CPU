module PC (
    input clk,
    input rst,
    input PCWr,
    input [31:0] npc,
    output reg [31:0]pc
);
always @(posedge clk or negedge rst)begin//时钟上升沿读pc
    if(!rst)pc<=32'h00003000;//与Mars的Memory Configuration相匹配
    else if(PCWr)begin
        pc<=npc;
    end
end
endmodule