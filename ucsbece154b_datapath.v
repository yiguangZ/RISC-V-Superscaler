// ucsbece154b_datapath.v
// ECE 154B, RISC-V pipelined processor 
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited

`define GL_NUM_BTB_ENTRIES 32
`define GL_NUM_GHR_BITS 3
`define GL_NUM_PHT_ENTRIES 1024

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// TO DO: MODIFY FETCH, DECODE, AND EXECUTE STAGE BELOW TO IMPLEMENT BRANCH PREDICTOR
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module ucsbece154b_datapath (
    input                clk, reset,
    output               ZeroE_o1,  
    output               ZeroE_o2, 
    input                FlushM_i2, 
    input                StallF_i1,
    input                StallF_i2,
    input           PCSrcE_i1,
    input           PCSrcE_i2,
    output reg    [31:0] PCF_o1,
    output reg    [31:0] PCF_o2,
    input                StallD_i1,
    input                StallD_i2,
    input                FlushD_i1,
    input                FlushD_i2,
    input         [31:0] InstrF_i1,
    input         [31:0] InstrF_i2,
    output wire    [6:0] op_o1,
    output wire    [6:0] op_o2,
    output wire    [2:0] funct3_o1,
    output wire    [2:0] funct3_o2,
    output wire          funct7b5_o1,
    output wire          funct7b5_o2,
    input                RegWriteW_i1,
    input                RegWriteW_i2,
    input          [2:0] ImmSrcD_i1,
    input          [2:0] ImmSrcD_i2,
    output wire    [4:0] Rs1D_o1,
    output wire    [4:0] Rs1D_o2,
    output wire    [4:0] Rs2D_o1,
    output wire    [4:0] Rs2D_o2,
    output wire    [4:0] RdD_o1,
    output wire    [4:0] RdD_o2,
    input  wire          FlushE_i1,
    input  wire          FlushE_i2,
    output reg     [4:0] Rs1E_o1,
    output reg     [4:0] Rs1E_o2,
    output reg     [4:0] Rs2E_o1,
    output reg     [4:0] Rs2E_o2, 
    output reg     [4:0] RdE_o1,
    output reg     [4:0] RdE_o2,  
    input                ALUSrcE_i1,
    input                ALUSrcE_i2,
    input          [2:0] ALUControlE_i1,
    input          [2:0] ALUControlE_i2,
    input          [2:0] ForwardAE_i1,
    input          [2:0] ForwardAE_i2,
    input          [2:0] ForwardBE_i1,
    input          [2:0] ForwardBE_i2,
    output reg     [4:0] RdM_o1,
    output reg     [4:0] RdM_o2,  
    output reg    [31:0] ALUResultM_o1,
    output reg    [31:0] ALUResultM_o2,
    output reg    [31:0] WriteDataM_o1,
    output reg    [31:0] WriteDataM_o2,
    input         [31:0] ReadDataM_i1,
    input         [31:0] ReadDataM_i2,
    input          [1:0] ResultSrcW_i1,
    input          [1:0] ResultSrcW_i2,
    output reg     [4:0] RdW_o1,
    output reg     [4:0] RdW_o2,
    input          [1:0] ResultSrcM_i1, 
    input          [1:0] ResultSrcM_i2,
    input                BranchE_i1,
    input                BranchE_i2,
    input                JumpE_i1,
    input                JumpE_i2,
    input                BranchTypeE_i1,
    input                BranchTypeE_i2,
    output               MisspredictE_o1,
    output               MisspredictE_o2
);

`include "ucsbece154b_defines.vh"

// Define signals earleir if needed here
wire [31:0] PCTargetE1;
wire [31:0] PCcorrecttargetE1;
wire [31:0] PCTargetE2;
wire [31:0] PCcorrecttargetE2;

reg [31:0] ResultW1;
reg [31:0] ResultW2;
// wire MisspredictE;

// ***** FETCH STAGE *********************************

// Mux feeding to PC
wire [31:0] PCPlus4F1 = PCF_o2 + 32'd4;
wire [31:0] PCPlus4F2 = PCF_o2 + 32'd8;

wire [31:0] acPCPlus4F1 = PCF_o1 + 32'd4;
wire [31:0] BTBTargetF1;
wire [31:0] BTBTargetF2;
wire BranchTakenF1;
wire BranchTakenF2;

wire [31:0] PCTargetF1 =  BranchTakenF1 ? BTBTargetF1 : PCPlus4F1;

//wire [31:0] PCnewF1 =  MisspredictE_o1 ? PCcorrecttargetE1 : PCTargetF1;
wire [31:0] PCnewF1 = MisspredictE_o1 ? PCcorrecttargetE1 : 
                     (MisspredictE_o2 ? PCcorrecttargetE2 : PCTargetF1);


wire [31:0] PCTargetF2 = BranchTakenF1 ? BTBTargetF2 : (BranchTakenF2 ? BTBTargetF2 : PCPlus4F2);

//wire [31:0] PCnewF2 =  MisspredictE_o2 ? PCcorrecttargetE2 : PCTargetF2;
wire [31:0] PCnewF2 = MisspredictE_o1 ? (PCcorrecttargetE1+ 32'd4) : 
                     (MisspredictE_o2 ? (PCcorrecttargetE2+ 32'd4) : PCTargetF2);

//wire [NUM_GHR_BITS-1:0] PHTindexF;
wire [$clog2(`GL_NUM_PHT_ENTRIES)-1:0] PHTindexF1;
wire [$clog2(`GL_NUM_PHT_ENTRIES)-1:0] PHTindexF2;
// Update registers
always @ (posedge clk) begin
    if (reset)        PCF_o1 <= pc_start1;
    else if (!StallF_i1) PCF_o1 <= PCnewF1;
end
always @ (posedge clk) begin
    if (reset)        PCF_o2 <= pc_start2;
    else if (!StallF_i2) PCF_o2 <= PCnewF2;
end

// ***** DECODE STAGE ********************************
reg [31:0] InstrD1, PCPlus4D1, PCD1;
reg [31:0] InstrD2, PCPlus4D2, PCD2;
wire [4:0] RdD1;
wire [4:0] RdD2;
assign RdD_o1 = RdD1;
assign RdD_o2 = RdD2;
reg [$clog2(`GL_NUM_PHT_ENTRIES)-1:0] PHTindexD1;
reg [$clog2(`GL_NUM_PHT_ENTRIES)-1:0] PHTindexD2;

assign op_o1       = InstrD1[6:0];
assign funct3_o1   = InstrD1[14:12];
assign funct7b5_o1 = InstrD1[30]; 

assign Rs1D_o1 = InstrD1[19:15];
assign Rs2D_o1 = InstrD1[24:20];
assign RdD1 = InstrD1[11:7];

assign op_o2       = InstrD2[6:0];
assign funct3_o2   = InstrD2[14:12];
assign funct7b5_o2 = InstrD2[30]; 

assign Rs1D_o2 = InstrD2[19:15];
assign Rs2D_o2 = InstrD2[24:20];
assign RdD2 = InstrD2[11:7];

// Register File
wire [31:0] RD1D1, RD2D1;
wire [31:0] RD1D2, RD2D2;
ucsbece154b_rf rf (
    .clk(~clk),
    .a1_i1(Rs1D_o1), .a2_i1(Rs2D_o1), .a3_i1(RdW_o1),
    .rd1_o1(RD1D1), .rd2_o1(RD2D1),
    .we3_i1(RegWriteW_i1), .wd3_i1(ResultW1),

    .a1_i2(Rs1D_o2), .a2_i2(Rs2D_o2), .a3_i2(RdW_o2),
    .rd1_o2(RD1D2), .rd2_o2(RD2D2),
    .we3_i2(RegWriteW_i2), .wd3_i2(ResultW2)
);

// Sign extension
reg [31:0] ExtImmD1;
reg [31:0] ExtImmD2;

always @ * begin
   case(ImmSrcD_i1)
      imm_Itype: ExtImmD1 = {{20{InstrD1[31]}},InstrD1[31:20]};
      imm_Stype: ExtImmD1 = {{20{InstrD1[31]}},InstrD1[31:25],InstrD1[11:7]};
      imm_Btype: ExtImmD1 = {{20{InstrD1[31]}},InstrD1[7],InstrD1[30:25], InstrD1[11:8],1'b0};
      imm_Jtype: ExtImmD1 = {{12{InstrD1[31]}},InstrD1[19:12],InstrD1[20],InstrD1[30:21],1'b0};
      imm_Utype: ExtImmD1 = {InstrD1[31:12],12'b0};
      default:   ExtImmD1 = 32'bx; 
//            `ifdef SIM
//            $warning("Unsupported ImmSrc given: %h", ImmSrc_i);
//            `else
//            ;
//            `endif
   endcase
end

always @ * begin
   case(ImmSrcD_i2)
      imm_Itype: ExtImmD2 = {{20{InstrD2[31]}},InstrD2[31:20]};
      imm_Stype: ExtImmD2 = {{20{InstrD2[31]}},InstrD2[31:25],InstrD2[11:7]};
      imm_Btype: ExtImmD2 = {{20{InstrD2[31]}},InstrD2[7],InstrD2[30:25], InstrD2[11:8],1'b0};
      imm_Jtype: ExtImmD2 = {{12{InstrD2[31]}},InstrD2[19:12],InstrD2[20],InstrD2[30:21],1'b0};
      imm_Utype: ExtImmD2 = {InstrD2[31:12],12'b0};
      default:   ExtImmD2 = 32'bx; 
//            `ifdef SIM
//            $warning("Unsupported ImmSrc given: %h", ImmSrc_i);
//            `else
//            ;
//            `endif
   endcase
end

// Update registers
always @ (posedge clk) begin
    if (reset | FlushD_i1) begin
        InstrD1   <= 32'b0;
        PCPlus4D1 <= 32'b0;
        PCD1      <= 32'b0;
        PHTindexD1 <= {$clog2(`GL_NUM_PHT_ENTRIES){1'b0}};
    end else if (!StallD_i1) begin 
        InstrD1   <= InstrF_i1;
        PCPlus4D1 <= acPCPlus4F1;
        PCD1      <= PCF_o1;
        PHTindexD1 <= PHTindexF1;
    end 
end

always @ (posedge clk) begin
    if (reset | FlushD_i2) begin
        InstrD2   <= 32'b0;
        PCPlus4D2 <= 32'b0;
        PCD2      <= 32'b0;
//        PHTindexD <= {`GL_NUM_GHR_BITS{1'b0}};
        PHTindexD2 <= {$clog2(`GL_NUM_PHT_ENTRIES){1'b0}};
    end else if (!StallD_i2) begin 
        InstrD2   <= InstrF_i2;
        PCPlus4D2 <= PCPlus4F2-32'd4;
        PCD2      <= PCF_o2;
        PHTindexD2 <= PHTindexF2;
    end 
end


// ***** EXECUTE STAGE ******************************
reg [31:0] RD1E1, RD2E1, PCPlus4E1, ExtImmE1, PCE1; 
reg [31:0] ForwardDataM1;

reg [31:0] RD1E2, RD2E2, PCPlus4E2, ExtImmE2, PCE2; 
reg [31:0] ForwardDataM2;
//reg [`GL_NUM_GHR_BITS-1:0] PHTindexE;
reg [$clog2(`GL_NUM_PHT_ENTRIES)-1:0] PHTindexE1;
reg [$clog2(`GL_NUM_PHT_ENTRIES)-1:0] PHTindexE2;

// Forwarding muxes 
reg  [31:0] SrcAE1;
always @ * begin
    case (ForwardAE_i1)
       forward_mem1: SrcAE1 = ALUResultM_o1; 
        forward_wb1: SrcAE1 = ResultW1;
        forward_mem2: SrcAE1 = ALUResultM_o2; 
        forward_wb2: SrcAE1 = ResultW2;
        forward_ex: SrcAE1 = RD1E1;
       default: SrcAE1 = 32'bx;
    endcase
end

reg  [31:0] SrcAE2;
always @ * begin
    case (ForwardAE_i2)
       forward_mem2: SrcAE2 = ALUResultM_o2; 
        forward_wb2: SrcAE2 = ResultW2;
        forward_mem1: SrcAE2 = ALUResultM_o1; 
        forward_wb1: SrcAE2 = ResultW1;
        forward_ex: SrcAE2 = RD1E2;
       default: SrcAE2 = 32'bx;
    endcase
end

reg  [31:0] SrcBE1;
reg  [31:0] WriteDataE1;
always @ * begin
    case (ForwardBE_i1)
       forward_mem1: WriteDataE1 = ForwardDataM1; 
        forward_wb1: WriteDataE1 = ResultW1;
        forward_mem2: WriteDataE1 = ForwardDataM2; 
        forward_wb2: WriteDataE1 = ResultW2;
        forward_ex: WriteDataE1 = RD2E1;
       default: WriteDataE1 = 32'bx;
    endcase
end

reg  [31:0] SrcBE2;
reg  [31:0] WriteDataE2;
always @ * begin
    case (ForwardBE_i2)
       forward_mem2: WriteDataE2 = ForwardDataM2; 
        forward_wb2: WriteDataE2 = ResultW2;
        forward_mem1: WriteDataE2 = ForwardDataM1; 
        forward_wb1: WriteDataE2 = ResultW1;
        forward_ex: WriteDataE2 = RD2E2;
       default: WriteDataE2 = 32'bx;
    endcase
end


// Mux feeding ALU Src B
always @ * begin
    case (ALUSrcE_i1)
        SrcB_imm: SrcBE1 = ExtImmE1;
        SrcB_reg: SrcBE1 = WriteDataE1;
      default: SrcBE1 = 32'bx;
    endcase
end

always @ * begin
    case (ALUSrcE_i2)
        SrcB_imm: SrcBE2 = ExtImmE2;
        SrcB_reg: SrcBE2 = WriteDataE2;
      default: SrcBE2 = 32'bx;
    endcase
end


// ALU
wire [31:0] ALUResultE1;
ucsbece154b_alu alu1 (
    .a_i(SrcAE1), .b_i(SrcBE1),
    .alucontrol_i(ALUControlE_i1),
    .result_o(ALUResultE1),
    .zero_o(ZeroE_o1)
);
wire [31:0] ALUResultE2;
ucsbece154b_alu alu2 (
    .a_i(SrcAE2), .b_i(SrcBE2),
    .alucontrol_i(ALUControlE_i2),
    .result_o(ALUResultE2),
    .zero_o(ZeroE_o2)
);

// PC Target
assign PCTargetE1 = PCE1 + ExtImmE1;
assign PCTargetE2 = PCE2 + ExtImmE2;
// Update registers

always @ (posedge clk) begin
    if (reset | FlushE_i1) begin
        RD1E1     <= 32'b0;
        RD2E1     <= 32'b0;
        PCE1      <= 32'b0;
        ExtImmE1  <= 32'b0;
        PCPlus4E1 <= 32'b0;
        Rs1E_o1   <=  5'b0;
        Rs2E_o1   <=  5'b0;
        RdE_o1    <=  5'b0;
//        PHTindexE <= {`GL_NUM_GHR_BITS{1'b0}};
        PHTindexE1 <= {$clog2(`GL_NUM_PHT_ENTRIES){1'b0}};
    end else begin 
        RD1E1     <= RD1D1;
        RD2E1     <= RD2D1;
        PCE1      <= PCD1;
        ExtImmE1  <= ExtImmD1;
        PCPlus4E1 <= PCPlus4D1;
        Rs1E_o1   <= Rs1D_o1;
        Rs2E_o1   <= Rs2D_o1;
        RdE_o1    <= RdD1;
        PHTindexE1 <= PHTindexD1;
    end 
end
always @ (posedge clk) begin
    if (reset | FlushE_i2) begin
        RD1E2     <= 32'b0;
        RD2E2     <= 32'b0;
        PCE2      <= 32'b0;
        ExtImmE2  <= 32'b0;
        PCPlus4E2 <= 32'b0;
        Rs1E_o2   <=  5'b0;
        Rs2E_o2   <=  5'b0;
        RdE_o2    <=  5'b0;
//        PHTindexE <= {`GL_NUM_GHR_BITS{1'b0}};
        PHTindexE2 <= {$clog2(`GL_NUM_PHT_ENTRIES){1'b0}};
    end else begin 
        RD1E2     <= RD1D2;
        RD2E2     <= RD2D2;
        PCE2      <= PCD2;
        ExtImmE2  <= ExtImmD2;
        PCPlus4E2 <= PCPlus4D2;
        Rs1E_o2   <= Rs1D_o2;
        Rs2E_o2   <= Rs2D_o2;
        RdE_o2    <= RdD2;
        PHTindexE2 <= PHTindexD2;
    end 
end


// ***** MEMORY STAGE ***************************
reg [31:0] ExtImmM1, PCPlus4M1;
reg [31:0] ExtImmM2, PCPlus4M2;

always @ * begin
   case(ResultSrcM_i1)
     MuxResult_aluout:  ForwardDataM1 = ALUResultM_o1;
     MuxResult_PCPlus4: ForwardDataM1 = PCPlus4M1;
     MuxResult_imm:     ForwardDataM1 = ExtImmM1;
     default:           ForwardDataM1 = 32'bx;

   endcase
 end
always @ * begin
   case(ResultSrcM_i2)
     MuxResult_aluout:  ForwardDataM2 = ALUResultM_o2;
     MuxResult_PCPlus4: ForwardDataM2 = PCPlus4M2;
     MuxResult_imm:     ForwardDataM2 = ExtImmM2;
     default:           ForwardDataM2 = 32'bx;

   endcase
 end

// Update registers
always @ (posedge clk) begin
    if (reset) begin
        ALUResultM_o1 <= 32'b0;
        WriteDataM_o1 <= 32'b0;
        ExtImmM1      <= 32'b0;
        PCPlus4M1     <= 32'b0;
        RdM_o1        <=  5'b0;
    end 
    else begin 
        ALUResultM_o1 <= ALUResultE1;
        WriteDataM_o1 <= WriteDataE1;
        ExtImmM1      <= ExtImmE1;
        PCPlus4M1     <= PCPlus4E1;
        RdM_o1        <= RdE_o1;
    end 
end
always @ (posedge clk) begin
    if (reset | (FlushM_i2) ) begin
        ALUResultM_o2 <= 32'b0;
        WriteDataM_o2 <= 32'b0;
        ExtImmM2      <= 32'b0;
        PCPlus4M2     <= 32'b0;
        RdM_o2        <=  5'b0;
    end else begin 
        ALUResultM_o2 <= ALUResultE2;
        WriteDataM_o2 <= WriteDataE2;
        ExtImmM2      <= ExtImmE2;
        PCPlus4M2     <= PCPlus4E2;
        RdM_o2        <= RdE_o2;
    end 
end

// ***** WRITEBACK STAGE ************************
reg [31:0] PCPlus4W1, ALUResultW1, ReadDataW1, ExtImmW1;
reg [31:0] PCPlus4W2, ALUResultW2, ReadDataW2, ExtImmW2;

always @ * begin
   case(ResultSrcW_i1)
     MuxResult_mem: ResultW1 = ReadDataW1;
     MuxResult_aluout:  ResultW1 = ALUResultW1;
     MuxResult_PCPlus4:  ResultW1 = PCPlus4W1;
     MuxResult_imm:  ResultW1 = ExtImmW1;
     default:        ResultW1 = 32'bx;
   endcase
 end

 always @ * begin
   case(ResultSrcW_i2)
     MuxResult_mem: ResultW2 = ReadDataW2;
     MuxResult_aluout:  ResultW2 = ALUResultW2;
     MuxResult_PCPlus4:  ResultW2 = PCPlus4W2;
     MuxResult_imm:  ResultW2 = ExtImmW2;
     default:        ResultW2 = 32'bx;
   endcase
 end


// Update registers
always @ (posedge clk) begin
    if (reset) begin
        ALUResultW1 <= 32'b0;
        ReadDataW1  <= 32'b0;
        ExtImmW1    <= 32'b0;
        PCPlus4W1   <= 32'b0;
        RdW_o1      <=  5'b0;
    end else begin 
        ALUResultW1 <= ALUResultM_o1;
        ReadDataW1  <= ReadDataM_i1;
        ExtImmW1    <= ExtImmM1;
        PCPlus4W1   <= PCPlus4M1;
        RdW_o1      <= RdM_o1;
    end 
end

always @ (posedge clk) begin
    if (reset) begin
        ALUResultW2 <= 32'b0;
        ReadDataW2  <= 32'b0;
        ExtImmW2    <= 32'b0;
        PCPlus4W2   <= 32'b0;
        RdW_o2      <=  5'b0;
    end else begin 
        ALUResultW2 <= ALUResultM_o2;
        ReadDataW2  <= ReadDataM_i2;
        ExtImmW2    <= ExtImmM2;
        PCPlus4W2   <= PCPlus4M2;
        RdW_o2      <= RdM_o2;
    end 
end


// ******** BRANCH PREDICTOR

 wire BranchTakenE1 = BranchE_i1 & (ZeroE_o1 ^ BranchTypeE_i1);  // BranchTakeE = 1 for branch taken, 0 otherwise
wire BranchNotTakenE1 = BranchE_i1 & ~(ZeroE_o1 ^ BranchTypeE_i1); //  // BranchNotTakeE = 1 for branch not taken, 0 otherwise
wire nextTakenE1 = (PCTargetE1 == PCE2); 
assign MisspredictE_o1 = (~nextTakenE1 & (BranchTakenE1 | JumpE_i1)) | (nextTakenE1 & BranchNotTakenE1); 

assign PCcorrecttargetE1 = (BranchTakenE1 | JumpE_i1) ? PCTargetE1 : PCPlus4E1; 

wire BranchTakenE2 = BranchE_i2 & (ZeroE_o2 ^ BranchTypeE_i2);  // BranchTakeE = 1 for branch taken, 0 otherwise
wire BranchNotTakenE2 = BranchE_i2 & ~(ZeroE_o2 ^ BranchTypeE_i2); //  // BranchNotTakeE = 1 for branch not taken, 0 otherwise
wire nextTakenE2 = (PCTargetE2 == PCD1); 
assign MisspredictE_o2 = (~nextTakenE2 & (BranchTakenE2 | JumpE_i2)) | (nextTakenE2 & BranchNotTakenE2); 

assign PCcorrecttargetE2 = (BranchTakenE2 | JumpE_i2) ? PCTargetE2 : PCPlus4E2  ; 

ucsbece154b_branch  bp (
//ucsbece154b_branch #(`GL_NUM_BTB_ENTRIES, `GL_NUM_GHR_BITS) bp (
    .clk(clk),
    .reset_i(reset), 
    .pc_i2(PCF_o2),

    .BTBwriteaddress_i1(PCE1),
    .BTBwritedata_i1(PCTargetE1),
    .BTB_we1(BranchE_i1| JumpE_i1),
    .jumpflag1(JumpE_i1),
    .jumpflag2(JumpE_i2),
    .branchflag1(BranchE_i1),
    .branchflag2(BranchE_i2),
    .BTBwriteaddress_i2(PCE2),
    .BTBwritedata_i2(PCTargetE2),
    .BTB_we2(BranchE_i2| JumpE_i2),

    .BTBtarget_o1(BTBTargetF1),
    .BTBtarget_o2(BTBTargetF2),
    .BranchTaken_o1(BranchTakenF1),
    .BranchTaken_o2(BranchTakenF2),

    .PHTwriteaddress_i1(PCE1[7:2]),
    .PHTwriteaddress_i2(PCE2[7:2]),
    .PHTincrement_i1( PCSrcE_i1),
    .PHTincrement_i2( PCSrcE_i2),
    .PHTwe_i1(BranchE_i1),
    .PHTwe_i2(BranchE_i2)
);
 

endmodule
