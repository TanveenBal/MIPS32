`timescale 1ns / 1ps


module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    
    // write your code here 
    // Remember that we test if the branch is taken or not in the decode stage. 	
    // Register File Wires
    wire [31:0] reg1_wire;
    wire [31:0] reg2_wire;
    // EQ Test Wire
    wire eq_test;
    // Control Mux Wires
    wire reg_dst;
    wire mem_to_reg_wire, mem_read_wire, mem_write_wire, alu_src_wire, reg_write_wire;
    wire [1:0] alu_op_wire;
    wire branch_wire;
    wire Hazard;
    
    control control_inst ( // Fetch control bits
        .reset(reset),
        .opcode(instr[31:26]),
        .reg_dst(reg_dst),
        .mem_to_reg(mem_to_reg_wire),
        .alu_op(alu_op_wire),
        .mem_read(mem_read_wire),
        .mem_write(mem_write_wire),
        .alu_src(alu_src_wire),
        .reg_write(reg_write_wire),
        .branch(branch_wire),
        .jump(jump));
    
    // Hazard muxes
    assign Hazard = ~Data_Hazard || Control_Hazard;
    
    mux2 #(.mux_width(1)) mem_to_reg_mux
    (   .a(mem_to_reg_wire),
        .b(1'b0),
        .sel(Hazard),
        .y(mem_to_reg));
        
    mux2 #(.mux_width(2)) alu_op_mux
    (   .a(alu_op_wire),
        .b(2'b0),
        .sel(Hazard),
        .y(alu_op));
    
    mux2 #(.mux_width(1)) mem_read_mux
    (   .a(mem_read_wire),
        .b(1'b0),
        .sel(Hazard),
        .y(mem_read));
        
    mux2 #(.mux_width(1)) mem_write_mux
    (   .a(mem_write_wire),
        .b(1'b0),
        .sel(Hazard),
        .y(mem_write));
    
    mux2 #(.mux_width(1)) alu_src_mux
    (   .a(alu_src_wire),
        .b(1'b0),
        .sel(Hazard),
        .y(alu_src));
        
    mux2 #(.mux_width(1)) reg_write_mux
    (   .a(reg_write_wire),
        .b(1'b0),
        .sel(Hazard),
        .y(reg_write));
        
    assign eq_test = ((reg1_wire ^ reg2_wire)==32'd0) ? 1'b1: 1'b0;
    assign branch_taken = branch_wire && eq_test;
    
    // Jump and Branch address
    assign jump_address = instr[25:0] << 2;
    assign branch_address = (imm_value << 2) + pc_plus4;
    
    register_file reg_file ( // Fetch register 1 and 2 from register file
        .clk(clk),  
        .reset(reset),  
        .reg_write_en(mem_wb_reg_write),  
        .reg_write_dest(mem_wb_write_reg_addr),  
        .reg_write_data(mem_wb_write_back_data),  
        .reg_read_addr_1(instr[25:21]), 
        .reg_read_addr_2(instr[20:16]), 
        .reg_read_data_1(reg1_wire),
        .reg_read_data_2(reg2_wire));

    assign reg1 = reg1_wire;
    assign reg2 = reg2_wire;
    
    sign_extend sign_ex_inst ( // Sign extend 16-bit immediate -> 32-bit immediate
        .sign_ex_in(instr[15:0]),
        .sign_ex_out(imm_value)); 
    
    mux2 #(.mux_width(5)) reg_dest_mux // Register destination selection
    (   .a(instr[20:16]),
        .b(instr[15:11]),
        .sel(reg_dst),
        .y(destination_reg));    
endmodule
