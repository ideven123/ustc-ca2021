`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB 
// Engineer: Wu Yuzhang
// 
// Design Name: RISCV-Pipline CPU
// Module Name: ControlUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: RISC-V Instruction Decoder
//////////////////////////////////////////////////////////////////////////////////
//功能和接口说明
    //ControlUnit       是本CPU的指令译码器，组合逻辑电路
//输入
    // Op               是指令的操作码部分
    // Fn3              是指令的func3部分
    // Fn7              是指令的func7部分
//输出
    // JalD==1          表示Jal指令到达ID译码阶段
    // JalrD==1         表示Jalr指令到达ID译码阶段
    // RegWriteD        表示ID阶段的指令对应的寄存器写入模式
    // MemToRegD==1     表示ID阶段的指令需要将data memory读取的值写入寄存器,
    // MemWriteD        共4bit，为1的部分表示有效，对于data memory的32bit字按byte进行写入,MemWriteD=0001表示只写入最低1个byte，和xilinx bram的接口类似
    // LoadNpcD==1      表示将NextPC输出到ResultM
    // RegReadD         表示A1和A2对应的寄存器值是否被使用到了，用于forward的处理
    // BranchTypeD      表示不同的分支类型，所有类型定义在Parameters.v中
    // AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v中
    // AluSrc2D         表示Alu输入源2的选择
    // AluSrc1D         表示Alu输入源1的选择
    // ImmType          表示指令的立即数格式
//实验要求  
    //补全模块  
`include "Parameters.v"   
module ControlUnit(
    input wire [6:0] Op,
    input wire [2:0] Fn3,
    input wire [6:0] Fn7,

    output wire JalD,
    output wire JalrD,
    output reg [2:0] RegWriteD,
    output reg MemToRegD,
    output reg [3:0] MemWriteD,
    output reg LoadNpcD,
    output reg [1:0] RegReadD,
    output reg [2:0] BranchTypeD,
    output reg [3:0] AluContrlD,
    output reg [1:0] AluSrc2D,
    output reg AluSrc1D,
    output reg [2:0] ImmType,     
    //csr
    output reg csr_wenD,
    output reg csr_immorregD
    ); 
assign JalD = (Op == 7'b1101111) ? 1:0 ;
assign JalrD  =  (Op == 7'b1100111) ? 1:0 ;

    always @(*) begin
    case (Op)
        7'b1101111: //Jal
        begin
            csr_wenD = 0;
            csr_immorregD = 0;
            RegWriteD <= `LW;
            MemToRegD <= 1'b0;
            MemWriteD <= 4'b0000;
            LoadNpcD <= 1'b1;
            RegReadD <= 2'b00;
            BranchTypeD <= 3'b000;
            AluContrlD <= `ADD;
            AluSrc2D <= 2'b00;  
            AluSrc1D <= 1'b0;   
            ImmType <= `JTYPE;
        end          
        7'b1100111: //Jalr
        begin
            csr_wenD = 0;
            csr_immorregD = 0;
            RegWriteD <= `LW;
            MemToRegD <= 1'b0;
            MemWriteD <= 4'b0000;
            LoadNpcD <= 1'b1;
            RegReadD <= 2'b10;
            BranchTypeD <= 3'b000;
            AluContrlD <= `ADD;
            AluSrc2D <= 2'b10;  //imm
            AluSrc1D <= 1'b0;   //rs1
            ImmType <= `ITYPE;
        end
        7'b1100011: //Branch
            begin
                csr_wenD = 0;
                csr_immorregD = 0;
                RegWriteD <= 3'b000;
                MemToRegD <= 1'b0;
                MemWriteD <= 4'b0000;
                LoadNpcD <= 1'b0;
                RegReadD <= 2'b11; 
                AluContrlD <= `ADD;
                AluSrc2D <= 2'b00;  //reg
                AluSrc1D <= 1'b0;   //reg
                ImmType <= `BTYPE;
                case(Fn3)
                    3'b000: BranchTypeD <= `BEQ;
                    3'b001: BranchTypeD <= `BNE;
                    3'b100: BranchTypeD <= `BLT;
                    3'b101: BranchTypeD <= `BGE;
                    3'b110: BranchTypeD <= `BLTU;
                    3'b111: BranchTypeD <= `BGEU;
                    default: BranchTypeD <= 3'b000;
                endcase
            end
            7'b0110111: //LUI
            begin
                csr_wenD = 0;
                csr_immorregD = 0;
                RegWriteD <= `LW;
                MemToRegD <= 1'b0;
                MemWriteD <= 4'b0000;
                LoadNpcD <= 1'b0;
                RegReadD <= 2'b00;
                BranchTypeD <= 3'b000;
                AluContrlD <= `LUI;
                AluSrc2D <= 2'b10;  //imm
                AluSrc1D <= 1'b0;   //irrelavant
                ImmType <= `UTYPE;
            end
            7'b0010111: //AUIPC
            begin
                csr_wenD = 0;
                csr_immorregD = 0;                
                RegWriteD <= `LW;
                MemToRegD <= 1'b0;
                MemWriteD <= 4'b0000;
                LoadNpcD <= 1'b0;
                RegReadD <= 2'b00;
                BranchTypeD <= 3'b000;
                AluContrlD <= `ADD;
                AluSrc2D <= 2'b10;  //imm
                AluSrc1D <= 1'b1;   //pc
                ImmType <= `UTYPE;
            end 
            7'b0010011: //alu imm
            begin
                csr_wenD = 0;
                csr_immorregD = 0;
                RegWriteD <= `LW;
                MemToRegD <= 1'b0;
                MemWriteD <= 4'b0000;
                LoadNpcD <= 1'b0;
                RegReadD <= 2'b10;
                BranchTypeD <= 3'b000;
                AluSrc1D <= 1'b0;   //rs1
                ImmType <= `ITYPE;
                case(Fn3)
                    3'b000: 
                    begin
                        AluContrlD <= `ADD;
                        AluSrc2D <= 2'b10;  //imm
                    end
                    3'b010: 
                    begin
                        AluContrlD <= `SLT;
                        AluSrc2D <= 2'b10;  //imm
                    end
                    3'b011: 
                    begin
                        AluContrlD <= `SLTU;
                        AluSrc2D <= 2'b10;  //imm
                    end
                    3'b100:
                    begin
                        AluContrlD <= `XOR;
                        AluSrc2D <= 2'b10;  //imm
                    end
                    3'b110:
                    begin
                        AluContrlD <= `OR;
                        AluSrc2D <= 2'b10;  //imm
                    end
                    3'b111:
                    begin
                        AluContrlD <= `AND;
                        AluSrc2D <= 2'b10;  //imm
                    end
                    3'b001:
                    begin 
                        AluContrlD <= `SLL;
                        AluSrc2D <= 2'b01;  //shamt
                    end
                    3'b101:
                    begin
                        case(Fn7)
                            7'b0000000: 
                            begin
                                AluContrlD <= `SRL;
                                AluSrc2D <= 2'b01;
                            end
                            7'b0100000:
                            begin
                                AluContrlD <= `SRA;
                                AluSrc2D <= 2'b01;
                            end
                        endcase
                    end
                endcase
            end 
            7'b0110011: //alu reg
            begin
                csr_wenD = 0;
                csr_immorregD = 0;
                RegWriteD <= `LW;
                MemToRegD <= 1'b0;
                MemWriteD <= 4'b0000;
                LoadNpcD <= 1'b0;
                RegReadD <= 2'b11;
                BranchTypeD <= 3'b000;
                AluSrc2D <= 2'b00;  //rs2
                AluSrc1D <= 1'b0;   //rs1
                ImmType <= `RTYPE;
                case(Fn3)
                    3'b000:
                    begin
                        case(Fn7)
                            7'b0000000: AluContrlD <= `ADD;
                            7'b0100000: AluContrlD <= `SUB;
                        endcase
                    end
                    3'b001: AluContrlD <= `SLL;
                    3'b010: AluContrlD <= `SLT;
                    3'b011: AluContrlD <= `SLTU;
                    3'b100: AluContrlD <= `XOR;
                    3'b101:
                    begin
                        case(Fn7)
                            7'b0000000: AluContrlD <= `SRL;
                            7'b0100000: AluContrlD <= `SRA;
                        endcase
                    end
                    3'b110: AluContrlD <= `OR;
                    3'b111: AluContrlD <= `AND;
                endcase
            end                                    
            7'b0000011: //load
            begin
                csr_wenD = 0;
                csr_immorregD = 0;
                MemToRegD <= 1'b1;
                MemWriteD <= 4'b0000;
                LoadNpcD <= 1'b0;
                RegReadD <= 2'b10;
                BranchTypeD <= 3'b000;
                AluContrlD <= `ADD;
                AluSrc2D <= 2'b10;  //imm
                AluSrc1D <= 1'b0;   //rs1
                ImmType <= `ITYPE;
                case(Fn3)
                    3'b000: RegWriteD <= `LB;
                    3'b001: RegWriteD <= `LH;
                    3'b010: RegWriteD <= `LW;
                    3'b100: RegWriteD <= `LBU;
                    3'b101: RegWriteD <= `LHU;
                endcase
            end
            7'b0100011: //store
            begin
                csr_wenD = 0;
                csr_immorregD = 0;
                RegWriteD <= 3'b000;   
                MemToRegD <= 1'b0;
                LoadNpcD <= 1'b0;
                RegReadD <= 2'b11;
                BranchTypeD <= 3'b000;
                AluContrlD <= `ADD;
                AluSrc2D <= 2'b10;  //imm
                AluSrc1D <= 1'b0;   //rs1
                ImmType <= `STYPE;
                case(Fn3)
                    3'b000: MemWriteD <= 4'b0001;
                    3'b001: MemWriteD <= 4'b0011;
                    3'b010: MemWriteD <= 4'b1111;
                endcase
            end
            7'b1110011:
            begin
                csr_wenD = 1;
                MemWriteD = 4'b0000;
                RegWriteD <= `LW;   
                MemToRegD <= 1'b0;
                LoadNpcD <= 1'b0; 
                BranchTypeD <= 3'b000;       
                AluSrc2D <= 2'b00;  //imm
                AluSrc1D <= 1'b0;   //rs1
                ImmType <= 0;
                RegReadD <= 2'b11;
                case(Fn3)
                3'b001:
                    begin
                        AluContrlD = `OP1 ;
                        csr_immorregD = 0 ;
                    end
                3'b010:
                    begin
                        AluContrlD = `OR  ;
                        csr_immorregD = 0  ;
                    end
                3'b011:
                    begin
                        AluContrlD = `NAND;
                        csr_immorregD = 0;
                    end           
                3'b101:
                    begin
                        AluContrlD = `OP1 ;
                        csr_immorregD = 1;
                    end
                3'b110:
                    begin
                        AluContrlD = `OR  ;
                        csr_immorregD = 1;
                    end
                3'b111:
                    begin
                        AluContrlD = `NAND;
                        csr_immorregD = 1;
                    end                    
                endcase
            end
               
            default
            begin
                csr_wenD = 0;
                csr_immorregD = 0;
                RegWriteD <= 3'b000;
                MemToRegD <= 1'b0;
                MemWriteD <= 4'b0000;
                LoadNpcD <= 1'b0;
                RegReadD <= 2'b00;
                BranchTypeD <= 3'b000;
                AluContrlD <= 4'd15;
                AluSrc2D <= 2'b00;  
                AluSrc1D <= 1'b0;   
                ImmType <= `JTYPE;
                
            end
    endcase    
    end

    // ÷ehdã
    
endmodule


                    