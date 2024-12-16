`timescale 1ns / 1ps


module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    
// write your code here
    reg [9:0] pc;

    wire [9:0] pc_final;
    wire [9:0] pc_branch;

    always @(posedge clk or posedge reset)  
    begin   
        if(reset)   
           pc <= 10'b0000000000;
        else if (en) //if not data hazards
           pc <= pc_final;  
    end
    
    assign pc_plus4 = pc + 10'b0000000100;
    
    mux2 #(.mux_width(10)) branch_mux // Check branch control bit
    (   .a(pc_plus4),
        .b(branch_address),
        .sel(branch_taken),
        .y(pc_branch));
        
    mux2 #(.mux_width(10)) jump_mux // Check jump control bit
    (   .a(pc_branch),
        .b(jump_address),
        .sel(jump),
        .y(pc_final));
    
    instruction_mem inst_mem ( // Fetch instruction
        .read_addr(pc),
        .data(instr));
endmodule
