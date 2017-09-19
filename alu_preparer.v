`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/16 22:21:11
// Design Name: 
// Module Name: alu_preparer
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


module alu_preparer(//input signals
					input [31:0] instruction,
					input [31:0] rs_reg_content,
					input [31:0] rt_reg_content,
					input [31:0] pc,
					//control signals
					input [1:0] control_port_a,
					input [1:0] control_port_b,
					//output signals
					output reg [31:0] b_port,
					output reg [31:0] a_port
    );

	parameter b_from_imm = 2'b00;
	parameter b_from_sa = 2'b01;
	parameter b_from_rt = 2'b10;
	parameter b_from_4   = 2'b11;
	parameter a_from_rs = 2'b00;
	parameter a_from_pc = 2'b01;
	parameter a_from_rt = 2'b10;

	always @ (*) begin
	case(control_port_b)
	b_from_imm:
		b_port = (instruction[15] == 0)? {16'h0000,instruction[15:0]}:{16'hffff,instruction[15:0]};
	b_from_rt:
		b_port = rt_reg_content;
	b_from_sa:
		b_port = {27'd0,instruction[10:6]};
	b_from_4:
		b_port = 'd4;
	default:
	   b_port = 32'b0;
	endcase
	case(control_port_a)
	a_from_rs: 
		a_port = rs_reg_content;
	a_from_pc:
		a_port = pc;
	a_from_rt:
		a_port = rt_reg_content;
	default:
		a_port = rs_reg_content;
	endcase
	end

endmodule
