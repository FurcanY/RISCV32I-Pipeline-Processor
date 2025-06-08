module fetch
  import riscv_pkg::*;
(
    input  logic clk_i,
    input  logic rstn_i,
    input  logic stallF, //hazard unit'den gelen durdurma komutu
    input  logic [XLEN-1:0] jump_pc_d, //atlanacak veri mux select 1 de olan
    input  logic            jump_pc_valid_d,
    output logic [XLEN-1:0] pc_o,
    output logic [XLEN-1:0] instr_o,
    output logic            update_o
);
    // Bellek parametreleri
    parameter int MEM_SIZE = 2048;
    logic [31:0] imem [MEM_SIZE-1:0];  // Komut belleği

    // Komut belleğini başlat
    initial $readmemh("./test/test.hex", imem);

    // Program sayacı sinyalleri
    logic [XLEN-1:0] pc_d;
    logic [XLEN-1:0] pc_q;

    // Program sayacı güncelleme
    always_ff @(posedge clk_i or negedge rstn_i) begin : pc_change_ff
        if (~rstn_i) begin
            pc_q <= 'h8000_0000;           // Reset durumunda PC'yi başlangıç adresine ayarla
            update_o <= 0;
        end else if (!stallF) begin
            update_o <= 1;
            pc_q <= pc_d;                  // Normal durumda PC'yi güncelle
        end
    end

    // Program sayacı hesaplama MUX
    always_comb begin
        if (jump_pc_valid_d) begin
            pc_d = jump_pc_d;
            instr_o = imem[jump_pc_d[$clog2(MEM_SIZE*4)-1:2]]; // <-- BRANCH Hedefinden oku!
        end else begin
            pc_d = pc_q + 4;
            instr_o = imem[pc_q[$clog2(MEM_SIZE*4)-1:2]];
        end
    end



    // Çıkış atamaları
    assign pc_o = pc_q;

endmodule
