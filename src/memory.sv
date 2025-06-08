module memory
  import riscv_pkg::*;
(
    input  logic clk_i,
    input  logic rstn_i,
    input  logic [XLEN-1:0] mem_wr_data_i,
    input  logic [XLEN-1:0] mem_wr_addr_i,
    input  logic            mem_wr_enable_i,
    input  operation_e      operation_i,
    output logic [XLEN-1:0] mem_data_o,

    input logic [31:0] debug_addr,
    output logic [31:0] debug_data



);
    // Bellek parametreleri
    parameter int MEM_SIZE = 2048;
    logic [31:0] dmem [MEM_SIZE-1:0];  // Veri belleği

    always_comb begin
        case (operation_i) 
            LB:  mem_data_o = {{24'({dmem[mem_wr_addr_i[$clog2(MEM_SIZE)-1:0]][7]})}, dmem[mem_wr_addr_i[$clog2(MEM_SIZE)-1:0]][7:0]};
            LH:  mem_data_o = {{16'({dmem[mem_wr_addr_i[$clog2(MEM_SIZE)-1:0]][7]})}, dmem[mem_wr_addr_i[$clog2(MEM_SIZE)-1:0]][15:0]};
            LW:  mem_data_o =  dmem[mem_wr_addr_i[$clog2(MEM_SIZE)-1:0]];
            LBU: mem_data_o = {{24'b0}, dmem[mem_wr_addr_i[$clog2(MEM_SIZE)-1:0]][7:0]};
            LHU: mem_data_o = {{16'b0}, dmem[mem_wr_addr_i[$clog2(MEM_SIZE)-1:0]][15:0]};
            default: mem_data_o = '0;
        endcase
        debug_data = dmem[debug_addr[$clog2(MEM_SIZE)-1:0]];

    end


    // Veri belleği yazma işlemi
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            // Reset durumunda bellek işlemi yok
        end 
        else if (mem_wr_enable_i) begin
            case(operation_i)
                SB : dmem[mem_wr_addr_i[$clog2(MEM_SIZE)-1:0]][ 7:0] <= mem_wr_data_i[ 7:0];  // Byte yazma
                SH : dmem[mem_wr_addr_i[$clog2(MEM_SIZE)-1:0]][15:0] <= mem_wr_data_i[15:0];  // Half word yazma
                SW : dmem[mem_wr_addr_i[$clog2(MEM_SIZE)-1:0]]       <= mem_wr_data_i;        // Word yazma
                
            endcase
        end
    end

endmodule
