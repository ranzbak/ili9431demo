module top (
  output led_green,
  output gpio_46,
  input gpio_20,

  output gpio_23,
  output gpio_25,
  output gpio_26,
  output gpio_27,
  output gpio_32,
  output gpio_35,
  output gpio_31,
  output gpio_37,

  output gpio_34,
  output gpio_43,
  output gpio_36,
  output gpio_48,
  output gpio_47
);

  wire clk;
  wire locked; // High when the PLL has locked

  // Reset 
  reg r_rst = 1'b1; // Active high

  // ILI9341 interface
  wire [7:0] DBOUT; // Data byte out
  reg        ALED; // Backlight PWD, active high
  reg        GLED; // Backlight PWD, active high
  reg         CS_ = 1'b1; // Chip select, active low
  wire        REST_ = 1'b1; // Reset control pin active low
  wire        RS; // Register/Data. This is LOW/0 for the command byte, HIGH/1 for parameters and pixel data.
  wire        WR_; // Write strobe.  The TFT will latch data pins on a rising edge (LOW/0 to HIGH/1) 
  wire        RD_; // Read strobe. The TFT will start setting up the data pins on a falling edge (HIGH/1 to LOW/0)


  reg [20:0] delay = 0;

  // Backlight control + PLL lock LED
  always @(posedge clk) begin
    delay <= delay + 1;
    ALED <= delay[8];
    GLED <= delay[8] | locked; // blink LED Green until stable clock
  end

  reg [9:0] r_rst_count = 0;
  always @(posedge clk) begin
    if (locked) begin
      r_rst_count <= r_rst_count + 1;
    end
    if (r_rst_count == 10'h3ff) begin
      r_rst <= 1'b0;
      CS_ <= 1'b0;
    end
  end

  // Clock generator
  pll mypll(
    .clock_in(gpio_20),
    .clock_out(clk),
    .locked(locked)
  );

  // 12 MHz clock
  // assign clk = gpio_20;


  // Display module
  // ili9341 my_ili9341(
  //   .clk(clk),
  //   .rst(r_rst),
  //   .dbout(DBOUT),
  //   .cs(CS),
  //   .rest(REST_),
  //   .rs(RS),
  //   .wr(WR),
  //   .rd(RD)
  // );

  lcd my_lcd(
    .i_clk(clk),
    .i_reset(r_rst),
    .o_lcd_data(DBOUT),
    .o_lcd_rs(RS),
    .o_lcd_wr(WR_),
    .i_lcd_fmark()
  );

  assign gpio_46 = 1'b1;
  assign led_green = GLED;

  // Parralel data out display
  assign gpio_23 = DBOUT[0];
  assign gpio_25 = DBOUT[1];
  assign gpio_26 = DBOUT[2];
  assign gpio_27 = DBOUT[3];
  assign gpio_32 = DBOUT[4];
  assign gpio_35 = DBOUT[5];
  assign gpio_31 = DBOUT[6];
  assign gpio_37 = DBOUT[7];
  // Control signals
  assign gpio_34 = RS;
  assign gpio_43 = WR_;
  assign gpio_36 = 1'b1; // RD
  assign gpio_48 = CS_; // CS Chip select
  assign gpio_47 = REST_; // REST

endmodule