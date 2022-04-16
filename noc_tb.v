`include "noc.v"
 

module noc_tb;
parameter PACKET_SIZE = 8;
reg clk;
reg rst;
reg [PACKET_SIZE-1:0]left_in;
reg left_en;

reg [PACKET_SIZE-1:0]right_in;
reg right_en;

noc n1 (.clk(clk), .rst(rst),.left_in(left_in), .left_en(left_en), .right_in(right_in), .right_en(right_en));
always begin
    #1 clk = ~clk;
end
initial begin
    $dumpfile("waveform.vcd");
    $dumpvars;

    clk <= 1;
    rst <= 1;
    #2 rst <= 0; left_in <= 8'b11; left_en <= 1'b1;
    #2 left_in <= 8'bz; left_en <= 1'bz;
    #6 left_in <= 8'b111; left_en <= 1'b1;
    #2 left_in <= 8'bz; left_en <= 1'bz;
    
    #40 $stop;
    end

endmodule
