`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB 
// Engineer: Wu Yuzhang
// 
// Design Name: RISCV-Pipline CPU
// Module Name: RegisterFile
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: 
//////////////////////////////////////////////////////////////////////////////////
//功能说明
   

module CSRFile(
    input wire clk,
    input wire rst,
    input wire WE3,
    input wire [5:0] A1,
    input wire [5:0] A3,
    input wire [31:0] WD3,
    output wire [31:0] RD1 
    );

    reg [31:0] CSRFile[31:0];
    integer i;
    //
    assign RD1 = CSRFile[A1];
    always@(negedge clk or posedge rst) 
    begin 
        if(rst)     for(i=0;i<32;i=i+1) CSRFile[i][31:0]<=32'b0;
        else if( WE3 == 1'b1 )    CSRFile[A3]<=WD3;   
    end
    //    
    
endmodule
