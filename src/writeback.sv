module writeback
  import riscv_pkg::*;
(

    input  operation_e operation_i,
    input logic [XLEN-1:0] pc_plus4_i,
    input logic [XLEN-1:0] rd_data_i,
    input logic [XLEN-1:0] mem_data_i,

    output logic [XLEN-1:0] write_back_o //register file gidecek
);

    //write back sonucunu oluştur
    always_comb begin
        case (operation_i)
            ADD, SUB, AND, OR, XOR, SLL, SRL, SRA,
            SLT, SLTU, SLTI, SLTIU, ADDI, ANDI, ORI, XORI,
            SLLI, SRLI, SRAI, LUI, AUIPC, CLZ, CTZ, CPOP:
                write_back_o = rd_data_i;

            LW, LH, LB, LHU, LBU:
                write_back_o = mem_data_i;

            JAL, JALR:
                write_back_o = pc_plus4_i;

            default:
                write_back_o = rd_data_i;
        endcase
    end

endmodule

