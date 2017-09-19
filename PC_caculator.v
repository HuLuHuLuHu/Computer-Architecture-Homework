`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/16 23:06:13
// Design Name: 
// Module Name: PC_caculator
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


module PC_caculator(
					//input signals
					input clk,
					input reset,
					input [31:0] instruction,
					input [31:0] rs_reg_content,
					//control signals
					input [1:0] pc_select,
					input pc_write,
					//output signals
					output reg [31:0] pc
    );

		parameter reset_address = 32'hbfc00000;
		parameter regular_pc = 2'b00;
		parameter imm_extend = 2'b01;
		parameter middle_extend = 2'b10;
		parameter regfile_to_pc = 2'b11;

		always @(posedge clk) begin
			if(reset == 0)
				pc <= reset_address;
			else if(pc_write == 1) begin
				case(pc_select)
				regular_pc:
					pc <= pc + 32'd4;
				imm_extend:
				    pc <= pc + ({{16{instruction[15]}},instruction[15:0]}<<2);
				middle_extend:
					pc <= {pc[31:28],instruction[25:0],2'b00};
				regfile_to_pc:
					pc <= rs_reg_content;
			     default:
			         pc <= pc;
				endcase
				end
			else 
				pc <= pc;
		end
endmodule
