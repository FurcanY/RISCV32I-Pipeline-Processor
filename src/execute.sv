module execute
  import riscv_pkg::*;
(
    input  operation_e operation_i,
    //bunlar alu giriş muxlanan kısım aslında
    input logic [XLEN-1:0] pc_i,       //pc in 
    input logic [XLEN-1:0] rs1_data_i, //alu a in //forward ile dışardan değiştirilmeli
    input logic [XLEN-1:0] rs2_data_i, //alu b in //forward ile dışardan değiştirilmeli
    input logic [XLEN-1:0] imm_data_i, //immediate in
    input logic [4:0]      shamt_data_i,
    input logic             do_jump_i,    
    input logic             do_branch_i,  

    output logic            pc_select_src_o, //pc select source (MUX) //mem registera geçirilmez
    output logic [XLEN-1:0] jump_pc_o, //pc in mux 1 //mem registera geçirilmez

    output logic [XLEN-1:0] rd_data_o,  //alu restult çıkışı write back aşamasında yazılacak
    output logic            rf_wr_enable_o, //register file write enable

    output logic [XLEN-1:0] mem_wr_data_o, //memory işlemleri
    output logic [XLEN-1:0] mem_wr_addr_o,
    output logic            mem_wr_enable_o
);
    logic            jump_pc_valid; //jump ve branc yapabilir

    assign pc_select_src_o = (do_branch_i & jump_pc_valid) | do_jump_i; //pc select kısmı

    // Execute işlemi
    always_comb begin : execute_block
        // Tüm çıkış sinyallerini sıfırla
        jump_pc_valid = 0;
        jump_pc_o = 0;
        rd_data_o = 0;
        rf_wr_enable_o = 0;
        mem_wr_enable_o = 0;
        mem_wr_data_o = 0;
        mem_wr_addr_o = 0;

        case (operation_i) 
            LUI    : begin
                rd_data_o = imm_data_i;          // LUI komutu için sabit değeri hedef kayda yaz
                rf_wr_enable_o = 1'b1;
            end
            AUIPC  : begin
                rd_data_o = imm_data_i + pc_i;   // AUIPC komutu için PC + sabit değer
                rf_wr_enable_o = 1'b1;
            end
            JAL    : begin
                jump_pc_valid = 1'b1;
                jump_pc_o = imm_data_i + pc_i;   // JAL komutu için atlama adresi
                rd_data_o = pc_i + 4;            // Dönüş adresi wb aşamasında kullanılmalı
                rf_wr_enable_o = 1'b1;
            end
            JALR   : begin
                jump_pc_valid = 1'b1;
                jump_pc_o = imm_data_i + rs1_data_i; // JALR komutu için atlama adresi
                rd_data_o = pc_i + 4;                 // Dönüş adresi wb aşamasında kullanılmalı
                rf_wr_enable_o = 1'b1;
            end
            BEQ    : begin
                if (rs1_data_i == rs2_data_i) begin
                    jump_pc_o = imm_data_i + pc_i;
                    jump_pc_valid = 1'b1;
                end 
            end
            BNE    : begin
                if (rs1_data_i != rs2_data_i) begin
                    jump_pc_o = imm_data_i + pc_i;
                    jump_pc_valid = 1'b1;
                end
            end
            BLT    : begin
                if ($signed(rs1_data_i) < $signed(rs2_data_i)) begin
                    jump_pc_o = imm_data_i + pc_i;
                    jump_pc_valid = 1'b1;
                end 
            end
            BGE    : begin
                if ($signed(rs1_data_i) >= $signed(rs2_data_i)) begin
                        jump_pc_o = imm_data_i + pc_i;
                        jump_pc_valid = 1'b1;
                end 
            end
            BLTU   : begin
                if (rs1_data_i < rs2_data_i) begin
                    jump_pc_o = imm_data_i + pc_i;
                    jump_pc_valid = 1'b1;
                end 
            end
            BGEU   : begin
                if (rs1_data_i >= rs2_data_i) begin
                    jump_pc_o = imm_data_i + pc_i;
                    jump_pc_valid = 1'b1;
                end
            end
            LB, LH, LW, LBU, LHU : begin
                 mem_wr_addr_o = rs1_data_i + imm_data_i; // Yükleme adresi //bu operation memory'ye aktarılır
                rf_wr_enable_o = 1'b1;
            end
            SB,SH,SW: begin
                mem_wr_enable_o = 1'b1;  //bu operation memory'ye aktarılır
                mem_wr_data_o = rs2_data_i; //memory'ye geri yazılacak değer
                mem_wr_addr_o = rs1_data_i + imm_data_i;
            end

            ADDI   : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = $signed(imm_data_i) + $signed(rs1_data_i);
            end
            SLTI   : begin
                rf_wr_enable_o = 1'b1;
                if ($signed(rs1_data_i) < $signed(imm_data_i)) rd_data_o = 32'b1;
            end

            SLTIU  : begin
                rf_wr_enable_o = 1'b1;
                if (rs1_data_i < imm_data_i) rd_data_o = 32'b1;
            end
            XORI   : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = rs1_data_i ^ imm_data_i;
            end
            ORI    : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = rs1_data_i | imm_data_i;
            end
            ANDI   : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = rs1_data_i & imm_data_i;
            end
            SLLI   : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = rs1_data_i << shamt_data_i;
            end
            SRLI   : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = rs1_data_i >> shamt_data_i;
            end
            SRAI   : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = rs1_data_i >>> shamt_data_i;
            end

            ADD    : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = rs1_data_i + rs2_data_i;
            end
            SUB    : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = rs1_data_i - rs2_data_i;
            end
            SLL    : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = rs1_data_i << rs2_data_i[4:0];
            end
            SLT    : begin
                rf_wr_enable_o = 1'b1;
                if ($signed(rs1_data_i) < $signed(rs2_data_i)) rd_data_o = 32'b1;
            end
            SLTU   : begin
                rf_wr_enable_o = 1'b1;
                if (rs1_data_i < rs2_data_i) rd_data_o = 32'b1;
            end
            XOR    : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = rs1_data_i ^ rs2_data_i;
            end
            SRL    : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = rs1_data_i >> rs2_data_i[4:0];
            end
            SRA    : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = $signed(rs1_data_i) >>> rs2_data_i[4:0];
            end
            OR     : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = rs1_data_i | rs2_data_i;
            end
            AND    : begin
                rf_wr_enable_o = 1'b1;
                rd_data_o = rs1_data_i & rs2_data_i;
            end
            CTZ:begin
                for (int i = 0; i < XLEN; i++) begin
                    if (rs1_data_i[i] == 1'b0)
                        rd_data_o++;
                    else
                        break;
                end
                rf_wr_enable_o = 1'b1;
            end
            CLZ:begin
                for (int i = XLEN-1; i >= 0; i--) begin
                    if (rs1_data_i[i] == 1'b0)
                        rd_data_o++;
                    else
                        break;
                end
                rf_wr_enable_o = 1'b1;
            end
            CPOP:begin 
                for (int i = 0; i < XLEN; i++) begin
                    if (rs1_data_i[i])
                        rd_data_o++;
                end
                rf_wr_enable_o = 1'b1;
            end

            UNKNOWN: begin
            // Tüm çıkışları temizle
            jump_pc_valid = 0;
            jump_pc_o = 0;
            rd_data_o = 0;
            rf_wr_enable_o = 0;
            mem_wr_enable_o = 0;
            mem_wr_data_o = 0;
            mem_wr_addr_o = 0;
        end

        endcase
    end

endmodule
