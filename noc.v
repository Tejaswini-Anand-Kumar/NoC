`include "router.v"
module noc #(
    parameter PACKET_SIZE = 8,
    parameter NUM_ROUTERS = 4,
    parameter ROUTER_BITS = 2
    ) (
    input clk,
    input rst,
    input [PACKET_SIZE*NUM_ROUTERS-1:0]host_data_in,
    input [NUM_ROUTERS-1:0]host_en,
    output [PACKET_SIZE*NUM_ROUTERS-1:0]host_data_out
    );

wire left_out_buffer_full[NUM_ROUTERS-1:0];
wire [PACKET_SIZE-1:0]left_data_out[NUM_ROUTERS-1:0];
wire left_enable_out[NUM_ROUTERS-1:0];

wire right_out_buffer_full[NUM_ROUTERS-1:0];
wire [PACKET_SIZE-1:0]right_data_out[NUM_ROUTERS-1:0];
wire right_enable_out[NUM_ROUTERS-1:0];


router #(
    .ROUTER_ID(0)
    ) r(
    .clk(clk),
    .rst(rst),
    .left_data_in(right_data_out[NUM_ROUTERS-1]),
    .left_enable_in(right_enable_out[NUM_ROUTERS-1]),
    .left_in_buffer_full(right_out_buffer_full[NUM_ROUTERS-1]),
    .left_out_buffer_full(left_out_buffer_full[0]),
    .left_data_out(left_data_out[0]),
    .left_enable_out(left_enable_out[0]),

    .right_data_in(left_data_out[1]),
    .right_enable_in(left_enable_out[1]),
    .right_in_buffer_full(left_out_buffer_full[1]),
    .right_out_buffer_full(right_out_buffer_full[0]),
    .right_data_out(right_data_out[0]),
    .right_enable_out(right_enable_out[0]),

    .host_data_in(host_data_in[PACKET_SIZE-1:0]),
    .host_data_out(host_data_out[PACKET_SIZE-1:0]),
    .host_enable_in(host_en[0]));
   
for (genvar i = 1; i < NUM_ROUTERS-1; i=i+1) begin

    router #(
    .ROUTER_ID(i)
    ) r1(
    .clk(clk),
    .rst(rst),


    .left_data_in(right_data_out[i-1]),
    .left_enable_in(right_enable_out[i-1]),
    .left_in_buffer_full(right_out_buffer_full[i-1]),
    .left_out_buffer_full(left_out_buffer_full[i]),
    .left_data_out(left_data_out[i]),
    .left_enable_out(left_enable_out[i]),

    .right_data_in(left_data_out[i+1]),
    .right_enable_in(left_enable_out[i+1]),
    .right_in_buffer_full(left_out_buffer_full[i+1]),
    .right_out_buffer_full(right_out_buffer_full[i]),
    .right_data_out(right_data_out[i]),
    .right_enable_out(right_enable_out[i]),

    .host_data_in(host_data_in[(PACKET_SIZE*(i+1)-1):PACKET_SIZE*(i)]),
    .host_data_out(host_data_out[(PACKET_SIZE*(i+1)-1):PACKET_SIZE*(i)]),
    .host_enable_in(host_en[i]));
end

router #(
    .ROUTER_ID(NUM_ROUTERS-1)
    ) r2(
    .clk(clk),
    .rst(rst),
    .left_data_in(right_data_out[NUM_ROUTERS-2]),
    .left_enable_in(right_enable_out[NUM_ROUTERS-2]),
    .left_in_buffer_full(right_out_buffer_full[NUM_ROUTERS-2]),
    .left_out_buffer_full(left_out_buffer_full[NUM_ROUTERS-1]),
    .left_data_out(left_data_out[NUM_ROUTERS-1]),
    .left_enable_out(left_enable_out[NUM_ROUTERS-1]),

    .right_data_in(left_data_out[0]),
    .right_enable_in(left_enable_out[0]),
    .right_in_buffer_full(left_out_buffer_full[0]),
    .right_out_buffer_full(right_out_buffer_full[NUM_ROUTERS-1]),
    .right_data_out(right_data_out[NUM_ROUTERS-1]),
    .right_enable_out(right_enable_out[NUM_ROUTERS-1]),

    .host_data_in(host_data_in[(PACKET_SIZE*(NUM_ROUTERS)-1):PACKET_SIZE*(NUM_ROUTERS-1)]),
    .host_data_out(host_data_out[(PACKET_SIZE*(NUM_ROUTERS)-1):PACKET_SIZE*(NUM_ROUTERS-1)]),
    .host_enable_in(host_en[NUM_ROUTERS-1]));

endmodule




