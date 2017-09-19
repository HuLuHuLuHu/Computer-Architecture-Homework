`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/16 10:27:27
// Design Name: 
// Module Name: mycpu_top
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


module mycpu_top(
    input [0:0] clk,
    input [0:0] resetn,
    output [0:0] inst_sram_en,  //from control block
    output [3:0] inst_sram_wen,		//always zero
    output [31:0] inst_sram_addr, //from pc caculator
    output [31:0] inst_sram_wdata, //always zero
    input [31:0] inst_sram_rdata,
    output [0:0] data_sram_en, //from control block
    output [3:0] data_sram_wen,//from control block
    output [31:0] data_sram_addr, //from output generator
    output [31:0] data_sram_wdata, //from output generator
    input [31:0] data_sram_rdata, 
    output [31:0] debug_wb_pc,
    output [3:0] debug_wb_rf_wen,
    output [4:0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
    );
    
    //instruction memory's wdata and waddr shoule always zero
    assign inst_sram_wen = 4'b0000;
    assign inst_sram_wdata = 32'd0;

    //the decoder extend the op in instruction to distinguish the R-type instructions
    wire [6:0] extend_inst;
    reg [31:0] alu_result_holder; //pre defined for early use
    reg alu_zero; //pre defined for early use
    wire wire_alu_zero;
    decoder decoder(.instruction(inst_sram_rdata),
                    .extend_inst(extend_inst)
                    );
    
    //the control block generate the control signals according to the extend_inst
    wire [1:0] control_reg_waddr;
    wire [1:0] control_reg_wdata;
    wire control_reg_wen;
    wire [1:0] control_port_b;
    wire [1:0] control_port_a;
    wire [2:0] control_aluop;
    wire [1:0] control_pc_select;
    wire control_pc_write;
    wire control_wb_state;
    control_block control_block(
    							//input signals
    							.clk(clk),
    							.resetn(resetn),
    							.extend_inst(extend_inst),
    							.alu_result(alu_result_holder),
                                .zflag(wire_alu_zero),
    							//output signals
    							.control_inst_mem_en(inst_sram_en),
    							.control_data_mem_en(data_sram_en),
    							.control_data_mem_wen(data_sram_wen),
    							.control_reg_waddr(control_reg_waddr),
    							.control_reg_wdata(control_reg_wdata),
    							.control_reg_wen(control_reg_wen),
    							.control_port_b(control_port_b),
                                .control_port_a(control_port_a),
    							.control_aluop(control_aluop),
    							.control_pc_select(control_pc_select),
    							.control_pc_write(control_pc_write),
    							.control_wb_state(control_wb_state)
                                );

    //this block manage the resources to the reg_flie
    wire [31:0] reg_waddr;
    wire [31:0] reg_raddr1;
    wire [31:0] reg_raddr2;
    wire [31:0] reg_wdata;
    reg_preparer reg_preparer(
                            //input signals
                            .instruction(inst_sram_rdata),
                            .alu_result(alu_result_holder),
                            .data_sram_rdata(data_sram_rdata),
                            //control signals
                            .control_reg_waddr(control_reg_waddr),
                            .control_reg_wdata(control_reg_wdata),
                            //output signals
                            .reg_waddr(reg_waddr),
                            .reg_raddr1(reg_raddr1),
                            .reg_raddr2(reg_raddr2),
                            .reg_wdata(reg_wdata)
                            );

    //this block holds the data from reg_file
    wire [31:0] wire_read_data_one;
    wire [31:0] wire_read_data_two;
    reg [31:0] read_data_one;//rs
    reg [31:0] read_data_two;//rt
    always @ (posedge clk) begin
        read_data_one <= wire_read_data_one;
        read_data_two <= wire_read_data_two;
    end

    //the register files
    reg_file reg_file(.clk(clk),
                      .rst(resetn),
                      .waddr(reg_waddr),
                      .raddr1(reg_raddr1),
                      .raddr2(reg_raddr2),
                      .wen(control_reg_wen),
                      .wdata(reg_wdata),
                      .rdata1(wire_read_data_one),
                      .rdata2(wire_read_data_two)
                        );

    //this block holds the data for ALU to caculate
    wire [31:0] alu_a_port;
    wire [31:0] alu_b_port;
    alu_preparer alu_preparer(//input signals
                                .instruction(inst_sram_rdata),
                                .rs_reg_content(read_data_one),
                                .rt_reg_content(read_data_two),
                                .pc(inst_sram_addr),                  //new
                                //control signals
                                .control_port_b(control_port_b),
                                .control_port_a(control_port_a),
                                //output signals
                                .b_port(alu_b_port),
                                .a_port(alu_a_port)
                                );
    
    //this block holds the results alu outputs
    wire wire_alu_overflow;
    wire wire_alu_carryout;
    wire [31:0] wire_alu_result_holder;
    reg alu_overflow;
    reg alu_carryout;
    //reg [31:0] alu_result_holder is define above
    always @ (posedge clk) begin
    	alu_overflow <= wire_alu_overflow;
    	alu_carryout <= wire_alu_carryout;
    	alu_zero <= wire_alu_zero;
    	alu_result_holder <= wire_alu_result_holder;
    end

    //ALU does all the caculation jobs
    alu alu(.A(alu_a_port),
            .B(alu_b_port),
            .ALUop(control_aluop),
            .Overflow(wire_alu_overflow),
            .CarryOut(wire_alu_carryout),
            .Zero(wire_alu_zero),
            .Result(wire_alu_result_holder)
            );
    wire [31:0] PC;
    //PC caculator generates the next PC
    PC_caculator PC_caculator(//input signals
                                .clk(clk),
                                .reset(resetn),
                                .instruction(inst_sram_rdata),
                                .rs_reg_content(read_data_one),
                                //control signals
                                .pc_select(control_pc_select),
                                .pc_write(control_pc_write),
                                //output signals
                                .pc(PC)
                                );
    assign inst_sram_addr = PC;
    //output generator generates the output signals
    output_gengerator output_gengerator(
                                        .alu_result(alu_result_holder),
                                        .rt_reg_content(read_data_two),
                                        .write_data(data_sram_wdata),
                                        .rw_addr(data_sram_addr)
                                        );
  
            assign debug_wb_pc = PC - 4;
            assign debug_wb_rf_wen = (control_reg_wen == 1)? 4'b1111:4'b0000;
            assign debug_wb_rf_wnum = reg_waddr;
            assign debug_wb_rf_wdata = reg_wdata;

endmodule
