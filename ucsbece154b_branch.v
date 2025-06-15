// ucsbece154_branch.v
// All Rights Reserved
// Copyright (c) 2024 UCSB ECE
// Distribution Prohibited


module ucsbece154b_branch #(
    parameter NUM_BTB_ENTRIES = 32,
    parameter NUM_GHR_BITS    = 5
)(
input [31:0] pc_i2,
input clk,
input reset_i,
input [31:0] BTBwriteaddress_i1,
input [31:0] BTBwritedata_i1,
input        BTB_we1,
input jumpflag1,
input jumpflag2,
input branchflag1,
input branchflag2,


input [31:0] BTBwriteaddress_i2,
input [31:0] BTBwritedata_i2,
input        BTB_we2,


output reg [31:0] BTBtarget_o1,
output reg [31:0] BTBtarget_o2,
output reg        BranchTaken_o1,
output reg        BranchTaken_o2,

input  [5:0] PHTwriteaddress_i1,
input  [5:0] PHTwriteaddress_i2,
input                     PHTincrement_i1,
input                     PHTincrement_i2,
input                     PHTwe_i1,
input                     PHTwe_i2



);

`include "ucsbece154b_defines.vh"

// YOUR CODE HERE
reg branchhit1;
reg jumphit1;
reg branchhit2;
reg jumphit2;
reg [31:0] firstpre;
reg [31:0] keys [0:NUM_BTB_ENTRIES-1];
reg [31:0] values [0:NUM_BTB_ENTRIES-1];
reg [0:NUM_BTB_ENTRIES-1] J;
reg [0:NUM_BTB_ENTRIES-1] B;
integer i;
integer j;
integer k;
integer l;
always @(posedge clk or posedge reset_i) begin
    if (reset_i) begin
        for (i = 0; i < NUM_BTB_ENTRIES; i = i + 1) begin
            keys[i] <= 0;
            values[i] <= 0;
            J[i] <=0;
            B[i] <=0;
        end
    end 
    else if (BTB_we1) begin
        j=0;
        for (i = 0; i < NUM_BTB_ENTRIES; i = i + 1) begin
            if (keys[i]==BTBwriteaddress_i1) begin
                j=1;
            end
        end

        if (j==0) begin
            for (i = 0; i < NUM_BTB_ENTRIES-1; i = i + 1) begin
                keys[i+1]<=keys[i];
                values[i+1]<=values[i];
                J[i+1]<=J[i];
                B[i+1]<=B[i];
            end
            keys[0]<=BTBwriteaddress_i1;
            values[0]<=BTBwritedata_i1;
            J[0]<=jumpflag1;
            B[0]<=branchflag1;
            
        end
    end
    else if (BTB_we2) begin
        j=0;
        for (i = 0; i < NUM_BTB_ENTRIES; i = i + 1) begin
            if (keys[i]==BTBwriteaddress_i2) begin
                j=1;
            end
        end

        if (j==0) begin
            for (i = 0; i < NUM_BTB_ENTRIES-1; i = i + 1) begin
                keys[i+1]<=keys[i];
                values[i+1]<=values[i];
                J[i+1]<=J[i];
                B[i+1]<=B[i];
            end
            keys[0]<=BTBwriteaddress_i2;
            values[0]<=BTBwritedata_i2;
            J[0]<=jumpflag2;
            B[0]<=branchflag2;
            
        end
    end
end

always @ * begin
    l=0;
    firstpre = pc_i2 + 32'd4;
    BTBtarget_o1 = 32'b0;
    branchhit1 = 1'b0;
    jumphit1 = 1'b0;
    for (i = 0; i < NUM_BTB_ENTRIES; i = i + 1) begin
        if (keys[i]==pc_i2 && (B[i]|J[i])==1) begin
            BTBtarget_o1 = values[i];
            firstpre = values[i];
            branchhit1 = B[i];
            jumphit1 = J[i];
            l=1;
        end
    end
    BTBtarget_o2 = firstpre +32'd4;
    branchhit2 = 1'b0;
    jumphit2 = 1'b0;
    for (i = 0; i < NUM_BTB_ENTRIES; i = i + 1) begin
        if (keys[i]==firstpre && (B[i]|J[i])==1) begin
            BTBtarget_o2 = values[i];
            branchhit2 = B[i];
            jumphit2 = J[i];
    end
    end
end
    

reg[63:0] hist;
always @(posedge clk or posedge reset_i) begin
    if (reset_i) begin
        for (i = 0; i < NUM_BTB_ENTRIES; i = i + 1)
            hist[i] <= 1'b1;
    end else if ( PHTwe_i1) begin
        hist[PHTwriteaddress_i1] <= PHTincrement_i1;  
    end
    else if (PHTwe_i2) begin
        hist[PHTwriteaddress_i2] <= PHTincrement_i2;  
    end
end
wire predict_taken1;
wire predict_taken2;
assign predict_taken1=hist[pc_i2[7:2]];
assign predict_taken2=hist[firstpre[7:2]];
always @ * begin
 BranchTaken_o1 <=  (predict_taken1 & branchhit1) | jumphit1;
 BranchTaken_o2 <=  ((firstpre == pc_i2 + 32'd4) |  ((firstpre != pc_i2 + 32'd4) & predict_taken1)) & ((predict_taken2 & branchhit2) | jumphit2);
end
endmodule
