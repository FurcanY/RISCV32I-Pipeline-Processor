module tb 
    import riscv_pkg::*;
();
    logic [XLEN-1:0] addr;
    logic [XLEN-1:0] data;
    logic [XLEN-1:0] pc;
    logic [XLEN-1:0] instr;
    logic [     4:0] reg_addr;
    logic [XLEN-1:0] reg_data;
    logic            update;
    logic clk;
    logic rstn;

    core_model i_core_model(
        .clk_i(clk),
        .rstn_i(rstn),
        .addr_i(addr),
        .update_o(update),
        .data_o(data),
        .pc_o(pc),
        .instr_o(instr),
        .reg_addr_o(reg_addr),
        .reg_data_o(reg_data)
    );

    integer file_pointer;
    initial begin
        file_pointer = $fopen("./test/model.log", "w");
        #4
        forever begin
            if (update) begin
                
                if (reg_addr == 0) begin
                    $fdisplay(file_pointer, "0x%8h (0x%8h)", pc, instr);
                end 

                else begin
                    if (reg_addr>9) begin
                        $fdisplay(file_pointer, "0x%8h (0x%8h) x%0d 0x%8h", pc, instr, reg_addr, reg_data);
                    end else begin
                        $fdisplay(file_pointer, "0x%8h (0x%8h) x%0d  0x%8h", pc, instr, reg_addr, reg_data);
                    end
                end
            end
            #2; //bu senkronizasyon beklemesini eklemeseydim, sinyalim ne olursa olsun hep log basıyordu. (sinyalim 0 olsun yine log basıyordu. sinyallerim doğru oluşuyor log yanlış oluyor yoksa)
        end
    end

    initial forever begin
        clk = 0;
        #1;
        clk = 1;
        #1;
    end

    initial begin
        rstn = 0;
        #4;
        rstn = 1;
        #4000;
        for (int i=0; i<10; i++) begin
            addr = i;
            $display("data @ mem[0x%8h] = %8h", addr, data);
        end
        $finish;
    end
        
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars();
    end
    
endmodule
