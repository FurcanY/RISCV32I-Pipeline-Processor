module tb ();
    logic a,b,c;
    test_xor i_test_xor (
        .a(a),
        .b(b),
        .c(c)
    );
    initial begin

        a = 0;
        b = 0;
        #1  a = 1;  b = 0;
        #1  a = 1;  b = 1;
        #1  a = 0;  b = 1;
        #1  a = 0;  b = 'x; // those are not properly supported yet
        #1  a = 1;  b = 'x; // those are not properly supported yet
        #1  a = 1;  b = 'z; // those are not properly supported yet
        #1  a = 0;  b = 'z; // those are not properly supported yet
        #1;
        
        $finish;
    end

        
   initial begin
      $dumpfile("dump.vcd");
      $dumpvars();
   end
    
endmodule
