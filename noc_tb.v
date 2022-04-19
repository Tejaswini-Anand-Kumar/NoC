`include "noc.v"
 

module noc_tb;
parameter PACKET_SIZE = 8;
parameter NUM_ROUTERS = 4;
reg clk;
reg rst;

reg [PACKET_SIZE*NUM_ROUTERS-1:0]host_data_in;
reg [NUM_ROUTERS-1:0]host_en;
wire [PACKET_SIZE*NUM_ROUTERS-1:0]host_data_out;

noc n1 (.clk(clk), .rst(rst),.host_data_in(host_data_in), .host_en(host_en), .host_data_out(host_data_out));
always begin
    #1 clk = ~clk;
end
initial begin
    $dumpfile("waveform.vcd");
    $dumpvars;

    clk <= 1;
    rst <= 1;
    #2 rst <= 0; host_data_in <= 32'b1001; host_en <= 4'b1; //1 to 3
   // #2 left_in <= 8'bz; left_en <= 1'bz;
   // #6 left_in <= 8'b111; left_en <= 1'b1;
    #4 host_data_in <= 32'bz; host_en <= 4'bz;
    
    #40 $stop;
    end

endmodule
