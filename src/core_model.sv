module core_model
  import riscv_pkg::*;
(
    input  logic  clk_i,                  // Sistem saat sinyali
    input  logic  rstn_i,                 // Aktif düşük reset sinyali
    input  logic  [XLEN-1:0] addr_i,      // Bellek adresi girişi
    output logic             update_o,    // Güncelleme sinyali çıkışı (tb için)
    output logic  [XLEN-1:0] data_o,      // Veri çıkışı
    output logic  [XLEN-1:0] pc_o,        // Program sayacı çıkışı
    output logic  [XLEN-1:0] instr_o,     // Komut çıkışı
    output logic  [     4:0] reg_addr_o,  // Kayıt dosyası adresi çıkışı
    output logic  [XLEN-1:0] reg_data_o   // Kayıt dosyası veri çıkışı
);
    //------ Update sinyalinin taşınması ------- 
    logic update_D,update_E,update_M,update_WB;

    //------------ flush ve stall sinyalleri ----
    logic            lw_stall;
    logic            stallF;
    logic            flushD;
    logic            stallD;
    logic            flushE;
    logic [XLEN-1:0] forward_a;
    logic [XLEN-1:0] forward_b;

    //------------ fetch sinyalleri -------------
    logic [XLEN-1:0] pc_F;
    logic [XLEN-1:0] instr_F;


    //------------ decode sinyalleri -------------
    logic [XLEN-1:0] pc_plus4_D;
    logic [XLEN-1:0] pc_D;
    logic [XLEN-1:0] instr_D;
    logic [XLEN-1:0] imm_data_D;
    logic [4:0]      shamt_data_D;
    logic [XLEN-1:0] rs1_data_D;
    logic [XLEN-1:0] rs2_data_D;
    logic            mem_wr_ena_D; 
    operation_e      operation_D;  
    logic            rd_wrt_ena_D; 
    logic [4:0]      rs1_addr_D; 
    logic [4:0]      rs2_addr_D; 
    logic [4:0]      rsd_addr_D; 
    logic            do_jump_D;
    logic            do_branch_D;


    //------------ execute sinyalleri -------------

    logic [XLEN-1:0] pc_plus4_E;
    logic [XLEN-1:0] pc_E;
    logic [XLEN-1:0] instr_E;
    logic [XLEN-1:0] imm_data_E;
    logic [4:0]      shamt_data_E;
    logic [XLEN-1:0] rs1_data_E;
    logic [XLEN-1:0] rs2_data_E;
    logic            mem_wr_ena_E; 
    operation_e      operation_E;  
    logic            rd_wrt_ena_E; 

    logic [4:0]      rs1_addr_E; 
    logic [4:0]      rs2_addr_E; 
    logic [4:0]      rsd_addr_E; 
    logic            do_jump_E;
    logic            do_branch_E;
    logic            pc_select_src_o_E;
    logic [XLEN-1:0] jump_pc_E; //pc in mux 1
    logic [XLEN-1:0] rd_data_E; //alu result çıkışı
    logic            rf_wr_enable_E;//register file write enable
    logic [XLEN-1:0] mem_wr_data_E;
    logic [XLEN-1:0] mem_wr_addr_E;
    logic            mem_wr_enable_E;

    //------------ memory sinyalleri -------------
    logic [XLEN-1:0] pc_plus4_M;
    operation_e      operation_M;
    logic            rd_wrt_ena_M; 
    logic [XLEN-1:0] rd_data_M;  
    logic            rf_wr_enable_M; 
    logic [XLEN-1:0] mem_wr_data_M;
    logic [XLEN-1:0] mem_wr_addr_M;
    logic            mem_wr_enable_M;
    logic [XLEN-1:0] mem_data_M;
    logic [4:0]      rsd_addr_M; 

    logic [XLEN-1:0] pc_M;
    logic [XLEN-1:0] instr_M;

    //------------ write back sinyalleri -------------
    logic            rf_wr_enable_WB;//regiser write back enable
    operation_e      operation_WB;   //writeback mux seçimi için
    logic [XLEN-1:0] pc_plus4_WB;    
    logic [XLEN-1:0] mem_data_WB;    //memory çıkışı
    logic [XLEN-1:0] rd_data_WB;     //alu çıkışı
    logic [4:0]      rsd_addr_WB;    //register destination address
    logic [XLEN-1:0] write_back_WB;
    logic            rd_wrt_ena_WB;

    logic [XLEN-1:0] pc_WB;
    logic [XLEN-1:0] instr_WB;

    // Komut geçerlilik sinyalleri
    logic valid_D, valid_E, valid_M, valid_WB;

    // Fetch aşaması
    fetch fetch_stage (
        .clk_i           (clk_i           ),
        .rstn_i          (rstn_i          ),
        .stallF          (stallF          ),
        .jump_pc_d       (jump_pc_E       ),
        .jump_pc_valid_d (pc_select_src_o_E),
        .pc_o            (pc_F            ),
        .instr_o         (instr_F         ),
        .update_o        (update_D  )
    );

    // FETCH - DECODE REGISTER
    always_ff @ (posedge clk_i or negedge rstn_i) begin
        if (~rstn_i || flushD ) begin
            pc_plus4_D  <= 'h8000_0000;
            pc_D        <= 'hFFFFFFFF; //fetch reset (wave'de görmek için)
            instr_D     <= 32'h0;  
            valid_D <= 0;
            update_D <= 0;
            
        end
        else if (!stallD) begin  // stallF yerine stallD kullan
            pc_plus4_D  <= pc_F + 4;
            pc_D        <= pc_F;
            instr_D     <= instr_F;
            valid_D <= 1;

        end
    end

    // Decode aşaması
    decode decode_stage (
        .instr_i      (instr_D),
        .clk_i        (clk_i),
        .rsd_addr_i   (rsd_addr_WB),
        .rf_wr_enable_i(rf_wr_enable_WB),
        .write_back_i (write_back_WB),

        // Forwarding inputs ekle
        .rsd_addr_M     (rsd_addr_M),
        .rd_data_M      (rd_data_M),
        .rf_wr_enable_M (rf_wr_enable_M),

        .imm_data_o   (imm_data_D),
        .shamt_data_o (shamt_data_D),
        .rs1_data_o   (rs1_data_D),
        .rs2_data_o   (rs2_data_D),
        .mem_wr_ena_o (mem_wr_ena_D),
        .operation_o  (operation_D),
        .rd_wrt_ena_o (rd_wrt_ena_D),
        .rs1_addr_o   (rs1_addr_D),
        .rs2_addr_o   (rs2_addr_D),
        .rsd_addr_o   (rsd_addr_D),
        .do_jump_o    (do_jump_D),
        .do_branch_o  (do_branch_D)
    );

    // DECODE - EXECUTE REGISTER
    always_ff @ (posedge clk_i or negedge rstn_i) begin
        if (!rstn_i || flushE ) begin
            pc_plus4_E   <= 32'h8000_0000;
            pc_E         <= 32'hDDDDDDDD; //decode reset (wave'de görmek için)
            imm_data_E   <= 32'b0;
            shamt_data_E <= 5'b0;
            rs1_data_E   <= 32'b0;
            rs2_data_E   <= 32'b0;
            mem_wr_ena_E <= 0;
            operation_E  <= UNKNOWN;
            rd_wrt_ena_E <= 0;
            rs1_addr_E   <= 0;
            rs2_addr_E   <= 0;
            rsd_addr_E   <= 0;
            do_jump_E    <= 0;   
            do_branch_E  <= 0;
            valid_E <= 0;
            //instr_E <= 32'h00000000; // NOP
            update_E <= 0;
            
        end
        else if (!stallD) begin
            pc_plus4_E   <= pc_plus4_D; 
            imm_data_E   <= imm_data_D;
            shamt_data_E <= shamt_data_D;
            rs1_data_E   <= rs1_data_D;
            rs2_data_E   <= rs2_data_D;
            mem_wr_ena_E <= mem_wr_ena_D;
            operation_E  <= operation_D;
            rd_wrt_ena_E <= rd_wrt_ena_D;
            
            rs1_addr_E   <= rs1_addr_D;
            rs2_addr_E   <= rs2_addr_D;
            rsd_addr_E   <= rsd_addr_D;
            do_jump_E    <= do_jump_D;   
            do_branch_E  <= do_branch_D;
            pc_E         <= pc_D;
            instr_E <= instr_D;
            valid_E <= valid_D;  // Valid sinyali düzeltildi
            update_E <= update_D;
        end
    end

    // Execute aşaması
    execute execute_stage (
        .pc_i            (pc_E),
        .rs1_data_i      (forward_a), //forward yapılmalı !!!!!!!!!!
        .rs2_data_i      (forward_b), //forward yapılmalı !!!!!!!!!!
        .imm_data_i      (imm_data_E),
        .shamt_data_i    (shamt_data_E),
        .do_jump_i        (do_jump_E),
        .do_branch_i      (do_branch_E),

        .pc_select_src_o  (pc_select_src_o_E),
        .jump_pc_o        (jump_pc_E),

        .rd_data_o        (rd_data_E),
        .rf_wr_enable_o   (rf_wr_enable_E),
        .mem_wr_data_o    (mem_wr_data_E),
        .mem_wr_addr_o    (mem_wr_addr_E),
        .mem_wr_enable_o  (mem_wr_enable_E),
        .operation_i      (operation_E)
    );



    // EXECUTE - MEMORY  REGISTER
    always_ff @ (posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            pc_plus4_M      <= 'h8000_0000; 
            operation_M     <= UNKNOWN;
            pc_M <= 32'hEEEEEEEE;
            rd_wrt_ena_M    <= 0;
            rd_data_M       <= 0;
            rf_wr_enable_M  <= 0;
            mem_wr_data_M   <= 0;
            mem_wr_addr_M   <= 0;
            mem_wr_enable_M <= 0;
            rsd_addr_M      <= 0;
            rsd_addr_WB     <=0 ;
            valid_M <= 0;
            instr_M <= 32'h00000000; // NOP
            update_M <= 0;
        end
        else begin
            pc_plus4_M      <= pc_plus4_E;
            operation_M     <= operation_E;
            rd_wrt_ena_M    <= rd_wrt_ena_E;
            rd_data_M       <= rd_data_E;
            rf_wr_enable_M  <= rf_wr_enable_E;
            mem_wr_data_M   <= mem_wr_data_E;
            mem_wr_addr_M   <= mem_wr_addr_E;
            mem_wr_enable_M <= mem_wr_enable_E;
            rsd_addr_M      <= rsd_addr_E; 
            pc_M         <= pc_E;
            instr_M <= instr_E;
            valid_M <= valid_E;
            update_M <= update_E;
        end
    end

    // Memory aşaması
    memory memory_stage (
       .clk_i(clk_i),
       .rstn_i(rstn_i),
       .mem_wr_data_i(mem_wr_data_M),
       .mem_wr_addr_i(mem_wr_addr_M),
       .mem_wr_enable_i(mem_wr_enable_M),
       .operation_i(operation_M),
       .mem_data_o(mem_data_M) ,
              .debug_addr(addr_i),
       .debug_data(data_o)
    );




        // MEMORY - WRITEBACK  REGISTER
    always_ff @ (posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            rf_wr_enable_WB <= 0;
            operation_WB    <= UNKNOWN;
            pc_WB <= 32'h0000000;
            pc_plus4_WB     <= 0;
            mem_data_WB     <= 0;
            rd_data_WB      <= 0;
            rsd_addr_WB     <= 0;
            valid_WB <= 0;
            instr_WB <= 32'h00;
            update_WB <= 0;
            rd_wrt_ena_WB<=0;
        end
        else begin
            rf_wr_enable_WB <= rf_wr_enable_M;
            operation_WB    <= operation_M;
            pc_plus4_WB     <= pc_plus4_M;
            mem_data_WB     <= mem_data_M;
            rd_data_WB      <= rd_data_M;
            rsd_addr_WB     <= rsd_addr_M;
            pc_WB    <= pc_M;
            instr_WB <= instr_M;
            valid_WB <= valid_M; 
            update_WB <= update_M;
            rd_wrt_ena_WB <= rd_wrt_ena_M;


        end
    end




    // Writeback aşaması
    writeback writeback_stage (
        .operation_i (operation_WB),
        .pc_plus4_i  (pc_plus4_WB),
        .rd_data_i   (rd_data_WB),
        .mem_data_i  (mem_data_WB),
        .write_back_o (write_back_WB)
    );

    //log sinyallerinin atanması
    assign pc_o = pc_WB;
    assign instr_o = instr_WB;
    assign data_o = mem_data_WB;
    assign reg_addr_o =   rd_wrt_ena_WB ? rsd_addr_WB : 0;
    assign reg_data_o = rd_data_WB;

    //stabil log için gerekli olan delay
    logic update_o_reg;

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            update_o_reg <= 0;
        end else begin
            update_o_reg <= update_WB;
        end
    end

    assign update_o = (update_o_reg || operation_WB != UNKNOWN) && valid_WB;


    always_comb begin : hazard_unit
        // default değerler
        stallF = 0;
        flushD = 0;
        stallD = 0;
        flushE = 0;
        forward_a = rs1_data_E;
        forward_b = rs2_data_E;
        lw_stall = 0;

        // === LW USE STALL kontrolü ===
        lw_stall = ((rs1_addr_D == rsd_addr_E) || (rs2_addr_D == rsd_addr_E)) &&
                (rf_wr_enable_E) &&
                (operation_E inside {LW, LB, LH, LBU, LHU});

        if (lw_stall) begin
            stallF = 1;
            stallD = 1;
            flushE = 1;
        end

        // === Control Hazard (branch/jump alınmışsa) ===
        if (pc_select_src_o_E) begin
            flushD = 1;
            flushE = 1;
        end

        // Forwarding logic
        if ((rs1_addr_E != 0) && (rs1_addr_E == rsd_addr_M) && rf_wr_enable_M)
            forward_a = rd_data_M;
        else if ((rs1_addr_E != 0) && (rs1_addr_E == rsd_addr_WB) && rf_wr_enable_WB)
            forward_a = write_back_WB;
        else
            forward_a = rs1_data_E;

        if ((rs2_addr_E != 0) && (rs2_addr_E == rsd_addr_M) && rf_wr_enable_M)
            forward_b = rd_data_M;
        else if ((rs2_addr_E != 0) && (rs2_addr_E == rsd_addr_WB) && rf_wr_enable_WB)
            forward_b = write_back_WB;
        else
            forward_b = rs2_data_E;
    end


endmodule
