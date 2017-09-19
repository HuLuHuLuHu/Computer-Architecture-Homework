`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/16 16:00:30
// Design Name: 
// Module Name: decoder
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


module decoder(
    input [31:0] instruction,
    output [6:0] extend_inst
    );
    
    assign extend_inst = (instruction[31:26] == 6'b000000)? {1'b0,instruction[5:0]}:{1'b1,instruction[31:26]};

endmodule
