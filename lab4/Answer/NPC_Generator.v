`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB 
// Engineer: Wu Yuzhang
// 
// Design Name: RISCV-Pipline CPU
// Module Name: NPC_Generator
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Choose Next PC value
//////////////////////////////////////////////////////////////////////////////////
//功能说明
    //NPC_Generator是用来生成Next PC值的模块，根据不同的跳转信号选择不同的新PC值
//输入
    //PCF              旧的PC值
    //JalrTarget       jalr指令的对应的跳转目标
    //BranchTarget     branch指令的对应的跳转目标
    //JalTarget        jal指令的对应的跳转目标
    //BranchE==1       Ex阶段的Branch指令确定跳转
    //JalD==1          ID阶段的Jal指令确定跳转
    //JalrE==1         Ex阶段的Jalr指令确定跳转
//输出
    //PC_In            NPC的值
//实验要求  
    //补全模块  

module NPC_Generator(
    input wire [31:0] PCF, PCE, JalrTarget, BranchTarget, JalTarget, BTB_Target,
    input wire BranchE, JalD, JalrE, BTB_hitF, BHT_brF, BTB_hitE, BHT_brE, Pred_True,
    output reg [31:0] PC_In
    );
    always @(*)begin
        if(JalrE)  PC_In <= JalrTarget;
        else if(BranchE)           
            begin
                if(Pred_True)    PC_In <= PCF+4;
                else    PC_In <= BranchTarget;
            end
        else if( (~BranchE) & (BTB_hitE & BHT_brE))
            PC_In <= PCE+4;
       
        else if(JalD)
            PC_In <= JalTarget;
        else begin
            if(BTB_hitF & BHT_brF)
                PC_In <= BTB_Target;
            else
                PC_In <= PCF+4;
        end
    end
endmodule