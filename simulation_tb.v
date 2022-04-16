`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 1 ns / 1 ns

module simulation_tb;
    // Generate the clock
    reg r_clk;

    reg        r_rst;
    wire [7:0] dbout;
    wire       cs;
    wire       rest;
    wire       rs;
    wire       wr;
    wire       rd;
    wire       aled;

    // clock_gen clock_gen_sim (
    //     .enable(1'b1),
    //     .clk(r_clk)
    // );

    initial begin
        r_clk = 1'b0;
    end

    always begin
        #5 r_clk = !r_clk;
    end



    initial begin
        $timeformat(3, 2, " ns", 20);
    end

    reg [9:0] r_count;

    initial begin
        r_rst = 1'b1;
        r_count = 0;
    end

    always @(posedge r_clk) begin
        r_count <= r_count + 1;

        if (r_count == 'h10) begin
            r_rst <= 1'b0;
        end
    end

    // LCD test string
    reg [7:0] r_lcd_test_string [0:40];
    initial begin
        r_lcd_test_string[0] = "a";
        r_lcd_test_string[1] = "b";
        r_lcd_test_string[2] = "c";
        r_lcd_test_string[3] = "d";
        r_lcd_test_string[4] = "e";
        r_lcd_test_string[5] = "f";
        r_lcd_test_string[6] = "g";
        r_lcd_test_string[7] = "h";
        r_lcd_test_string[8] = "i";
        r_lcd_test_string[9] = "j";
        r_lcd_test_string[10] = "k";
        r_lcd_test_string[11] = "l";
        r_lcd_test_string[12] = "m";
        r_lcd_test_string[13] = "n";
        r_lcd_test_string[14] = "o";
        r_lcd_test_string[15] = "p";
        r_lcd_test_string[15] = "q";
    end

    // Character ROM
    wire [8:0] pos_x;
    wire [7:0] pos_y;
    wire [2:0] char_col = 0;
    wire [3:0] char_row = 0;
    wire [7:0] char_ascii = 0;
    wire       pixel;
    pc_vga_8x16 my_char_rom (
        .clk(r_clk),
        .col(pos_x[2:0]),
        .row(pos_y[3:0]),
        .ascii(r_lcd_test_string[pos_x[8:3]]),
        .pixel(pixel)
    );

    // LCD code
    lcd my_lcd(
        .i_clk(r_clk),
        .i_reset(r_rst),
        .o_lcd_data(dbout),
        .o_lcd_rs(rs),
        .o_lcd_wr(wr),
        .i_pixel_data(pixel ? 16'hffff : 16'h0000),
        .o_pixel_x(pos_x),
        .o_pixel_y(pos_y),
        .i_lcd_fmark()
    );

    // Print character start
    // always @(posedge r_clk) begin
    //     if (r_pixel_p_x != pixel_x && pixel_x < 128) begin
    //         if (pixel_x[2:0] == 0) begin
    //             $write(":");
    //             p_x = 1'b1;
    //         end
    //     end
    // end

    // Print the output in pixels to the terminal
    reg [8:0] r_pos_p_x;
    reg [7:0] r_pos_p_y;
    reg       p_x = 0;
    reg       p_y = 0;
    always @(posedge r_clk) begin
        p_x <= 1'b0;
        p_y <= 1'b0;
        r_pos_p_x <= pos_x;
        r_pos_p_y <= pos_y;

        if (r_pos_p_x != pos_x) begin
            p_x <= 1'b1;
        end

        if (pos_x[2:0] == 3'b000 && p_x) begin
            $write("|");
        end

        if (p_x && pos_x < 128) begin

            if (pixel) begin
                $write("#");
            end else begin
                $write(" ");
            end
        end

        if (r_pos_p_y != pos_y) begin
            $write("||\n");
            p_y <= 1'b1;
            if (pos_y[3:0] == 0) begin
                $write("------------------------------------------------------------------------------\n");
            end
        end

    end

    initial begin
        $dumpfile(`DUMPSTR(`VCD_OUTPUT)); // Dump the VCD file 
        $dumpvars(0, simulation_tb);

        $display("Simulation started");
        repeat (40000) @(posedge r_clk);
        // End the simulation when we reach stage
        // if (ili9341sim.stateonehot[2] == 1'b1 || r_count == 'hFF) begin
        $display("Simulation finished");
        $finish;
        // end
    end
endmodule
