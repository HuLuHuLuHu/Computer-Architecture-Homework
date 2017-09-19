`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/17 08:34:26
// Design Name: 
// Module Name: alu
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

module alu(
	input [`DATA_WIDTH - 1:0] A,
	input [`DATA_WIDTH - 1:0] B,
	input [2:0] ALUop,
	output reg Overflow,
	output reg CarryOut,
	output reg Zero,
	output reg [`DATA_WIDTH - 1:0] Result
);

reg carryout_low;
reg [`DATA_WIDTH - 2:0] result_low;


always @(A or B or ALUop)
begin
case (ALUop)
    3'b000://and
    begin
    Result = A & B;
      Zero = (Result == 0) ? 1 :  0;
      Overflow = 0;
      CarryOut = 0;
    end
 
    3'b001://or
    begin
      Result = A | B;
      Zero = (Result == 0) ? 1 :  0;  
      Overflow = 0;
      CarryOut = 0;
    end
   
    3'b010://add
    begin
    {CarryOut,Result }= A + B;
     {carryout_low,result_low} = A[`DATA_WIDTH - 2:0] +B[`DATA_WIDTH - 2:0] ;
      Zero = (Result == 0) ? 1 :  0;
    Overflow = CarryOut ^ carryout_low;
    end

    3'b110://sub
    begin
  {CarryOut, Result} = A + ~B +1;
   {carryout_low,result_low} = A[`DATA_WIDTH - 2:0] +~B[`DATA_WIDTH - 2:0]+1 ;
    Overflow = CarryOut ^ carryout_low;
    Zero = (Result == 0) ? 1 :  0;
    end
 
    3'b111://slt
    begin
    {CarryOut, Result} = A + ~B +1;
     {carryout_low,result_low} = A[`DATA_WIDTH - 2:0] +~B[`DATA_WIDTH - 2:0]+1 ;
     Overflow = CarryOut ^ carryout_low;
    Result [0] = Overflow ^ Result[`DATA_WIDTH-1];
    Result [`DATA_WIDTH-1:1] = 0; 
    Zero = 0;
    CarryOut = 0;
    Overflow = 0;
    end
    
     3'b100://sltiu
    begin
    Result = (A<B)? 1 : 0;
    Zero = 0;
    CarryOut = 0;
    Overflow = 0;
    end
    
    3'b011://sll
    begin
    Result = A<<B;
    Zero = 0;
    CarryOut = 0;
    Overflow = 0;
    end

    3'b101://lui
    begin
    Result = {B[15:0],16'd0};
    Zero = 0;
    CarryOut = 0;
    Overflow = 0;
    end

    default:
    begin
    Zero = 0;
    CarryOut = 0;
    Overflow = 0;
    Result = 0;
    end
endcase     
end
endmodule
