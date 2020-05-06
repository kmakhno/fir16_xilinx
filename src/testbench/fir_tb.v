`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2020 03:33:47 PM
// Design Name: 
// Module Name: test_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fir_tb;

parameter IDATA_WIDTH = 18;
parameter ODATA_WIDTH = 48;
parameter PERIOD = 20;

reg clk, clr, ce;
wire signed [15:0] product;

fir t0(.i_clk(clk), .i_clr(clr), .i_ce(ce), .res(product));


initial begin
    clk = 0;
    ce = 1'b0;
    clr = 1'b1;
end

initial begin
    forever #(PERIOD/2) clk = ~clk;
end


initial begin
    repeat (4) @(negedge clk);
    @(negedge clk) begin
        clr = 1'b0;
        ce = 1'b1;
    end
    repeat (200000) @(negedge clk);
    
    $finish;
end

endmodule
