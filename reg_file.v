`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/16 16:45:52
// Design Name: 
// Module Name: reg_file
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


`define DATA_WIDTH 32
`define ADDR_WIDTH 5


module reg_file(
	input clk,
	input rst,
	input [`ADDR_WIDTH - 1:0] waddr,
	input [`ADDR_WIDTH - 1:0] raddr1,
	input [`ADDR_WIDTH - 1:0] raddr2,
	input wen,
	input [`DATA_WIDTH - 1:0] wdata,
	output [`DATA_WIDTH - 1:0] rdata1,
	output [`DATA_WIDTH - 1:0] rdata2
);

reg [`DATA_WIDTH - 1:0] register [(1<<`ADDR_WIDTH) - 1 :0] ; 
integer count;

always @ (posedge clk)
 begin 

        if(rst == 0)
             for(count =0 ; count<`DATA_WIDTH ; count=count+1)
              register[count] <= 0;
         else if (wen)
         begin
         if(waddr)
             register[waddr] <= wdata;
         end
   end 
  

assign rdata1 =  register[raddr1];
assign rdata2 = register[raddr2];

endmodule

