
module init_delay #(
    parameter CNT_BITS = 9
) (
    input clk, // 16Mhz input +-
    input rst, // Active high
    output reg done = 1'b0 // Goes high when done
);

    reg low_stb;
    reg ck_stb;
    reg [(CNT_BITS-1):0] low_counter, hi_counter; // 2x 9 bit counter for a delay of +- 10ms 

    // Split counter to have a 10ms wait before starting with the ili9341
    always @(posedge clk)
    if (rst) begin
        low_counter <= 0;
        low_stb <= 1'b0;
    end else begin
        { low_stb, low_counter } <= low_counter + 1'b1;
    end
    always @(posedge clk)
    if (rst) begin
        hi_counter <= 0;
        ck_stb <= 1'b0;
    end else begin
        if (low_stb)
            { ck_stb, hi_counter } <= hi_counter + 1'b1;
        else
            ck_stb <= 1'b0;
    end

    // Delay output
    always @(posedge clk) begin
        if (rst) begin
            done <= 1'b0;
        end

        // Fire once
        if (ck_stb == 1'b1) begin
            done <= 1'b1;
        end
    end

endmodule