`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/22/2020 08:07:58 PM
// Design Name: 
// Module Name: BTB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*  一个周期 
维护 BTB 表 ,检查PC是否命中 。 工作在IF段 。
IF阶段: PC_IF_Query : 直接预测的pc 
EX阶段: PC_new_key, PC_new_value。 表中需要更新的键值对, 对应BR指令的PC和 , RB指令的跳转地址 。 
IS_BR: 是分支指令,需要更新BTB表
BR_SUCC: 是分支了还是没有分支 : 用于BTH
*/
module btb(
    input  clk, rst,
    output reg btb_hit,        
    input  [31:0] raddr,        
    output reg [31:0] rd_data,  
    input  [1:0]  web,           
    input  [31:0] waddr,
    input  [31:0] wr_data      
);

localparam btb_addr_len = 12;
localparam BTB_SIZE     = 1 << btb_addr_len;

wire [btb_addr_len-1:0]   rbtb_addr;                    // read addr?
wire [31:btb_addr_len ]   rtag_addr;                    // read tag
wire [btb_addr_len-1:0]   wbtb_addr;                    // write addr
wire [31:btb_addr_len ]   wtag_addr;                    // write tag
reg [31:0           ] pred_pc   [BTB_SIZE]; 
reg [31:btb_addr_len] btb_tags  [BTB_SIZE]; 
reg valid [BTB_SIZE];

assign {rtag_addr,rbtb_addr} = raddr;       // analysis into 2 parts
assign {wtag_addr,wbtb_addr} = waddr;       // ~

always @ (*) begin                          //read data
    if( (valid[rbtb_addr]==1'b1) && (btb_tags[rbtb_addr] == rtag_addr) ) begin
        rd_data = pred_pc[rbtb_addr];  
        btb_hit = 1'b1;
    end
    else begin
        rd_data = 32'b0;
        btb_hit = 1'b0;
    end
end

always @ (posedge clk or posedge rst) begin //write data(update BTB)
    if(rst) begin
        for(integer i=0; i<BTB_SIZE; i++) begin
                btb_tags[i]<=0;
                valid[i]<=0;
                pred_pc[i]<=0;
        end
    end
    else
        case(web)
        2'b01:  begin   //need to update branch target 
                pred_pc[wbtb_addr] = wr_data;
                end
        2'b10:  begin   //need to add entry
                pred_pc[wbtb_addr] = wr_data;
                btb_tags[wbtb_addr] = wtag_addr;
                valid[wbtb_addr] = 1'b1;
                end
        2'b11:  begin   //need to remove entry(invalidate entry)
                valid[wbtb_addr] = 1'b0;
                end   
        endcase
end

endmodule