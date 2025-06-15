// ucsbece154b_riscv_pipe.v
// ECE 154B, RISC-V pipelined processor 
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited


module ucsbece154b_riscv_pipe (
    input               clk, reset,
    output wire  [31:0] PCF_o1,
    input        [31:0] InstrF_i1,
    output wire         MemWriteM_o1,
    output wire  [31:0] ALUResultM_o1,
    output wire  [31:0] WriteDataM_o1,
    input        [31:0] ReadDataM_i1,

    output wire  [31:0] PCF_o2,
    input        [31:0] InstrF_i2,
    output wire         MemWriteM_o2,
    output wire  [31:0] ALUResultM_o2,
    output wire  [31:0] WriteDataM_o2,
    input        [31:0] ReadDataM_i2

);

wire  FlushM2, StallF1, StallD1, FlushD1, RegWriteW1, FlushE1, ALUSrcE1; //, ZeroE, PCSrcE;
wire [6:0] op1;
wire [2:0] funct31;
wire funct7b51;
wire [2:0] ImmSrcD1;
wire [2:0] ALUControlE1,ForwardAE1, ForwardBE1;
wire [1:0] ResultSrcW1, ResultSrcM1;
wire [4:0] Rs1D1, Rs2D1, Rs1E1, Rs2E1, RdE1, RdM1, RdW1, RdD1, RdD2;
wire BranchE1, JumpE1, BranchTypeE1, MisspredictE1,ReadyF1;

wire  StallF2, StallD2, FlushD2, RegWriteW2, FlushE2, ALUSrcE2; //, ZeroE, PCSrcE;
wire [6:0] op2;
wire [2:0] funct32;
wire funct7b52;
wire [2:0] ImmSrcD2;
wire [2:0] ALUControlE2, ForwardAE2, ForwardBE2;
wire [1:0] ResultSrcW2, ResultSrcM2;
wire [4:0] Rs1D2, Rs2D2, Rs1E2, Rs2E2, RdE2, RdM2, RdW2;
wire BranchE2, JumpE2, BranchTypeE2, MisspredictE2,ReadyF2;

wire ZeroE1,ZeroE2, PCSrcE1, PCSrcE2;
ucsbece154b_controller c (
    .clk(clk), .reset(reset),
    .FlushM_o2(FlushM2),
    .op_i1 (op1), 
    .funct3_i1(funct31),
    .funct7b5_i1(funct7b51),
  //  .ZeroE_i(ZeroE),
    .Rs1D_i1(Rs1D1),
    .Rs2D_i1(Rs2D1),
    .Rs1E_i1(Rs1E1),
    .Rs2E_i1(Rs2E1),
    .RdE_i1(RdE1),
    .RdM_i1(RdM1),
    .RdW_i1(RdW1),

     .op_i2 (op2), 
    .funct3_i2(funct32),
    .funct7b5_i2(funct7b52),
  //  .ZeroE_i(ZeroE),
    .Rs1D_i2(Rs1D2),
    .Rs2D_i2(Rs2D2),
    .Rs1E_i2(Rs1E2),
    .Rs2E_i2(Rs2E2),
    .RdE_i2(RdE2),
    .RdM_i2(RdM2),
    .RdW_i2(RdW2),

    .StallF_o1(StallF1),  
    .StallD_o1(StallD1),
    .FlushD_o1(FlushD1),
    .ImmSrcD_o1(ImmSrcD1),
    .MisspredictE_i1(MisspredictE1),
    .ALUControlE_o1(ALUControlE1),
    .ALUSrcE_o1(ALUSrcE1),
    .FlushE_o1(FlushE1),
    .ForwardAE_o1(ForwardAE1),
    .ForwardBE_o1(ForwardBE1),
    .MemWriteM_o1(MemWriteM_o1),
    .RegWriteW_o1(RegWriteW1),
    .ResultSrcW_o1 (ResultSrcW1),
    .ResultSrcM_o1 (ResultSrcM1),
    .BranchE_o1 (BranchE1),
    .JumpE_o1 (JumpE1),
    .BranchTypeE_o1 (BranchTypeE1), 
    
    .StallF_o2(StallF2),  
    .StallD_o2(StallD2),
    .FlushD_o2(FlushD2),
    .ImmSrcD_o2(ImmSrcD2),
    .MisspredictE_i2(MisspredictE2),
    .ALUControlE_o2(ALUControlE2),
    .ALUSrcE_o2(ALUSrcE2),
    .FlushE_o2(FlushE2),
    .ForwardAE_o2(ForwardAE2),
    .ForwardBE_o2(ForwardBE2),
    .MemWriteM_o2(MemWriteM_o2),
    .RegWriteW_o2(RegWriteW2),
    .ResultSrcW_o2 (ResultSrcW2),
    .ResultSrcM_o2 (ResultSrcM2),
    .BranchE_o2 (BranchE2),
    .JumpE_o2 (JumpE2),
    .BranchTypeE_o2 (BranchTypeE2), 
    .RdD_i1(RdD1),
    .RdD_i2(RdD2),
    .ZeroE_i1(ZeroE1),
    .ZeroE_i2(ZeroE2),
    .PCSrcE_o1(PCSrcE1),
    .PCSrcE_o2(PCSrcE2)

);


ucsbece154b_datapath dp (
    .RdD_o1(RdD1),
    .RdD_o2(RdD2),
    .ZeroE_o1(ZeroE1),
    .ZeroE_o2(ZeroE2),
    .PCSrcE_i1(PCSrcE1),
    .PCSrcE_i2(PCSrcE2),
    .FlushM_i2(FlushM2),
    .clk(clk), .reset(reset),
    .MisspredictE_o1(MisspredictE1),
    .StallF_i1(StallF1),
    .PCF_o1(PCF_o1),
    .StallD_i1(StallD1),
    .FlushD_i1(FlushD1),
    .InstrF_i1(InstrF_i1),
    .op_o1(op1),
    .funct3_o1(funct31),
    .funct7b5_o1(funct7b51),
    .RegWriteW_i1(RegWriteW1),
    .ImmSrcD_i1(ImmSrcD1),
    .Rs1D_o1(Rs1D1),
    .Rs2D_o1(Rs2D1),
    .FlushE_i1(FlushE1),
    .Rs1E_o1(Rs1E1),
    .Rs2E_o1(Rs2E1), 
    .RdE_o1(RdE1), 
    .ALUSrcE_i1(ALUSrcE1),
    .ALUControlE_i1(ALUControlE1),
    .ForwardAE_i1(ForwardAE1),
    .ForwardBE_i1(ForwardBE1),
  //  .ZeroE_o(ZeroE),
    .RdM_o1(RdM1), 
    .ALUResultM_o1(ALUResultM_o1),
    .WriteDataM_o1(WriteDataM_o1),
    .ReadDataM_i1(ReadDataM_i1),
    .ResultSrcW_i1(ResultSrcW1),
    .RdW_o1(RdW1),
    .ResultSrcM_i1 (ResultSrcM1),
    .BranchE_i1 (BranchE1),
    .JumpE_i1 (JumpE1),
    .BranchTypeE_i1 (BranchTypeE1), 

    .MisspredictE_o2(MisspredictE2),
    .StallF_i2(StallF2),
    .PCF_o2(PCF_o2),
    .StallD_i2(StallD2),
    .FlushD_i2(FlushD2),
    .InstrF_i2(InstrF_i2),
    .op_o2(op2),
    .funct3_o2(funct32),
    .funct7b5_o2(funct7b52),
    .RegWriteW_i2(RegWriteW2),
    .ImmSrcD_i2(ImmSrcD2),
    .Rs1D_o2(Rs1D2),
    .Rs2D_o2(Rs2D2),
    .FlushE_i2(FlushE2),
    .Rs1E_o2(Rs1E2),
    .Rs2E_o2(Rs2E2), 
    .RdE_o2(RdE2), 
    .ALUSrcE_i2(ALUSrcE2),
    .ALUControlE_i2(ALUControlE2),
    .ForwardAE_i2(ForwardAE2),
    .ForwardBE_i2(ForwardBE2),
  //  .ZeroE_o(ZeroE),
    .RdM_o2(RdM2), 
    .ALUResultM_o2(ALUResultM_o2),
    .WriteDataM_o2(WriteDataM_o2),
    .ReadDataM_i2(ReadDataM_i2),
    .ResultSrcW_i2(ResultSrcW2),
    .RdW_o2(RdW2),
    .ResultSrcM_i2 (ResultSrcM2),
    .BranchE_i2 (BranchE2),
    .JumpE_i2 (JumpE2),
    .BranchTypeE_i2 (BranchTypeE2)
);
endmodule
