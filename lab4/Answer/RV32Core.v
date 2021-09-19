`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB 
// Engineer: Wu Yuzhang
// 
// Design Name: RISCV-Pipline CPU
// Module Name: RV32Core
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Top level of our CPU Core
//////////////////////////////////////////////////////////////////////////////////
//功能说明
    //RV32I 指令集CPU的顶层模块
//实验要求  
    //无需修改

module RV32Core(
    input wire CPU_CLK,
    input wire CPU_RST,
    input wire [31:0] CPU_Debug_DataRAM_A2,
    input wire [31:0] CPU_Debug_DataRAM_WD2,
    input wire [3:0] CPU_Debug_DataRAM_WE2,
    output wire [31:0] CPU_Debug_DataRAM_RD2,
    input wire [31:0] CPU_Debug_InstRAM_A2,
    input wire [31:0] CPU_Debug_InstRAM_WD2,
    input wire [ 3:0] CPU_Debug_InstRAM_WE2,
    output wire [31:0] CPU_Debug_InstRAM_RD2
    );
	//wire values definitions
    wire StallF, FlushF, StallD, FlushD, StallE, FlushE, StallM, FlushM, StallW, FlushW;
    wire [31:0] PC_In;
    wire [31:0] PCF;
    wire [31:0] Instr, PCD;
    wire JalD, JalrD, LoadNpcD, MemToRegD, AluSrc1D;
    wire [2:0] RegWriteD;
    wire [3:0] MemWriteD;
    wire [1:0] RegReadD;
    wire [2:0] BranchTypeD;
    wire [3:0] AluContrlD;
    wire [1:0] AluSrc2D;
    wire [2:0] RegWriteW;
    wire [4:0] RdW;
    wire [31:0] RegWriteData;
    wire [31:0] DM_RD_Ext;
    wire [2:0] ImmType;
    wire [31:0] ImmD;
    wire [31:0] JalNPC;
    wire [31:0] BrNPC; 
    wire [31:0] ImmE;
    wire [6:0] OpCodeD, Funct7D;
    wire [2:0] Funct3D;
    wire [4:0] Rs1D, Rs2D, RdD;
    wire [4:0] Rs1E, Rs2E, RdE;
    wire [31:0] RegOut1D;
    wire [31:0] RegOut1E;
    wire [31:0] RegOut2D;
    wire [31:0] RegOut2E;
    wire JalrE;
    wire [2:0] RegWriteE;
    wire MemToRegE;
    wire [3:0] MemWriteE;
    wire LoadNpcE;
    wire [1:0] RegReadE;
    wire [2:0] BranchTypeE;
    wire [3:0] AluContrlE;
    wire AluSrc1E;
    wire [1:0] AluSrc2E;
    wire [31:0] Operand1;
    wire [31:0] Operand2;
    wire BranchE;
    wire [31:0] AluOutE;
    wire [31:0] AluOutM; 
    wire [31:0] ForwardData1;
    wire [31:0] ForwardData2;
    wire [31:0] PCE;
    wire [31:0] StoreDataM; 
    wire [4:0] RdM;
    wire [31:0] PCM;
    wire [2:0] RegWriteM;
    wire MemToRegM;
    wire [3:0] MemWriteM;
    wire LoadNpcM;
    wire [31:0] DM_RD;
    wire [31:0] ResultM;
    wire [31:0] ResultW;
    wire MemToRegW;
    wire [1:0] Forward1E;
    wire [1:0] Forward2E;
    wire [1:0] LoadedBytesSelect;
    //add cache
    wire DCacheMiss;
    // add csr
    wire csr_wenD , csr_wenE ,csr_wenM;
    wire csr_immorregD , csr_immorregE;
    wire [5:0] csr_addrD , csr_addrE;
    wire [31:0]  csr_rout_dataD ,csr_rout_dataE , csr_rout_dataM;
    wire [31:0] needforward;
    wire [31:0] nocsr_Operand1,nocsr_Operand2  ,nocsr_ResultM , csr_Operand1 ;
    wire [31:0] csr_zimmextD , csr_zimmextE;

    //wire values assignments
    assign {Funct7D, Rs2D, Rs1D, Funct3D, RdD, OpCodeD} = Instr;
    assign JalNPC=ImmD+PCD;
    
    assign needforward = (csr_wenM == 0)? AluOutM : csr_rout_dataM ;
    assign ForwardData1 = Forward1E[1]?(needforward):( Forward1E[0]?RegWriteData:RegOut1E );
    assign ForwardData2 = Forward2E[1]?(needforward):( Forward2E[0]?RegWriteData:RegOut2E );
    
    assign csr_zimmextD = { {27{1'b0}} , Rs1D};

    assign nocsr_Operand1 = AluSrc1E? PCE:ForwardData1;
    assign csr_Operand1 = csr_immorregE? csr_zimmextE:ForwardData1; 
    assign Operand1 = csr_wenE? csr_Operand1:nocsr_Operand1;
    
    assign nocsr_Operand2 = AluSrc2E[1]?(ImmE):( AluSrc2E[0]?Rs2E:ForwardData2 );
    assign Operand2 = csr_wenE? csr_rout_dataE:nocsr_Operand2;

    
    assign nocsr_ResultM = LoadNpcM ? (PCM+4) : AluOutM;
    assign ResultM = csr_wenM? csr_rout_dataM : nocsr_ResultM;  
    assign RegWriteData = ~MemToRegW ? ResultW:DM_RD_Ext;
    assign csr_addrD = Instr[31:20] ;

 
    //add BTB

    // BR指令 , 且缓存里有
    wire BTB_hitF, BTB_hitD, BTB_hitE;
    wire [31:0] PPCF, PPCD, PPCE;
    wire BTB_True;
    wire [1:0] BTB_Update;
    //BHT
    localparam  bht_addr_len = 12;
    wire BHT_brF, BHT_brD, BHT_brE;
    wire [31:0] FPPCF, FPPCD, FPPCE;    //Final Predicted (branch) PC
    wire Pred_True;
    assign BTB_True = (PPCE == BrNPC)? 1: 0;
    assign BTB_Update = BranchE ? (BTB_hitE ? (BHT_brE ? 2'b00 : 2'b11) : 2'b10) : (BTB_hitE ? (BHT_brE? 2'b00 : 2'b11): 2'b00); //不用跳转 , 但是 BHT 预测跳转
    //01 need to update branch target
    //10 need to add entry
    //11 need to remove entry

    assign FPPCF = BHT_brF? (BTB_hitF? PPCF : (PCF+4)) : (PCF+4);
    assign Pred_True = (FPPCE==BrNPC) ? 1'b1 : 1'b0;
    
    //统计分支预测信息
     reg [31:0] branch_time,flush_time,true_time;
     always @ (posedge CPU_CLK or posedge CPU_RST) begin
         if(CPU_RST) begin
            branch_time = 0;
            flush_time = 0;
            true_time = 0;
         end
         else begin
            if(BranchTypeE != 3'b000)
                branch_time = branch_time + 1;
            if((BranchTypeE != 3'b000) & FlushD) 
                flush_time = flush_time + 1;
            if ((BranchTypeE != 3'b000) & (~FlushD))
                true_time = true_time + 1;
         end
     end
    //Module connections
    // ---------------------------------------------
    // PC-IF
    // ---------------------------------------------
    
    //csr_control 

    CSRFile CSRFile1(
        .clk(CPU_CLK),
        .rst(CPU_RST),
        .WE3(csr_wenE),
        .A1(csr_addrD),
        .A3(csr_addrE),
        .WD3(AluOutE),
        .RD1(csr_rout_dataD)
    );

    btb btb1(
        .clk(CPU_CLK),
        .rst(CPU_RST),
        .btb_hit(BTB_hitF),     //Whether entry of this pc exists
        .raddr(PCF),        //pc(addr)
        .rd_data(PPCF),     //Predicted Branch Target
        .web(BTB_Update),   //Update BTB in which way or not
        .waddr(PCE),        //BR instruction 
        .wr_data(BrNPC)     //Update to what(new branch target)
    );

    
    bht #(
    .bht_addr_len (bht_addr_len)
    )
    bht1(
    .clk(CPU_CLK),
    .rst(CPU_RST), 
    .BranchE(BranchE),        
    .raddr(PCF[bht_addr_len-1:0]),     
    .waddr(PCE[bht_addr_len-1:0]),  
    .pred_taken(BHT_brF)        
    );

    NPC_Generator NPC_Generator1(
        .PCF(PCF),
        .PCE(PCE),
        .JalrTarget(AluOutE), 
        .BranchTarget(BrNPC), 
        .JalTarget(JalNPC),
        .BTB_Target(PPCF),
        .BranchE(BranchE),
        .JalD(JalD),
        .JalrE(JalrE),
        .BTB_hitF(BTB_hitF),
        .BHT_brF(BHT_brF),
        .BTB_hitE(BTB_hitE),
        .BHT_brE(BHT_brE),
        .Pred_True(Pred_True),
        .PC_In(PC_In)
    ); 

    IFSegReg IFSegReg1(
        .clk(CPU_CLK),
        .en(~StallF),
        .clear(FlushF), 
        .PC_In(PC_In),
        .PCF(PCF)
    );

    // ---------------------------------------------
    // ID stage
    // ---------------------------------------------
    IDSegReg IDSegReg1(
        .clk(CPU_CLK),
        .clear(FlushD),
        .en(~StallD),
        .A(PCF),
        .RD(Instr),
        .A2(CPU_Debug_InstRAM_A2),
        .WD2(CPU_Debug_InstRAM_WD2),
        .WE2(CPU_Debug_InstRAM_WE2),
        .RD2(CPU_Debug_InstRAM_RD2),
        .PCF(PCF),
        .PCD(PCD),
        .PPCF(PPCF),
        .PPCD(PPCD),
        .BTB_hitF(BTB_hitF),
        .BTB_hitD(BTB_hitD),
        .FPPCF(FPPCF),
        .FPPCD(FPPCD),
        .BHT_brF(BHT_brF),
        .BHT_brD(BHT_brD)
    );

    ControlUnit ControlUnit1(
        .Op(OpCodeD),
        .Fn3(Funct3D),
        .Fn7(Funct7D),
        .JalD(JalD),
        .JalrD(JalrD),
        .RegWriteD(RegWriteD),
        .MemToRegD(MemToRegD),
        .MemWriteD(MemWriteD),
        .LoadNpcD(LoadNpcD),
        .RegReadD(RegReadD),
        .BranchTypeD(BranchTypeD),
        .AluContrlD(AluContrlD),
        .AluSrc1D(AluSrc1D),
        .AluSrc2D(AluSrc2D),
        .ImmType(ImmType),
        .csr_wenD(csr_wenD),
        .csr_immorregD(csr_immorregD)
    );

    ImmOperandUnit ImmOperandUnit1(
        .In(Instr[31:7]),
        .Type(ImmType),
        .Out(ImmD)
    );

    RegisterFile RegisterFile1(
        .clk(CPU_CLK),
        .rst(CPU_RST),
        .WE3(|RegWriteW),
        .A1(Rs1D),
        .A2(Rs2D),
        .A3(RdW),
        .WD3(RegWriteData),
        .RD1(RegOut1D),
        .RD2(RegOut2D)
    );

    // ---------------------------------------------
    // EX stage
    // ---------------------------------------------
    EXSegReg EXSegReg1(
        .clk(CPU_CLK),
        .en(~StallE),
        .clear(FlushE),
        .PCD(PCD),
        .PCE(PCE), 
        .JalNPC(JalNPC),
        .BrNPC(BrNPC), 
        .ImmD(ImmD),
        .ImmE(ImmE),
        .RdD(RdD),
        .RdE(RdE),
        .Rs1D(Rs1D),
        .Rs1E(Rs1E),
        .Rs2D(Rs2D),
        .Rs2E(Rs2E),
        .RegOut1D(RegOut1D),
        .RegOut1E(RegOut1E),
        .RegOut2D(RegOut2D),
        .RegOut2E(RegOut2E),
        .JalrD(JalrD),
        .JalrE(JalrE),
        .RegWriteD(RegWriteD),
        .RegWriteE(RegWriteE),
        .MemToRegD(MemToRegD),
        .MemToRegE(MemToRegE),
        .MemWriteD(MemWriteD),
        .MemWriteE(MemWriteE),
        .LoadNpcD(LoadNpcD),
        .LoadNpcE(LoadNpcE),
        .RegReadD(RegReadD),
        .RegReadE(RegReadE),
        .BranchTypeD(BranchTypeD),
        .BranchTypeE(BranchTypeE),
        .AluContrlD(AluContrlD),
        .AluContrlE(AluContrlE),
        .AluSrc1D(AluSrc1D),
        .AluSrc1E(AluSrc1E),
        .AluSrc2D(AluSrc2D),
        .AluSrc2E(AluSrc2E),
        .csr_wenD(csr_wenD),
        .csr_wenE(csr_wenE),
        .csr_immorregD(csr_immorregD),
        .csr_immorregE(csr_immorregE),
        .csr_rout_dataD(csr_rout_dataD),
        .csr_rout_dataE(csr_rout_dataE),
        .csr_zimmextD(csr_zimmextD),
        .csr_zimmextE(csr_zimmextE),
        .csr_addrD(csr_addrD),
        .csr_addrE(csr_addrE),
        .PPCD(PPCD),
        .PPCE(PPCE),
        .BTB_hitD(BTB_hitD),
        .BTB_hitE(BTB_hitE),
        .FPPCD(FPPCD),
        .FPPCE(FPPCE),
        .BHT_brD(BHT_brD),
        .BHT_brE(BHT_brE) 
    	); 

    ALU ALU1(
        .Operand1(Operand1),
        .Operand2(Operand2),
        .AluContrl(AluContrlE),
        .AluOut(AluOutE)
    	);

    BranchDecisionMaking BranchDecisionMaking1(
        .BranchTypeE(BranchTypeE),
        .Operand1(Operand1),
        .Operand2(Operand2),
        .BranchE(BranchE)
        );

    // ---------------------------------------------
    // MEM stage
    // ---------------------------------------------
    MEMSegReg MEMSegReg1(
        .clk(CPU_CLK),
        .en(~StallM),
        .clear(FlushM),
        .AluOutE(AluOutE),
        .AluOutM(AluOutM), 
        .ForwardData2(ForwardData2),
        .StoreDataM(StoreDataM), 
        .RdE(RdE),
        .RdM(RdM),
        .PCE(PCE),
        .PCM(PCM),
        .RegWriteE(RegWriteE),
        .RegWriteM(RegWriteM),
        .MemToRegE(MemToRegE),
        .MemToRegM(MemToRegM),
        .MemWriteE(MemWriteE),
        .MemWriteM(MemWriteM),
        .LoadNpcE(LoadNpcE),
        .LoadNpcM(LoadNpcM),
        .csr_wenE(csr_wenE),
        .csr_wenM(csr_wenM),
        .csr_rout_dataE(csr_rout_dataE),
        .csr_rout_dataM(csr_rout_dataM)
    );

    // ---------------------------------------------
    // WB stage
    // ---------------------------------------------
    WBSegReg WBSegReg1(
        .clk(CPU_CLK),
        .rst(CPU_RST),
        .en(~StallW),
        .clear(FlushW),
        .CacheMiss(DCacheMiss),
        .A(AluOutM),
        .WD(StoreDataM),
        .WE(MemWriteM),
        .RD(DM_RD),
        .LoadedBytesSelect(LoadedBytesSelect),
        .A2(CPU_Debug_DataRAM_A2),
        .WD2(CPU_Debug_DataRAM_WD2),
        .WE2(CPU_Debug_DataRAM_WE2),
        .RD2(CPU_Debug_DataRAM_RD2),
        .ResultM(ResultM),
        .ResultW(ResultW), 
        .RdM(RdM),
        .RdW(RdW),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .MemToRegM(MemToRegM),
        .MemToRegW(MemToRegW)
    );
    
    DataExt DataExt1(
        .IN(DM_RD),
        .LoadedBytesSelect(LoadedBytesSelect),
        .RegWriteW(RegWriteW),
        .OUT(DM_RD_Ext)
    );
    // ---------------------------------------------
    // Harzard Unit
    // ---------------------------------------------
    HarzardUnit HarzardUnit1(
        .CpuRst(CPU_RST),
        .BranchE(BranchE),
        .JalrE(JalrE),
        .JalD(JalD),
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RegReadE(RegReadE),
        .MemToRegE(MemToRegE),
        .RdE(RdE),
        .RdM(RdM),
        .RegWriteM(RegWriteM),
        .RdW(RdW),
        .RegWriteW(RegWriteW),
        .ICacheMiss(1'b0),
        .DCacheMiss(DCacheMiss),
        .StallF(StallF),
        .FlushF(FlushF),
        .StallD(StallD),
        .FlushD(FlushD),
        .StallE(StallE),
        .FlushE(FlushE),
        .StallM(StallM),
        .FlushM(FlushM),
        .StallW(StallW),
        .FlushW(FlushW),
        .Forward1E(Forward1E),
        .Forward2E(Forward2E),
        //BTB
        .BTB_hitE(BTB_hitE),
        .BHT_brE(BHT_brE),
        .Pred_True(Pred_True)
    	);    
endmodule

