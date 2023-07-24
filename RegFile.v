module RegFile (
    input clk,
    input rst,
    input wEn,
    input[4:0] Ra,
    input[4:0] Rb,
    input[4:0] Rw,
    input[31:0] busW,
    output[31:0] busA,
    output[31:0] busB);

    reg[31:0] regs[31:0];//32*32bits registers
    integer i;
    //读操作为组合逻辑
    assign busA=regs[Ra];
    assign busB=regs[Rb];

    //写操作为时序逻辑
    always @(posedge clk or negedge rst) begin
        if(!rst)begin//rst为0进行复位
            for(i=0;i<32;i=i+1)regs[i]<=32'h00000000;
        end
        else begin
            if(wEn&&(Rw!=5'b0))begin//写使能为1并且写入地址不为0（$zero中存储值0）
                regs[Rw]<=busW;
            end
        end
    end
endmodule