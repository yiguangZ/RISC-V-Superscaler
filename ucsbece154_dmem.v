// ucsbece154_dmem.v
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited

`define MIN(A,B) (((A)<(B))?(A):(B))

module ucsbece154_dmem #(
    parameter DATA_SIZE = 64
) (
    input               clk, we_i1, we_i2,
    input        [31:0] a_i1, a_i2,
    input        [31:0] wd_i1, wd_i2,
    output wire  [31:0] rd_o1, rd_o2
);

// instantiate/initialize BRAM
reg [31:0] DATA [0:DATA_SIZE-1];

// calculate address bounds for memory
localparam DATA_START = 32'h10000000;
localparam DATA_END   = `MIN(DATA_START + (DATA_SIZE * 4), 32'h80000000);

// calculate address width
localparam DATA_ADDRESS_WIDTH = $clog2(DATA_SIZE);

// create flags to specify whether in-range 
wire data_enable1 = (DATA_START <= a_i1) && (a_i1 < DATA_END);
wire data_enable2 = (DATA_START <= a_i2) && (a_i2 < DATA_END);

// create addresses 
wire [DATA_ADDRESS_WIDTH-1:0] data_address1 = a_i1[2 +: DATA_ADDRESS_WIDTH] - DATA_START[2 +: DATA_ADDRESS_WIDTH];
wire [DATA_ADDRESS_WIDTH-1:0] data_address2 = a_i2[2 +: DATA_ADDRESS_WIDTH] - DATA_START[2 +: DATA_ADDRESS_WIDTH];

// get read-data 
wire [31:0] data_data1 = DATA[data_address1];
wire [31:0] data_data2 = DATA[data_address2];

// set rd_o1 and rd_o2 iff addresses are in range 
assign rd_o1 = data_enable1 ? data_data1 : {32{1'bz}}; // not driven by this memory
assign rd_o2 = data_enable2 ? data_data2 : {32{1'bz}}; // not driven by this memory

// write routine
always @ (posedge clk) begin
    if (we_i1) begin
        if (data_enable1)
            DATA[data_address1] <= wd_i1;
`ifdef SIM
        if (a_i1[1:0] != 2'b0)
            $warning("Attempted to write to invalid address 0x%h. Address coerced to 0x%h.", a_i1, (a_i1 & (~32'b11)));
        if (!data_enable1)
            $warning("Attempted to write to out-of-range address 0x%h.", (a_i1 & (~32'b11)));
`endif
    end
end

always @ (posedge clk) begin
    if (we_i2) begin
        if (data_enable2)
            DATA[data_address2] <= wd_i2;
`ifdef SIM
        if (a_i2[1:0] != 2'b0)
            $warning("Attempted to write to invalid address 0x%h. Address coerced to 0x%h.", a_i2, (a_i2 & (~32'b11)));
        if (!data_enable2)
            $warning("Attempted to write to out-of-range address 0x%h.", (a_i2 & (~32'b11)));
`endif
    end
end

endmodule

`undef MIN
