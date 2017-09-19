`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/16 16:41:25
// Design Name: 
// Module Name: reg_preparer
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


module reg_preparer(//input signals
                    input  [31:0] instruction,
                    input  [31:0] alu_result,
                    input  [31:0] data_sram_rdata,
                    //control signals
                    input  [1:0] control_reg_waddr,
                    input  [1:0] control_reg_wdata,
                    //output signals
                    output reg [31:0] reg_waddr,
                    output [31:0] reg_raddr1,
                    output  [31:0] reg_raddr2,
                    output reg [31:0] reg_wdata
                    );
    parameter write_to_rd = 2'b00;
    parameter write_to_rt  = 2'b01;
    parameter write_to_31 = 2'b10;
    parameter wdata_from_alu = 2'b00;
    parameter wdata_from_dmem = 2'b01;
    parameter wdata_from_imm  = 2'b10;
    
    // decide what data to write to reg_file
    always @ (*) begin
        case(control_reg_wdata)
        wdata_from_imm:
            reg_wdata = {instruction[15:0],16'd0};
        wdata_from_dmem:
            reg_wdata = data_sram_rdata;
        wdata_from_alu:
            reg_wdata = alu_result;
        default:
            reg_wdata = 32'b0;
        endcase
    end

    //dicide what address to write
    always @ (*) begin
        case(control_reg_waddr)
        write_to_rt:
            reg_waddr = instruction[20:16];
        write_to_rd:
            reg_waddr = instruction[15:11];
        write_to_31:
            reg_waddr = 5'd31;
        default:
            reg_waddr = 5'd0;
        endcase
    end

    //decide what to read
    assign reg_raddr1 = instruction[25:21]; //read rs
    assign reg_raddr2 = instruction[20:16]; //read rt
    
endmodule
