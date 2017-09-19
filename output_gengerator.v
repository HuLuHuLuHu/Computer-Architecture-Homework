`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/16 23:47:19
// Design Name: 
// Module Name: output_gengerator
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


module output_gengerator(
						//input signals
						input [31:0] alu_result,
						input [31:0] rt_reg_content,
						//output signals
						output [31:0] write_data,
						output [31:0] rw_addr
    );
		assign rw_addr = alu_result;
		assign write_data = rt_reg_content;
endmodule
