module sfifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8
)(
    input clk,
    input rst_n,
    input wire [7:0] data_in,
    input wire read_en,
    input wire write_en,
    output wire [7:0] data_out,
    output wire full,
    output wire empty
);

    localparam PTR_WIDTH = $clog2(FIFO_DEPTH) + 1;

    reg [DATA_WIDTH-1:0] fifo_ram [0:FIFO_DEPTH-1];
    reg [PTR_WIDTH-1:0]  wrt_ptr;
    reg [PTR_WIDTH-1:0]  rd_ptr; 

    // Write Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wrt_ptr <= 0;
        end else if (write_en && !full) begin
            fifo_ram[wrt_ptr[PTR_WIDTH-2:0]] <= data_in;
            wrt_ptr <= wrt_ptr + 1;
        end
    end

    // Read Pointer Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 0;
        end else if (read_en && !empty) begin
            rd_ptr <= rd_ptr + 1;
        end
    end

    // Combinational Output (FWFT)
    assign data_out = fifo_ram[rd_ptr[PTR_WIDTH-2:0]];

    // Flags
    assign empty = (rd_ptr == wrt_ptr);   
    assign full  = (wrt_ptr[PTR_WIDTH-1] != rd_ptr[PTR_WIDTH-1]) && 
                   (wrt_ptr[PTR_WIDTH-2:0] == rd_ptr[PTR_WIDTH-2:0]);

endmodule