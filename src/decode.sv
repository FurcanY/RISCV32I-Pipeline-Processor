module decode
  import riscv_pkg::*;
(
    input  logic [XLEN-1:0] instr_i,
    input  logic clk_i,
    input  logic [4:0] rsd_addr_i,
    input  logic rf_wr_enable_i,
    input  logic [XLEN-1:0] write_back_i,
    
    // Forwarding inputs
    input  logic [4:0] rsd_addr_M,
    input  logic [XLEN-1:0] rd_data_M,
    input  logic rf_wr_enable_M,
    
    output logic [XLEN-1:0] imm_data_o,
    output logic [4:0]      shamt_data_o,
    output logic [XLEN-1:0] rs1_data_o,
    output logic [XLEN-1:0] rs2_data_o,
    output logic            mem_wr_ena_o,
    output operation_e      operation_o,
    output logic            rd_wrt_ena_o,
    output logic [4:0]      rs1_addr_o,
    output logic [4:0]      rs2_addr_o,
    output logic [4:0]      rsd_addr_o,
    output logic            do_jump_o,
    output logic            do_branch_o
);

    logic [XLEN-1:0] rf [31:0];
    logic [XLEN-1:0] rs1_data_raw, rs2_data_raw;

    assign rs1_addr_o = instr_i[19:15];
    assign rs2_addr_o = instr_i[24:20];
    assign rsd_addr_o = instr_i[11:7];

    
    always_ff @ (posedge clk_i) begin
        if(rf_wr_enable_i && rsd_addr_i != 0) begin
            rf[rsd_addr_i] <= write_back_i;
        end
    end

    
    assign rs1_data_raw = rf[rs1_addr_o];
    assign rs2_data_raw = rf[rs2_addr_o];

    
    always_comb begin
        if ((rs1_addr_o != 0) && (rs1_addr_o == rsd_addr_i) && rf_wr_enable_i)
            rs1_data_o = write_back_i;  
        else if ((rs1_addr_o != 0) && (rs1_addr_o == rsd_addr_M) && rf_wr_enable_M)
            rs1_data_o = rd_data_M;     
        else
            rs1_data_o = rs1_data_raw;
    end

    
    always_comb begin
        if ((rs2_addr_o != 0) && (rs2_addr_o == rsd_addr_i) && rf_wr_enable_i)
            rs2_data_o = write_back_i;  
        else if ((rs2_addr_o != 0) && (rs2_addr_o == rsd_addr_M) && rf_wr_enable_M)
            rs2_data_o = rd_data_M;     
        else
            rs2_data_o = rs2_data_raw;
    end

    always_comb begin : decode_block
        // Tüm sinyalleri sıfırla
        imm_data_o = 32'b0;
        shamt_data_o = 5'b0;
        mem_wr_ena_o = 1'b0;
        operation_o  = UNKNOWN;
        rd_wrt_ena_o = 1'b0;
        do_jump_o = 1'b0;
        do_branch_o = 1'b0;
        
        // Komut tipine göre decode işlemi
        case(instr_i[6:0])


            OpcodeLui: begin
                imm_data_o = {instr_i[31:12] , 12'b0};
                operation_o = LUI;
                rd_wrt_ena_o = 1'b1;
            end   

            OpcodeAuipc: begin
                imm_data_o = {instr_i[31:12] , 12'b0};
                operation_o = AUIPC;
                rd_wrt_ena_o = 1'b1;
            end

            OpcodeJal: begin
                imm_data_o = {{12'(signed'(instr_i[31]))}, instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0};
                operation_o = JAL;
                rd_wrt_ena_o = 1'b1;
                do_jump_o = 1'b1;
            end

            OpcodeJalr: begin
                if (instr_i[14:12] == F3_JALR) begin
                    rd_wrt_ena_o = 1'b1;
                    operation_o = JALR;
                    imm_data_o = {{21'(signed'(instr_i[31]))}, instr_i[30:20]};
                    do_jump_o = 1'b1;
                end
            end

            OpcodeBranch: begin
                if ( instr_i[14:12] == F3_BEQ ) operation_o = BEQ;
                if ( instr_i[14:12] == F3_BNE ) operation_o = BNE;
                if ( instr_i[14:12] == F3_BLT ) operation_o = BLT;
                if ( instr_i[14:12] == F3_BGE ) operation_o = BGE;
                if ( instr_i[14:12] == F3_BLTU ) operation_o = BLTU;
                if ( instr_i[14:12] == F3_BGEU ) operation_o = BGEU;

                if (instr_i[14:12] inside {F3_BEQ, F3_BNE, F3_BLT, F3_BGE, F3_BLTU, F3_BGEU}) begin
                    do_branch_o = 1'b1;
                    rd_wrt_ena_o = 1'b0;
                    imm_data_o = {{19'(signed'(instr_i[31]))}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0};
                end
            end

            OpcodeLoad: begin
                case (instr_i[14:12])
                    F3_LB: begin
                        operation_o = LB;
                        rd_wrt_ena_o = 1'b1;
                    end
                    F3_LH: begin
                        operation_o = LH;
                        rd_wrt_ena_o = 1'b1;
                    end
                    F3_LW: begin
                        operation_o = LW;
                        rd_wrt_ena_o = 1'b1;
                    end
                    F3_LBU: begin
                        operation_o = LBU;
                        rd_wrt_ena_o = 1'b1;
                    end
                    F3_LHU: begin
                        operation_o = LHU;
                        rd_wrt_ena_o = 1'b1;
                    end
                    default: operation_o = UNKNOWN;
                endcase
                imm_data_o = {{20'(signed'(instr_i[31]))}, instr_i[31:20]};
            end

            OpcodeStore: begin
                case (instr_i[14:12])
                    F3_SB: begin
                        operation_o = SB;
                        mem_wr_ena_o = 1'b1;
                    end
                    F3_SH: begin
                        operation_o = SH;
                        mem_wr_ena_o = 1'b1;
                    end
                    F3_SW: begin
                        operation_o = SW;
                        mem_wr_ena_o = 1'b1;
                    end
                    default: operation_o = UNKNOWN;
                endcase
                imm_data_o = {{20'(signed'(instr_i[31]))}, instr_i[31:25], instr_i[11:7]};
            end

            OpcodeOpImm: begin
                case (instr_i[14:12])
                    F3_ADDI: begin
                        operation_o = ADDI;
                        rd_wrt_ena_o = 1'b1;
                        imm_data_o = {{20{instr_i[31]}}, instr_i[31:20]};
                    end
                    F3_SLTI: begin
                        operation_o = SLTI;
                        rd_wrt_ena_o = 1'b1;
                        imm_data_o = {{20{instr_i[31]}}, instr_i[31:20]};
                    end
                    F3_SLTIU: begin
                        operation_o = SLTIU;
                        rd_wrt_ena_o = 1'b1;
                        imm_data_o = {{20{instr_i[31]}}, instr_i[31:20]};
                    end
                    F3_XORI: begin
                        operation_o = XORI;
                        rd_wrt_ena_o = 1'b1;
                        imm_data_o = {{20{instr_i[31]}}, instr_i[31:20]};
                    end
                    F3_ORI: begin
                        operation_o = ORI;
                        rd_wrt_ena_o = 1'b1;
                        imm_data_o = {{20{instr_i[31]}}, instr_i[31:20]};
                    end
                    F3_ANDI: begin
                        operation_o = ANDI;
                        rd_wrt_ena_o = 1'b1;
                        imm_data_o = {{20{instr_i[31]}}, instr_i[31:20]};
                    end
                    F3_SLLI: begin  // 3'b001 - ama birden fazla instruction bu funct3'ü kullanıyor
                        if (instr_i[31:25] == F7_SLLI) begin      // 7'b0000000
                            operation_o = SLLI;
                            rd_wrt_ena_o = 1'b1;
                            shamt_data_o = instr_i[24:20];
                        end 
                        else if (instr_i[31:25] == F7_CTZ_CLZ_CPOP) begin  // 7'b0110000
                            rd_wrt_ena_o = 1'b1;
                            if(instr_i[24:20] == 5'b00000) operation_o = CLZ;
                            else if(instr_i[24:20] == 5'b00001) operation_o = CTZ;
                            else if(instr_i[24:20] == 5'b00010) operation_o = CPOP;
                            else operation_o = UNKNOWN;
                        end
                        else begin
                            operation_o = UNKNOWN;
                        end
                    end
                    F3_SRLI: begin
                        if (instr_i[31:25] == F7_SRLI) begin
                            operation_o = SRLI;
                        end else if (instr_i[31:25] == F7_SRAI) begin
                            operation_o = SRAI;
                        end
                        rd_wrt_ena_o = 1'b1;
                        shamt_data_o = instr_i[24:20];
                    end
                    
                    default: operation_o = UNKNOWN;
                endcase
            end

    
            OpcodeOp: begin
                case(instr_i[14:12])
                    F3_ADD: begin
                        if (instr_i[31:25] == F7_ADD) begin
                            rd_wrt_ena_o = 1'b1;
                            operation_o = ADD;
                        end else if (instr_i[31:25] == F7_SUB) begin
                            rd_wrt_ena_o = 1'b1;
                            operation_o = SUB;
                        end
                    end
                    F3_SLL: begin
                        if (instr_i[31:25] == F7_SLL) begin
                            rd_wrt_ena_o = 1'b1;
                            operation_o = SLL;
                        end
                    end
                    F3_SLT: begin
                        if (instr_i[31:25] == F7_SLT) begin
                            rd_wrt_ena_o = 1'b1;
                            operation_o = SLT;
                        end
                    end
                    F3_SLTU: begin
                        if (instr_i[31:25] == F7_SLTU) begin
                            rd_wrt_ena_o = 1'b1;
                            operation_o = SLTU;
                        end
                    end
                    F3_XOR: begin
                        if (instr_i[31:25] == F7_XOR) begin
                            rd_wrt_ena_o = 1'b1;
                            operation_o = XOR;
                        end
                    end
                    F3_SRL: begin
                        if (instr_i[31:25] == F7_SRL) begin
                            rd_wrt_ena_o = 1'b1;
                            operation_o = SRL;
                        end else if (instr_i[31:25] == F7_SRA) begin
                            rd_wrt_ena_o = 1'b1;
                            operation_o = SRA;
                        end
                    end
                    F3_OR: begin
                        if (instr_i[31:25] == F7_OR) begin
                            rd_wrt_ena_o = 1'b1;
                            operation_o = OR;
                        end
                    end
                    F3_AND: begin
                        if (instr_i[31:25] == F7_AND) begin
                            rd_wrt_ena_o = 1'b1;
                            operation_o = AND;
                        end
                    end
                endcase
            end

            default: ;
        endcase
    end

endmodule
