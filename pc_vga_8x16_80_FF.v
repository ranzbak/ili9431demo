`timescale 1ns / 1ps
`default_nettype none
module pc_vga_8x16_80_FF (
    input  clk,
    input  [6:0] ascii_code,
    input  [3:0] row,
    input  [2:0]  col,
    output reg row_of_pixels
);
    // 2D array 8-bit offset, 6-bit index
    reg [0:255] BRAM_PC_VGA_0 [0:63];

    // Initialize the high character ROM
    // For convenience a hex file is usued 
    initial begin
        $readmemh("./VGA_8x16_80_FF.mem", BRAM_PC_VGA_0);
    end

    // Retrieve the correct pixel value from ROM
    always @(posedge clk) begin
        row_of_pixels <= BRAM_PC_VGA_0[ascii_code[6:1]][{ ascii_code[0], row, ~col}];
    end

endmodule
