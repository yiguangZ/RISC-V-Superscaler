// ucsbece154b_rf.v
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited

module ucsbece154b_rf (
    input               clk,
    input         [4:0] a1_i1, a2_i1, a3_i1,
    output wire  [31:0] rd1_o1, rd2_o1,
    input               we3_i1,
    input        [31:0] wd3_i1,

    // slot 2
    input         [4:0] a1_i2, a2_i2, a3_i2,
    output wire  [31:0] rd1_o2, rd2_o2,
    input               we3_i2,
    input        [31:0] wd3_i2
);

reg [31:0] MEM [0:31];

// register reads
assign rd1_o1 = MEM[a1_i1];
assign rd2_o1 = MEM[a2_i1];
assign rd1_o2 = MEM[a1_i2];
assign rd2_o2 = MEM[a2_i2];

// initialize x0 to 0
initial MEM[0] = 32'b0;

always @(posedge clk) begin
    // slot 1 write
    if (we3_i1 && (a3_i1 != 5'b0))
        MEM[a3_i1] <= wd3_i1;
`ifdef SIM
    if (we3_i1 && (a3_i1 == 5'b0))
        $warning("Slot 1: Attempted to write to $zero register");
`endif

    // slot 2 write
    if (we3_i2 && (a3_i2 != 5'b0))
        MEM[a3_i2] <= wd3_i2;
`ifdef SIM
    if (we3_i2 && (a3_i2 == 5'b0))
        $warning("Slot 2: Attempted to write to $zero register");
`endif
end

`ifdef SIM
wire [31:0] zero = MEM[5'd0];
wire [31:0] ra = MEM[5'd1];
wire [31:0] sp = MEM[5'd2];
wire [31:0] gp = MEM[5'd3];
wire [31:0] tp = MEM[5'd4];
wire [31:0] t0 = MEM[5'd5];
wire [31:0] t1 = MEM[5'd6];
wire [31:0] t2 = MEM[5'd7];
wire [31:0] s0 = MEM[5'd8];
wire [31:0] s1 = MEM[5'd9];
wire [31:0] a0 = MEM[5'd10];
wire [31:0] a1 = MEM[5'd11];
wire [31:0] a2 = MEM[5'd12];
wire [31:0] a3 = MEM[5'd13];
wire [31:0] a4 = MEM[5'd14];
wire [31:0] a5 = MEM[5'd15];
wire [31:0] a6 = MEM[5'd16];
wire [31:0] a7 = MEM[5'd17];
wire [31:0] s2 = MEM[5'd18];
wire [31:0] s3 = MEM[5'd19];
wire [31:0] s4 = MEM[5'd20];
wire [31:0] s5 = MEM[5'd21];
wire [31:0] s6 = MEM[5'd22];
wire [31:0] s7 = MEM[5'd23];
wire [31:0] s8 = MEM[5'd24];
wire [31:0] s9 = MEM[5'd25];
wire [31:0] s10 = MEM[5'd26];
wire [31:0] s11 = MEM[5'd27];
wire [31:0] t3 = MEM[5'd28];
wire [31:0] t4 = MEM[5'd29];
wire [31:0] t5 = MEM[5'd30];
wire [31:0] t6 = MEM[5'd31];
`endif

endmodule
