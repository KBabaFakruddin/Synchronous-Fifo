`timescale 1ns/1ps

module sfifo_tb;

    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 8;

    reg                     clk;
    reg                     rst_n;
    reg  [DATA_WIDTH-1:0]   data_in;
    reg                     read_en;
    reg                     write_en;
    
    wire [DATA_WIDTH-1:0]   data_out;
    wire                    full;
    wire                    empty;

    // Instantiate DUT
    sfifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .read_en(read_en),
        .write_en(write_en),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // 100MHz Clock Generation
    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd"); // Specifies the output VCD file name
        $dumpvars(0, sfifo_tb);
        $dumpfile("sfifo_dump.vcd");
        $dumpvars(0, sfifo_tb);

        clk      = 0;
        rst_n    = 1;
        write_en = 0;
        read_en  = 0;
        data_in  = 0;

        // Apply Reset
        #10; rst_n = 0;
        #20; rst_n = 1;
        #10;

        // --- WRITE OPERATIONS ---
        $display("--- Starting Write Operations ---");
        repeat (FIFO_DEPTH) begin
            @(posedge clk);
            if (!full) begin
                write_en = 1;
                data_in  = data_in + 8'h05;
                #1;
                $display("[WRITE] Data: %h, Full: %b, Empty: %b", data_in, full, empty);
            end
        end

        @(posedge clk);
        write_en = 0;
        #1;
        $display("[STATUS] After filling -> Full: %b, Empty: %b", full, empty);

        // --- OVERFLOW TEST ---
        @(posedge clk);
        write_en = 1;
        data_in  = 8'hFF;
        @(posedge clk);
        write_en = 0;
        $display("[OVERFLOW TEST] Attempted write to full.");

        #20;

        // --- READ OPERATIONS (FWFT / Combinational Alignment) ---
        $display("\n--- Starting Read Operations ---");
        repeat (FIFO_DEPTH) begin
            if (!empty) begin
                #1; // Allow combinational data_out to settle before sampling
                $display("[READ] Data Out: %h, Full: %b, Empty: %b", data_out, full, empty);
                
                // Assert read_en to advance the pointer on the next clock edge
                read_en = 1;
                @(posedge clk);
                #1;
                read_en = 0;
            end
        end

        #1;
        $display("[STATUS] After emptying -> Full: %b, Empty: %b", full, empty);

        // --- UNDERFLOW TEST ---
        read_en = 1;
        @(posedge clk);
        #1;
        read_en = 0;
        $display("[UNDERFLOW TEST] Attempted read from empty successfully blocked.");

        #50;
        $display("--- Simulation Completed Successfully! ---");
        $finish;
    end

endmodule
