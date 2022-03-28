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

    // ili9341 #(

    // ) ili9341sim (
    //     .clk(r_clk),
    //     .rst(r_rst),
    //     .dbout(dbout),
    //     .cs(cs),
    //     .rest(rest),
    //     .rs(rs),
    //     .wr(wr),
    //     .rd(rd)
    // );

    lcd my_lcd(
        .i_clk(r_clk),
        .i_reset(r_rst),
        .o_lcd_data(dbout),
        .o_lcd_rs(rs),
        .o_lcd_wr(wr),
        .i_lcd_fmark()
    );


    initial begin
        $dumpfile(`DUMPSTR(`VCD_OUTPUT)); // Dump the VCD file
        $dumpvars(0, simulation_tb);

        $display("Simulation started");
        repeat (10000) @(posedge r_clk);
        // End the simulation when we reach stage
        // if (ili9341sim.stateonehot[2] == 1'b1 || r_count == 'hFF) begin
        $display("Simulation finished");
        $finish;
        // end
    end
endmodule
