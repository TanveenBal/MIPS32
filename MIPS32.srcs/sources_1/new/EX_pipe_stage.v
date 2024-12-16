`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    
    // Write your code here
    // ALUControl Wire
    wire [3:0] ALU_Control_wire;
    
    // Register Mux Wires
    wire [31:0] reg1_wire_mux;
    wire [31:0] reg2_wire_mux;
    wire [31:0] reg2_immediate_wire_mux;
    wire zero; // Where is this given?
    
    
    ALUControl alu_control_inst ( // Fetch ALU_Control bits for ALU 
        .ALUOp(id_ex_alu_op),
        .Function(id_ex_instr[5:0]),
        .ALU_Control(ALU_Control_wire));
    
    // Muxes to determine what register value is needed
    mux4 #(.mux_width(32)) reg1_mux
    (   .a(reg1),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(32'b0),
        .sel(Forward_A),
        .y(reg1_wire_mux));
        
    mux4 #(.mux_width(32)) reg2_mux
    (   .a(reg2),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(32'b0),
        .sel(Forward_B),
        .y(reg2_wire_mux));
        
    assign alu_in2_out = reg2_wire_mux;
        
    mux2 #(.mux_width(32)) mem_to_reg_mux
    (   .a(reg2_wire_mux),
        .b(id_ex_imm_value),
        .sel(id_ex_alu_src),
        .y(reg2_immediate_wire_mux));
    
    ALU alu_inst ( // Execute ALU
        .a(reg1_wire_mux),
        .b(reg2_immediate_wire_mux),
        .alu_control(ALU_Control_wire),
        .zero(zero), // Not needed?
        .alu_result(alu_result));
endmodule
