module decode
  import riscv_pkg::*;
(
    input  logic             clk_i,
    input  logic             rstn_i,
    input  logic  [XLEN-1:0] pc_i,
    input  logic  [XLEN-1:0] instruction_i,
    input  logic  [     4:0] rd_addr_i,
    input  logic             rd_wrt_ena_i,
    input  logic             mem_wrt_ena_i,
    output rd_port_t         rd_port_o,
    output logic             mem_wrt_ena_o,
    output logic  [XLEN-1:0] mem_wrt_addr_o,
    output logic  [XLEN-1:0] mem_wrt_data_o,
    output logic  [XLEN-1:0] pc_o,
    output logic  [XLEN-1:0] instruction_o,
    output logic  [XLEN-1:0] alu_data_o,
    output logic             next_pc_ena_o,
    output logic  [XLEN-1:0] next_pc_o
    

);

    always_comb begin : execute_block
      next_pc_ena_o = 0;
      next_pc_o = 0;
      rd_port_o.data = 0;
      case(instr_d[6:0])
        OpcodeLui: begin
          rd_port_o.data = imm_data;
        end 
        OpcodeAuipc: begin
          rd_port_o.data =  imm_data + pc_q;
        end
        OpcodeJal: begin
          next_pc_ena_o = 1'b1;
          next_pc_o = imm_data + pc_q;
          rd_port_o.data = pc_q + 4;
        end
        OpcodeJalr:begin
          next_pc_ena_o = 1'b1;
          next_pc_o = imm_data + rs1_data;
          rd_port_o.data = pc_q + 4;
        end
        OpcodeBranch:
          case(instr_d[14:12])
            F3_BEQ  : if (rs1_data == rs2_data) begin
              next_pc_o = imm_data + pc_q;
              next_pc_ena_o = 1'b1;
            end 
            F3_BNE  : if (rs1_data != rs2_data) begin
              next_pc_o = imm_data + pc_q;
              next_pc_ena_o = 1'b1;
            end 
            F3_BLT  : if ($signed(rs1_data) < $signed(rs2_data)) begin
              next_pc_o = imm_data + pc_q;
              next_pc_ena_o = 1'b1;
            end 
            F3_BGE  : if ($signed(rs1_data) >= $signed(rs2_data)) begin
              next_pc_o = imm_data + pc_q;
              next_pc_ena_o = 1'b1;
            end 
            F3_BLTU : if (rs1_data < rs2_data) begin
              next_pc_o = imm_data + pc_q;
              next_pc_ena_o = 1'b1;
            end 
            F3_BGEU : if (rs1_data >= rs2_data) begin
              next_pc_o = imm_data + pc_q;
              next_pc_ena_o = 1'b1;
            end 
          endcase
        OpcodeLoad:
          case(instr_d[14:12])
            F3_LB  : begin
              rd_port_o.data = {{24'({dmem[rs1_data[$clog2(MEM_SIZE)-1:0]][7]})}, dmem[rs1_data[$clog2(MEM_SIZE)-1:0]][7:0]};
            end 
            F3_LH  : begin
              rd_port_o.data = {{16'({dmem[rs1_data[$clog2(MEM_SIZE)-1:0]][7]})}, dmem[rs1_data[$clog2(MEM_SIZE)-1:0]][15:0]};
            end 
            F3_LW  : begin
              rd_port_o.data =dmem[rs1_data[$clog2(MEM_SIZE)-1:0]];
            end 
            F3_LBU : begin
              rd_port_o.data = {{24'b0}, dmem[rs1_data[$clog2(MEM_SIZE)-1:0]][7:0]};
            end 
            F3_LHU : begin
              rd_port_o.data = {{16'b0}, dmem[rs1_data[$clog2(MEM_SIZE)-1:0]][15:0]};
            end 
          endcase
        OpcodeStore: ;
        OpcodeOpImm:
          case(instr_d[14:12])
            F3_ADDI : begin
              rd_port_o.data = $signed(imm_data) + $signed(rs1_data);
            end
            F3_SLTI : begin
              if ($signed(rs1_data) < $signed(imm_data)) rd_port_o.data = 32'b1;
            end
            F3_SLTIU: begin
              if (rs1_data < imm_data) rd_port_o.data = 32'b1;
            end
            F3_XORI : begin
              rd_port_o.data = rs1_data ^ imm_data;
            end
            F3_ORI  :begin
              rd_port_o.data = rs1_data | imm_data;
            end
            F3_ANDI :begin
              rd_port_o.data = rs1_data & imm_data;
            end
            F3_SLLI :
              if (instr_d[31:25] == F7_SLLI) begin
                rd_port_o.data = rs1_data << shamt_data;
              end
            F3_SRLI : begin
              if (instr_d[31:25] == F7_SRLI) begin
                rd_port_o.data = rs1_data >> shamt_data;
              end else  if (instr_d[31:25] == F7_SRAI) begin
                rd_port_o.data = rs1_data >>> shamt_data;
              end
            end
          endcase
        OpcodeOp:
          case(instr_d[14:12])
            F3_ADD :
              if (instr_d[31:25] == F7_ADD) begin
                rd_port_o.data = rs1_data + rs2_data;
              end else if (instr_d[31:25] == F7_SUB) begin
                rd_port_o.data = rs1_data - rs2_data;
              end
            F3_SLL :
              if (instr_d[31:25] == F7_SLL) begin
                rd_port_o.data = rs1_data << rs2_data;
              end
            F3_SLT :
              if (instr_d[31:25] == F7_SLT) begin
                if ($signed(rs1_data) < $signed(rs2_data))  rd_port_o.data = 32'b1;
              end
            F3_SLTU:
              if (instr_d[31:25] == F7_SLTU) begin
                if (rs1_data < rs2_data)  rd_port_o.data = 32'b1;
              end
            F3_XOR :
              if (instr_d[31:25] == F7_XOR) begin
                rd_port_o.data = rs1_data ^ rs2_data;
              end
            F3_SRL :
              if (instr_d[31:25] == F7_SRL) begin
                rd_port_o.data = rs1_data >> rs2_data;
              end else if (instr_d[31:25] == F7_SRA) begin
                rd_port_o.data = $signed(rs1_data) >>> rs2_data;
              end
            F3_OR  :
              if (instr_d[31:25] == F7_OR) begin
                rd_port_o.data = rs1_data | rs2_data;
              end
            F3_AND :
              if (instr_d[31:25] == F7_AND) begin
                rd_port_o.data = rs1_data & rs2_data;
              end
          endcase
      endcase
    end

    always_ff @(posedge clk_i) begin
      if (~rstn_i) begin
        pass
      end else begin
        mem_wrt_data_o = rs2_data;
        mem_wrt_addr_o = rs1_data + imm_data;
      end
    end

endmodule
