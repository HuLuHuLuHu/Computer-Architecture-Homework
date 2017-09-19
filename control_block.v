`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/16 16:41:53
// Design Name: 
// Module Name: control_block
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


module control_block(//input signals
                    input clk,
                    input resetn,
                    input [6:0] extend_inst,
                    input [31:0] alu_result,
                    input zflag,
                    //output signals
                    output reg control_inst_mem_en,
                    output reg control_data_mem_en,
                    output reg [3:0] control_data_mem_wen,
                    output reg [1:0] control_reg_waddr,
                    output reg [1:0] control_reg_wdata,
                    output reg control_reg_wen,
                    output reg [1:0] control_port_b,
                    output reg [1:0] control_port_a,
                    output reg [2:0] control_aluop,
                    output reg [1:0] control_pc_select,
                    output reg control_pc_write,
                    output  control_wb_state
                    );
    //parameters for instructions 
    parameter LUI    = 7'b1001111;
    parameter ADDU   = 7'b0100001;
    parameter ADDIU  = 7'b1001001;
    parameter BEQ    = 7'b1000100;
    parameter BNE    = 7'b1000101;
    parameter LW     = 7'b1100011;
    parameter OR     = 7'b0100101;
    parameter SLT    = 7'b0101010;
    parameter SLTI   = 7'b1001010;
    parameter SLTIU  = 7'b1001011;
    parameter SLL    = 7'b0000000;
    parameter SW     = 7'b1101011;
    parameter J      = 7'b1000010;
    parameter JAL    = 7'b1000011;
    parameter JR     = 7'b0001000;
    
    //parameters for reg manager
    parameter write_to_rd = 2'b00;
    parameter write_to_rt  = 2'b01;
    parameter write_to_31 = 2'b10;
    parameter wdata_from_alu = 2'b00;
    parameter wdata_from_dmem = 2'b01;
    parameter wdata_from_imm  = 2'b10;

    //parameters for alu manager
    parameter b_from_imm= 2'b00;
    parameter b_from_sa = 2'b01;
    parameter b_from_rt = 2'b10;
    parameter b_from_4  = 2'b11;
    parameter a_from_rs = 2'b00;
    parameter a_from_pc = 2'b01;
    parameter a_from_rt = 2'b10;
    //parameters for alu
    parameter alu_and = 3'b000;
    parameter alu_or = 3'b001;
    parameter alu_add = 3'b010;
    parameter alu_sub = 3'b110;
    parameter alu_slt = 3'b111;
    parameter alu_sltiu = 3'b100;
    parameter alu_sll = 3'b011;
    parameter alu_lui = 3'b101;

    //parameters for pc
    parameter reset_address = 32'b0;
    parameter regular_pc = 2'b00;
    parameter imm_extend = 2'b01;
    parameter middle_extend = 2'b10;
    parameter regfile_to_pc = 2'b11;

    //parameter for states
    parameter fetch_inst = 6'd0;
    parameter fetch_reg = 6'd1;
    parameter exec =6'd4;
    parameter alu_to_rd = 6'd5;
    parameter alu_to_rt = 6'd6;
    parameter alu_to_reg31= 6'd12;
    parameter reg_to_mem = 6'd7;
    parameter fetch_mem =6'd8;
    parameter mem_to_rt = 6'd9;
    parameter calculate_pc = 6'd10;

    //state transfer
    reg [5:0] current_state;
    reg [5:0] next_state;

    always @(posedge clk) begin
        if (resetn == 0)
            current_state = 6'd0;
        else 
            current_state <= next_state;
    end

    //next state caculator
    always @ (*) begin
        case(extend_inst)
        LUI,
        ADDIU,
        SLTI,
        SLTIU:
            case(current_state)
            fetch_inst:  next_state = fetch_reg;
            fetch_reg:next_state = exec;
            exec:        next_state = alu_to_rt;
            alu_to_rt:   next_state = fetch_inst;
            default: next_state = 6'd0;
            endcase
        LW:
            case(current_state)
            fetch_inst:  next_state = fetch_reg;
            fetch_reg:next_state = exec;
            exec:        next_state = fetch_mem;
            fetch_mem:   next_state = mem_to_rt;
            mem_to_rt:   next_state = fetch_inst;
            default: next_state = 6'd0;
            endcase
        SW:
            case(current_state)
            fetch_inst:  next_state = fetch_reg;
            fetch_reg:next_state = exec;
            exec:        next_state = reg_to_mem;
            reg_to_mem:  next_state = fetch_inst;
            default: next_state = 6'd0;
            endcase
        BNE,
        BEQ:
            case(current_state)
            fetch_inst:  next_state = fetch_reg;
            fetch_reg: next_state = exec;
            exec:        next_state = calculate_pc;
            calculate_pc:next_state = fetch_inst;
            default: next_state = 6'd0;
            endcase
        OR,
        ADDU,
        SLL,
        SLT:
            case(current_state)
            fetch_inst:  next_state = fetch_reg;
            fetch_reg: next_state = exec;
            exec:        next_state = alu_to_rd;
            alu_to_rd:   next_state = fetch_inst;
            default: next_state = 6'd0;
            endcase
        J:
            case(current_state)
            fetch_inst:  next_state = fetch_reg;
            fetch_reg:next_state = calculate_pc;
            calculate_pc: next_state = fetch_inst;
            default: next_state = 6'd0;
            endcase
        JR:
            case(current_state)
            fetch_inst:  next_state = fetch_reg;
            fetch_reg: next_state = calculate_pc;
            calculate_pc:next_state = fetch_inst;
            default: next_state = 6'd0;
            endcase
        JAL:
            case(current_state)
            fetch_inst:  next_state = fetch_reg;
            fetch_reg:  next_state = exec;
            exec:   next_state = alu_to_reg31;
            alu_to_reg31:    next_state = calculate_pc;
            calculate_pc:  next_state = fetch_inst;
            default: next_state = 6'd0;
            endcase
        default:
             next_state = current_state;
        endcase
    end

    //generate control signals
    always @(current_state)
    begin
        case (current_state)
        //fetch instruction
        fetch_inst: begin
            control_inst_mem_en = 'd1;
            control_data_mem_en = 'd0;
            control_data_mem_wen = 4'b0000;
            control_reg_waddr = write_to_rt;
            control_reg_wdata = wdata_from_alu;
            control_reg_wen = 'd0;
            control_port_b = b_from_rt;
            control_port_a = a_from_rs;
            control_aluop = alu_and;
            control_pc_select = regular_pc;
            control_pc_write = 'b1;
        end
        //prepare data for ALU
        fetch_reg: begin
            control_inst_mem_en = 'd0;
            control_data_mem_en = 'd1;
            control_data_mem_wen = 4'b0000;
            control_reg_waddr = write_to_rt;
            control_reg_wdata = wdata_from_alu;
            control_reg_wen = 'd0;
            control_port_b = b_from_rt;
            control_port_a = a_from_rs;
            control_pc_select = regular_pc;
            control_pc_write = 'b0;
            control_aluop = alu_add;
        end
        //ALU caculate
        exec:begin
            control_inst_mem_en = 'd0;
            control_data_mem_en = 'd0;
            control_data_mem_wen = 4'b0000;
            control_reg_waddr = write_to_rt;
            control_reg_wdata = wdata_from_alu;
            control_reg_wen = 'd0;
            control_pc_select = regular_pc;
            control_pc_write = 'b0;
            case(extend_inst)
            LUI:begin control_port_a = a_from_rs; control_port_b = b_from_imm; control_aluop = alu_lui; end
            ADDIU:begin control_port_a = a_from_rs; control_port_b = b_from_imm; control_aluop = alu_add; end
            SLTI:begin control_port_a = a_from_rs; control_port_b = b_from_imm; control_aluop = alu_slt; end
            SLTIU:begin control_port_a = a_from_rs; control_port_b = b_from_imm; control_aluop = alu_sltiu; end
            SW:begin control_port_a = a_from_rs; control_port_b = b_from_imm; control_aluop = alu_add; end
            LW:begin control_port_a = a_from_rs; control_port_b = b_from_imm; control_aluop = alu_add; end
            ADDU:begin control_port_a = a_from_rs; control_port_b = b_from_rt; control_aluop = alu_add; end
            SLT:begin control_port_a = a_from_rs; control_port_b = b_from_rt; control_aluop = alu_slt; end
            OR:begin control_port_a = a_from_rs; control_port_b = b_from_rt; control_aluop = alu_or; end
            BEQ:begin control_port_a = a_from_rs; control_port_b = b_from_rt; control_aluop = alu_sub; end
            BNE:begin control_port_a = a_from_rs; control_port_b = b_from_rt; control_aluop = alu_sub; end
            JR:begin control_port_a = a_from_rs; control_port_b = b_from_rt; control_aluop = alu_add; end
            SLL:begin control_port_a = a_from_rt; control_port_b = b_from_sa; control_aluop = alu_sll; end
            J:begin control_port_a = a_from_rt; control_port_b = b_from_sa; control_aluop = alu_sll; end
            JAL:begin control_port_a = a_from_pc; control_port_b = b_from_4; control_aluop = alu_add; end
            default:begin control_port_a = a_from_rs; control_port_b = b_from_rt; control_aluop = alu_add; end
            endcase
        end
        alu_to_rd: begin
            control_inst_mem_en = 'd0;
            control_data_mem_en = 'd0;
            control_data_mem_wen = 4'b0000;
            control_reg_waddr = write_to_rd;
            control_reg_wdata = wdata_from_alu;
            control_reg_wen = 'd1;
            control_port_b = b_from_rt;
            control_port_a = a_from_rs;
            control_aluop = alu_and;
            control_pc_select = regular_pc;
            control_pc_write = 'b0;
        end
        alu_to_rt:begin
            control_inst_mem_en = 'd0;
            control_data_mem_en = 'd0;
            control_data_mem_wen = 4'b0000;
            control_reg_waddr = write_to_rt;
            control_reg_wdata = wdata_from_alu;
            control_reg_wen = 'd1;
            control_port_b = b_from_rt;
            control_port_a = a_from_rs;
            control_aluop = alu_and;
            control_pc_select = regular_pc;
            control_pc_write = 'b0;
        end
        alu_to_reg31:begin
            control_inst_mem_en = 'd0;
            control_data_mem_en = 'd0;
            control_data_mem_wen = 4'b0000;
            control_reg_waddr = write_to_31;
            control_reg_wdata = wdata_from_alu;
            control_reg_wen = 'd1;
            control_port_b = b_from_rt;
            control_port_a = a_from_rs;
            control_aluop = alu_and;
            control_pc_select = regular_pc;
            control_pc_write = 'b0;
        end
        mem_to_rt:begin
            control_inst_mem_en = 'd0;
            control_data_mem_en = 'd0;
            control_data_mem_wen = 4'b0000;
            control_reg_waddr = write_to_rt;
            control_reg_wdata = wdata_from_dmem;
            control_reg_wen = 'd1;
            control_port_b = b_from_rt;
            control_port_a = a_from_rs;
            control_aluop = alu_and;
            control_pc_select = regular_pc;
            control_pc_write = 'b0;
        end
        reg_to_mem:begin
            control_inst_mem_en = 'd0;
            control_data_mem_en = 'd1;
            control_data_mem_wen = 4'b1111;
            control_reg_waddr = write_to_rt;
            control_reg_wdata = wdata_from_alu;
            control_reg_wen = 'd0;
            control_port_b = b_from_rt;
            control_port_a = a_from_rs;
            control_aluop = alu_and;   
            control_pc_select = regular_pc;
            control_pc_write = 'b0;
        end
        fetch_mem:begin
            control_inst_mem_en = 'd0;
            control_data_mem_en = 'd1;
            control_data_mem_wen = 4'b0000;
            control_reg_waddr = write_to_rt;
            control_reg_wdata = wdata_from_dmem;
            control_reg_wen = 'd0;
            control_port_b = b_from_rt;
            control_port_a = a_from_rs;
            control_aluop = alu_and;
            control_pc_select = regular_pc;
            control_pc_write = 'b0;
        end
        calculate_pc: begin
            control_inst_mem_en = 'd0;
            control_data_mem_en = 'd0;
            control_data_mem_wen = 4'b0000;
            control_reg_waddr = write_to_rt;
            control_reg_wdata = wdata_from_alu;
            control_reg_wen = 'd0;
            control_port_b = b_from_rt;
            control_port_a = a_from_rs;
            control_aluop = alu_and;
            case(extend_inst)
                BNE: begin control_pc_select =  imm_extend; control_pc_write = (zflag == 0)? 1:0;end
                BEQ: begin control_pc_select =  imm_extend; control_pc_write = (zflag == 1)? 1:0;end
                J:   begin control_pc_select = middle_extend; control_pc_write = 'b1; end
                JAL:  begin control_pc_select = middle_extend; control_pc_write = 'b1; end
                JR:  begin control_pc_select = regfile_to_pc; control_pc_write = 'b1; end
                default:begin control_pc_select = regfile_to_pc; control_pc_write = 'b0; end
            endcase
        end
        default: begin
                  control_inst_mem_en = 'd0;
                  control_data_mem_en = 'd0;
                  control_data_mem_wen = 4'b0000;
                  control_reg_waddr = write_to_rt;
                  control_reg_wdata = wdata_from_dmem;
                  control_reg_wen = 'd0;
                  control_port_b = b_from_rt;
                  control_port_a = a_from_rs;
                  control_aluop = alu_and;
                  control_pc_select = regular_pc;
                  control_pc_write = 'b0;
       
        end
    endcase
    end
    

    assign control_wb_state =  ((current_state == alu_to_reg31) | 
                           (current_state == alu_to_rd) | 
                           (current_state == alu_to_rt) | 
                           (current_state == mem_to_rt) | 
                           (current_state == calculate_pc))? 1:0;
                       
endmodule