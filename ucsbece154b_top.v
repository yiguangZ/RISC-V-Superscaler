// ucsbece154b_top.v
// ECE 154B, RISC-V pipelined processor 
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited


module ucsbece154b_top (
    input clk, reset
);

wire [31:0] pc1, pc2, instr1, instr2, readdata1, readdata2;
wire [31:0] writedata1, writedata2, dataadr1, dataadr2;
wire  memwrite1,memwrite2;
wire [31:0] SDRAM_ReadAddress;
wire [31:0] SDRAM_DataIn;





// processor and memories are instantiated here
ucsbece154b_riscv_pipe riscv (
    .clk(clk), .reset(reset),
    .PCF_o1(pc1),
    .PCF_o2(pc2),
    .InstrF_i1(instr1),
    .InstrF_i2(instr2),
    .MemWriteM_o1(memwrite1),
    .MemWriteM_o2(memwrite2),
    .ALUResultM_o1(dataadr1), 
    .ALUResultM_o2(dataadr2),
    .WriteDataM_o1(writedata1),
    .WriteDataM_o2(writedata2),
    .ReadDataM_i1(readdata1),
    .ReadDataM_i2(readdata2)

);
ucsbece154_imem imem (
 .a_i1(pc1), .rd_o1(instr1),
 .a_i2(pc2), .rd_o2(instr2)
);
ucsbece154_dmem dmem (
    .clk(clk), 
    .we_i1(memwrite1), .we_i2(memwrite2),
    .a_i1(dataadr1), .a_i2(dataadr2),
    .wd_i1(writedata1), .wd_i2(writedata2),
    .rd_o1(readdata1), .rd_o2(readdata2)
);

endmodule
