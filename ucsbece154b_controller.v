// ucsbece154b_controller.v
// ECE 154B, RISC-V pipelined processor 
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited


module ucsbece154b_controller (
    input                clk, reset,
    input         [6:0]  op_i1, 
    input         [6:0]  op_i2,

    input         [2:0]  funct3_i1,
    input         [2:0]  funct3_i2,
    input                funct7b5_i1,
    input                funct7b5_i2,
    input 	         ZeroE_i1,
    input 	         ZeroE_i2,
    output           PCSrcE_o1,
    output           PCSrcE_o2,
    input         [4:0]  Rs1D_i1,
    input         [4:0]  Rs2D_i1,
    input         [4:0]  Rs1E_i1,
    input         [4:0]  Rs2E_i1,
    input         [4:0]  RdE_i1,
    input         [4:0]  RdM_i1,
    input         [4:0]  RdW_i1,
    output wire       FlushM_o2,
    output wire		 StallF_o1,  
    output wire          StallD_o1,
    output wire          FlushD_o1,
    output wire    [2:0] ImmSrcD_o1,
    input           MisspredictE_i1,   
    output reg     [2:0] ALUControlE_o1,
    output reg           ALUSrcE_o1,
    output wire          FlushE_o1,
    output reg     [2:0] ForwardAE_o1,
    output reg     [2:0] ForwardBE_o1,
    output reg           MemWriteM_o1,
    output reg          RegWriteW_o1,
    output reg    [1:0] ResultSrcW_o1, 
    output reg    [1:0] ResultSrcM_o1, 
    output reg          BranchE_o1,
    output reg          JumpE_o1,
    output reg          BranchTypeE_o1,
    input wire    [4:0] RdD_i1,
    input wire    [4:0] RdD_i2,
    input         [4:0]  Rs1D_i2,
    input         [4:0]  Rs2D_i2,
    input         [4:0]  Rs1E_i2,
    input         [4:0]  Rs2E_i2,
    input         [4:0]  RdE_i2,
    input         [4:0]  RdM_i2,
    input         [4:0]  RdW_i2,
    output wire		 StallF_o2,  
    output wire          StallD_o2,
    output wire          FlushD_o2,
    output wire    [2:0] ImmSrcD_o2,
    input           MisspredictE_i2,   
    output reg     [2:0] ALUControlE_o2,
    output reg           ALUSrcE_o2,
    output wire          FlushE_o2,
    output reg     [2:0] ForwardAE_o2,
    output reg     [2:0] ForwardBE_o2,
    output reg           MemWriteM_o2,
    output reg          RegWriteW_o2,
    output reg    [1:0] ResultSrcW_o2, 
    output reg    [1:0] ResultSrcM_o2, 
    output reg          BranchE_o2,
    output reg          JumpE_o2,
    output reg          BranchTypeE_o2
);


 `include "ucsbece154b_defines.vh"

// Decoder signals other than from hazard unit are implemented next. Hazard unit is implemented at the end

// ***** FETCH STAGE ***************************************

// ***** DECODE STAGE **************************************
 wire RegWriteD1, MemWriteD1, JumpD1, BranchD1, ALUSrcD1;
 wire RegWriteD2, MemWriteD2, JumpD2, BranchD2, ALUSrcD2;

 reg BranchTypeD1;
 reg BranchTypeD2;

 wire [1:0] ResultSrcD1; 
 reg [2:0] ALUControlD1;

 wire [1:0] ResultSrcD2; 
 reg [2:0] ALUControlD2;
 
 wire [1:0] ALUOpD1;
 wire [1:0] ALUOpD2;

 reg [11:0] maindecoderD1; // Note that maindecoder is just clubbing of signals for a convinient (compact, human readable) implementaiton of main decoder table. "reg" is required because is maindecoder is used in always block, which is used because of case statements. Also note that default in always blocks is a must in such case, otherwise maindecoder will be treated as register.
 reg [11:0] maindecoderD2;

 assign {RegWriteD1,	
	ImmSrcD_o1,
        ALUSrcD1,
        MemWriteD1,
        ResultSrcD1,
	BranchD1, 
	ALUOpD1,
	JumpD1} = maindecoderD1;

 assign {RegWriteD2,	
	ImmSrcD_o2,
        ALUSrcD2,
        MemWriteD2,
        ResultSrcD2,
	BranchD2, 
	ALUOpD2,
	JumpD2} = maindecoderD2;

 always @ * begin
   case (op_i1)
	instr_lw_op:        maindecoderD1 = 12'b1_000_1_0_01_0_00_0;       
	instr_sw_op:        maindecoderD1 = 12'b0_001_1_1_00_0_00_0; 
	instr_Rtype_op:     maindecoderD1 = 12'b1_xxx_0_0_00_0_10_0;  
	instr_branch_op:    maindecoderD1 = 12'b0_010_0_0_00_1_01_0;  
	instr_ItypeALU_op:  maindecoderD1 = 12'b1_000_1_0_00_0_10_0; 
	instr_jal_op:       maindecoderD1 = 12'b1_011_x_0_10_0_xx_1; 
        instr_lui_op:       maindecoderD1 = 12'b1_100_x_0_11_0_xx_0; 
        instr_jalr_op:      maindecoderD1 = 12'b1_000_x_0_10_0_xx_1;  
	default: 	    maindecoderD1 = 12'b0_xxx_x_0_xx_0_xx_0; 
   endcase
 end
 always @ * begin
   case (op_i2)
	instr_lw_op:        maindecoderD2 = 12'b1_000_1_0_01_0_00_0;       
	instr_sw_op:        maindecoderD2 = 12'b0_001_1_1_00_0_00_0; 
	instr_Rtype_op:     maindecoderD2 = 12'b1_xxx_0_0_00_0_10_0;  
	instr_branch_op:    maindecoderD2 = 12'b0_010_0_0_00_1_01_0;  
	instr_ItypeALU_op:  maindecoderD2 = 12'b1_000_1_0_00_0_10_0; 
	instr_jal_op:       maindecoderD2 = 12'b1_011_x_0_10_0_xx_1; 
        instr_lui_op:       maindecoderD2 = 12'b1_100_x_0_11_0_xx_0; 
        instr_jalr_op:      maindecoderD2 = 12'b1_000_x_0_10_0_xx_1;  
	default: 	    maindecoderD2 = 12'b0_xxx_x_0_xx_0_xx_0; 
   endcase
 end
 wire RtypeSubD1;
 wire RtypeSubD2;

 assign RtypeSubD1 = funct7b5_i1 & op_i1[5];
 assign RtypeSubD2 = funct7b5_i2 & op_i2[5];

 always @ * begin
  case(ALUOpD1)
    ALUop_mem:                 ALUControlD1 = ALUcontrol_add;
    ALUop_beqbne:              ALUControlD1 = ALUcontrol_sub;
    ALUop_other: 
       case(funct3_i1)
           instr_addsub_funct3: 
                 if(RtypeSubD1) ALUControlD1 = ALUcontrol_sub;
                 else          ALUControlD1 = ALUcontrol_add;  
           instr_slt_funct3:   ALUControlD1 = ALUcontrol_slt;  
           instr_or_funct3:    ALUControlD1 = ALUcontrol_or;  
           instr_and_funct3:   ALUControlD1 = ALUcontrol_and;  
           default:            ALUControlD1 = 3'bxxx;
       endcase
    default: 
      `ifdef SIM
          $warning("Unsupported ALUop given: %h", ALUOpD1);
      `else
          ;
      `endif   
   endcase
 end

 always @ * begin
  case(ALUOpD2)
    ALUop_mem:                 ALUControlD2 = ALUcontrol_add;
    ALUop_beqbne:              ALUControlD2 = ALUcontrol_sub;
    ALUop_other: 
       case(funct3_i2)
           instr_addsub_funct3: 
                 if(RtypeSubD2) ALUControlD2 = ALUcontrol_sub;
                 else          ALUControlD2 = ALUcontrol_add;  
           instr_slt_funct3:   ALUControlD2 = ALUcontrol_slt;  
           instr_or_funct3:    ALUControlD2 = ALUcontrol_or;  
           instr_and_funct3:   ALUControlD2 = ALUcontrol_and;  
           default:            ALUControlD2 = 3'bxxx;
       endcase
    default: 
      `ifdef SIM
          $warning("Unsupported ALUop given: %h", ALUOpD2);
      `else
          ;
      `endif   
   endcase
 end
// this is pipelined signal to invert zero when branch is bne

 always @ * begin
  case(funct3_i1)
    instr_beq_funct3:      BranchTypeD1 = 1'b0;
    instr_bne_funct3:      BranchTypeD1 = 1'b1;
    default:               BranchTypeD1 = 1'bx;
   endcase
 end
 always @ * begin
  case(funct3_i2)
    instr_beq_funct3:      BranchTypeD2 = 1'b0;
    instr_bne_funct3:      BranchTypeD2 = 1'b1;
    default:               BranchTypeD2 = 1'bx;
   endcase
 end


// ****** EXECUTE STAGE ****************************************
 reg RegWriteE1, MemWriteE1;
 reg RegWriteE2, MemWriteE2;
 // reg BranchTypeE;
 reg [1:0] ResultSrcE1;
 reg [1:0] ResultSrcE2;

 assign PCSrcE_o1 = BranchE_o1 & (ZeroE_i1 ^ BranchTypeE_o1) | JumpE_o1; 
 assign PCSrcE_o2 = BranchE_o2 & (ZeroE_i2 ^ BranchTypeE_o2) | JumpE_o2; 
// Update registers (move control signals via pipeline)
 always @(posedge clk) begin
    if(FlushE_o1 | reset) begin
       RegWriteE1     <=  1'b0;
       ResultSrcE1    <=  2'b0;
       MemWriteE1     <=  1'b0;
       JumpE_o1       <=  1'b0;
       BranchE_o1     <=  1'b0;
       ALUControlE_o1 <=  3'b0;
       ALUSrcE_o1     <=  1'b0;
       BranchTypeE_o1 <=  1'b0;
    end else begin
       RegWriteE1     <= RegWriteD1;
       ResultSrcE1    <= ResultSrcD1;
       MemWriteE1     <= MemWriteD1;
       JumpE_o1       <= JumpD1;
       BranchE_o1     <= BranchD1;
       ALUControlE_o1 <= ALUControlD1;
       ALUSrcE_o1     <= ALUSrcD1; 
       BranchTypeE_o1 <= BranchTypeD1;
    end
 end 
 always @(posedge clk) begin
    if(FlushE_o2 | reset) begin
       RegWriteE2     <=  1'b0;
       ResultSrcE2    <=  2'b0;
       MemWriteE2     <=  1'b0;
       JumpE_o2       <=  1'b0;
       BranchE_o2     <=  1'b0;
       ALUControlE_o2 <=  3'b0;
       ALUSrcE_o2     <=  1'b0;
       BranchTypeE_o2 <=  1'b0;
    end else begin
       RegWriteE2     <= RegWriteD2;
       ResultSrcE2    <= ResultSrcD2;
       MemWriteE2     <= MemWriteD2;
       JumpE_o2       <= JumpD2;
       BranchE_o2     <= BranchD2;
       ALUControlE_o2 <= ALUControlD2;
       ALUSrcE_o2     <= ALUSrcD2; 
       BranchTypeE_o2 <= BranchTypeD2;
    end
 end 

// ***** MEMORY STAGE ******************************************
reg RegWriteM1;
reg RegWriteM2;

// Update registers (move control signals via pipeline)
 always @(posedge clk) begin
    if(reset) begin 
       RegWriteM1    <= 1'b0;
       ResultSrcM_o1 <= 2'b0;
       MemWriteM_o1  <= 1'b0;
    end else begin
       RegWriteM1    <= RegWriteE1;
       ResultSrcM_o1 <= ResultSrcE1;
       MemWriteM_o1  <= MemWriteE1;
    end
  end
always @(posedge clk) begin
    if(reset) begin 
       RegWriteM2    <= 1'b0;
       ResultSrcM_o2 <= 2'b0;
       MemWriteM_o2  <= 1'b0;
    end else begin
       RegWriteM2    <= RegWriteE2;
       ResultSrcM_o2 <= ResultSrcE2;
       MemWriteM_o2  <= MemWriteE2;
    end
  end

// ***** WRITEBACK STAGE ***************************************

// Update registers (move control signals via pipeline)
 always @(posedge clk) begin
    if(reset) begin 
       RegWriteW_o1  <= 1'b0;
       ResultSrcW_o1 <= 2'b0;
    end else begin
       RegWriteW_o1  <= RegWriteM1;
       ResultSrcW_o1 <= ResultSrcM_o1;
    end
  end
 always @(posedge clk) begin
    if(reset) begin 
       RegWriteW_o2  <= 1'b0;
       ResultSrcW_o2 <= 2'b0;
    end else begin
       RegWriteW_o2  <= RegWriteM2;
       ResultSrcW_o2 <= ResultSrcM_o2;
    end
  end

// Hazard unit (stall and data forwarding)

// Forwarding logic
 always @ * begin
  if      ( (Rs1E_i1 == RdM_i2) & RegWriteM2 & (Rs1E_i1 != 0) ) 
         ForwardAE_o1 = forward_mem2;
  else if ( (Rs1E_i1 == RdM_i1) & RegWriteM1 & (Rs1E_i1 != 0) ) 
         ForwardAE_o1 = forward_mem1;
  else if ( (Rs1E_i1 == RdW_i2) & RegWriteW_o2 & (Rs1E_i1 != 0) ) 
         ForwardAE_o1 = forward_wb2;
  else if ( (Rs1E_i1 == RdW_i1) & RegWriteW_o1 & (Rs1E_i1 != 0) ) 
         ForwardAE_o1 = forward_wb1;

  else   ForwardAE_o1 = forward_ex;
 end
 always @ * begin
  if      ( (Rs1E_i2 == RdM_i2) & RegWriteM2 & (Rs1E_i2 != 0) ) 
         ForwardAE_o2 = forward_mem2;
  else if ( (Rs1E_i2 == RdM_i1) & RegWriteM1 & (Rs1E_i2 != 0) ) 
         ForwardAE_o2 = forward_mem1;
  else if ( (Rs1E_i2 == RdW_i2) & RegWriteW_o2 & (Rs1E_i2 != 0) ) 
         ForwardAE_o2 = forward_wb2;
  else if ( (Rs1E_i2 == RdW_i1) & RegWriteW_o1 & (Rs1E_i2 != 0) ) 
         ForwardAE_o2 = forward_wb1;

  else   ForwardAE_o2 = forward_ex;
 end

  
 always @ * begin
  if      ( (Rs2E_i1 == RdM_i2) & RegWriteM2 & (Rs2E_i1 != 0) ) 
         ForwardBE_o1 = forward_mem2;
  else if ( (Rs2E_i1 == RdM_i1) & RegWriteM1 & (Rs2E_i1 != 0) ) 
         ForwardBE_o1 = forward_mem1;
  else if ( (Rs2E_i1 == RdW_i2) & RegWriteW_o2 & (Rs2E_i1 != 0) ) 
         ForwardBE_o1 = forward_wb2;
  else if ( (Rs2E_i1 == RdW_i1) & RegWriteW_o1 & (Rs2E_i1 != 0) ) 
         ForwardBE_o1 = forward_wb1;

  else   ForwardBE_o1 = forward_ex;
 end

  always @ * begin
  if      ( (Rs2E_i2 == RdM_i2) & RegWriteM2 & (Rs2E_i2 != 0) ) 
         ForwardBE_o2 = forward_mem2;
  else if ( (Rs2E_i2 == RdM_i1) & RegWriteM1 & (Rs2E_i2 != 0) ) 
         ForwardBE_o2 = forward_mem1;
  else if ( (Rs2E_i2 == RdW_i2) & RegWriteW_o2 & (Rs2E_i2 != 0) ) 
         ForwardBE_o2 = forward_wb2;
  else if ( (Rs2E_i2 == RdW_i1) & RegWriteW_o1 & (Rs2E_i2 != 0) ) 
         ForwardBE_o2 = forward_wb1;

  else   ForwardBE_o2 = forward_ex;
 end




// Stall logic
 wire lwStall1;
 wire lwStall2;  
 wire sameD;
 reg sameDd;
  always @(posedge clk) begin
   if(reset) begin 
       sameDd  <= 1'b0;
    end else begin
       sameDd  <= sameD;
    end
  end
 assign lwStall1 = ((ResultSrcE1 == 1) & ( (Rs1D_i1 == RdE_i1) | (Rs2D_i1 == RdE_i1) ) & (RdE_i1 != 0))
                  |((ResultSrcE2 == 1) & ( (Rs1D_i1 == RdE_i2) | (Rs2D_i1 == RdE_i2) ) & (RdE_i2 != 0))
                  ;
 assign StallF_o1 = lwStall1 |sameD |(lwStall2 & sameDd);
 assign StallD_o1 = lwStall1 |sameD |(lwStall2 & sameDd);
 assign FlushD_o1 = MisspredictE_i1 | MisspredictE_i2 |sameD;
 assign FlushE_o1 = lwStall1 | MisspredictE_i1 | MisspredictE_i2 ; 

 assign sameD = ((RegWriteD1|MemWriteD1) & (((Rs1D_i2==RdD_i1)|(Rs2D_i2==RdD_i1)) & (!MisspredictE_i2) & (!MisspredictE_i1) & (RdD_i1 != 0)));
 assign lwStall2 = ((ResultSrcE1 == 1) & ( (Rs1D_i2 == RdE_i1) | (Rs2D_i2 == RdE_i1) ) & (RdE_i1 != 0))
                  |((ResultSrcE2 == 1) & ( (Rs1D_i2 == RdE_i2) | (Rs2D_i2 == RdE_i2) ) & (RdE_i2 != 0))
                  | sameD;
                  
 assign StallF_o2 = lwStall2;
 assign StallD_o2 = lwStall2;
 assign FlushM_o2 =  MisspredictE_i1;
 assign FlushD_o2 =  MisspredictE_i1 | MisspredictE_i2;
 assign FlushE_o2 = lwStall2 | MisspredictE_i1 | MisspredictE_i2; 


endmodule

