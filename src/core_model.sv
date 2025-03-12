module core_model
  import riscv_pkg::*;
(
    input  logic clk_i,
    input  logic rstn_i,
    input  logic  [XLEN-1:0] addr_i,
    output logic             update_o,
    output logic  [XLEN-1:0] data_o,
    output logic  [XLEN-1:0] pc_o,
    output logic  [XLEN-1:0] instr_o,
    output logic  [     4:0] reg_addr_o,
    output logic  [XLEN-1:0] reg_data_o
);
    // memory
    parameter int MEM_SIZE = 2048;
    logic [31:0]     dmem [MEM_SIZE-1:0];
    initial $readmemh("./test/test.hex", imem, 0, MEM_SIZE);
    // pc + instr

    logic [XLEN-1:0] jump_pc_d;
    logic            jump_pc_valid_d;
    logic [XLEN-1:0] instr_d;
    assign data_o = dmem[addr_i];
    assign instr_o = instr_d;
    assign reg_addr_o = rf_wr_enable ? instr_d[11:7] : '0;
    assign reg_data_o = rd_data;
    logic [XLEN-1:0] rd_data;

    logic [XLEN-1:0] mem_wr_data;   // memory write data
    logic [XLEN-1:0] mem_wr_addr;   // memory write address
    logic            mem_wr_enable; // memory write enable

    ///////////////////////// FETCH //////////////////

    ///////////////////////// FETCH //////////////////

    ///////////////////////// DECODE //////////////////

    ///////////////////////// DECODE //////////////////


    ///////////////////////// EXECUTE //////////////////

    ///////////////////////// EXECUTE //////////////////

    ///////////////////////// MEMORY //////////////////
    always_ff @(posedge clk_i) begin
      if (!rstn_i) begin
      end else if (mem_wr_enable) begin
        case(instr_d[14:12])
          F3_SB :         dmem[mem_wr_addr[$clog2(MEM_SIZE)-1:0]][ 7:0] <= rs2_data[ 7:0];
          F3_SH :         dmem[mem_wr_addr[$clog2(MEM_SIZE)-1:0]][15:0] <= rs2_data[15:0];
          F3_SW :         dmem[mem_wr_addr[$clog2(MEM_SIZE)-1:0]]       <= rs2_data;
        endcase
      end
    end
    ///////////////////////// MEMORY //////////////////

    ////////////////////// WRITE_BACK ///////////////

    ////////////////////// WRITE_BACK ///////////////

endmodule
