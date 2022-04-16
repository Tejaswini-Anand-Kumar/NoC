module router #(
    parameter ROUTER_ID = 0,
    parameter PACKET_SIZE = 8,
    parameter NUM_ROUTERS = 4,
    parameter ROUTER_BITS = 2,
    parameter NUM_VC = 4

)(
    input clk,
    input rst,

    input [PACKET_SIZE-1:0]left_data_in, //data entering from left port; left_data_in[2:0] - destination router
    input left_enable_in, // if 1, take input data
    input left_in_buffer_full, //next router indicating it's buffer is full
    output left_out_buffer_full, //this router indicating previous router that it is full
    output [PACKET_SIZE-1:0]left_data_out, //outgoing data from left port
    output left_enable_out, //continue passing data to next router if 1
    
    input [PACKET_SIZE-1:0]right_data_in,
    input right_enable_in,
    input right_in_buffer_full,
    output right_out_buffer_full,
    output [PACKET_SIZE-1:0]right_data_out,
    output right_enable_out

    
    // input [PACKET_SIZE-1:0]host_data_in,
    // input host_enable_in,
    // output [PACKET_SIZE-1:0]host_data_out
);

    reg left_out_buffer_full;
    reg [PACKET_SIZE-1:0]left_data_out;
    reg left_enable_out;
    reg right_out_buffer_full;
    reg [PACKET_SIZE-1:0]right_data_out;
    reg right_enable_out;

    reg [ROUTER_BITS-1:0]router_no; //fixed value

    reg [PACKET_SIZE:0] vc0; //4 VC's : 2 left , 2 right
    reg [PACKET_SIZE:0] vc1;
    reg [PACKET_SIZE:0] vc2;
    reg [PACKET_SIZE:0] vc3;
    integer vc_left; //indicates empty VC for left_data_in
    integer vc_right; //indidcates empty VC for right_data_in
    integer left_full_vc=0; //indidcates all left VCs are full
    integer right_full_vc=0; //indicates all right VCs are full
    integer random_loop1=0;
    integer random_loop2=0;
    integer temp1=0;
    integer temp2=0;
    integer i,j,a,b,c,d;
    integer flag1, flag2, flag3, flag4;
    integer x;
    //Traffic going from left to right
    always @(posedge clk)
    begin
        if(rst)
        begin
            right_data_out <= 8'bz;
            right_enable_out <= 1'b0;
            router_no <= ROUTER_ID;
            vc0 <=8'b0;
            vc1 <=8'b0;
            vc_left <= -1;
            x <= 1;
            flag1 <= 0; //change
            flag2 <= 0;
        
        end

        else
        begin
            x <= 22;
            if(left_enable_in == 1)
            begin
                x <= 23;
                flag1 <= 0;
                if((vc0[0] == 0) && (flag1 == 0)) //if current vc is invalid
                begin
                    x <= 55;
                    vc0[PACKET_SIZE:1] <= left_data_in; //assign left data to empty vc
                    vc0[0] <= 1; //set it to valid
                    flag1 <= 1;
                    x <= 2;
                end

                else if((vc1[0] == 0) && (flag1 == 0)) //if current vc is invalid
                begin
                    vc1[PACKET_SIZE:1] <= left_data_in; //assign left data to empty vc
                    vc1[0] <= 1; //set it to valid
                    flag1 <= 1;
                    x <= 3;
                end
                flag1 <= 0;
            end
            x <= 10;
           vc_left <= ({$random} %2)? (vc1[0]? 1:(vc0[0]? 0:-1)) : (vc0[0]? 0:(vc1[0]? 1:-1));
            x <= 4;
            if((vc_left == 0) && (vc0[0] == 1))
            begin
                x <= 3;
                if (vc0[ROUTER_BITS:1] == router_no) //if Packet has reached destination
                begin
                    right_enable_out <= 0; //stop forwarding the packet in the network
                    right_data_out <= 8'bz;
                    vc0 <= 0;
                    //send host
                end
                else if (right_in_buffer_full == 1) //check if next router has empty buffers, if 1 don't forward
                begin
                    right_enable_out <= 0; //don't forward packet
                    right_data_out <= 1'bz;
                end
                else //if current router is not destination and packet can be forwarded
                begin
                    x <= 2;
                    right_data_out <= vc0[PACKET_SIZE:1];
                    right_enable_out <= 1'b1; //change
                    vc0 <= 0; //free the VC after packet is sent out
                end
            end
            else if((vc_left == 1) && (vc1[0] == 1))
            begin
                if (vc1[ROUTER_BITS:1] == router_no) //if Packet has reached destination
                begin
                    right_enable_out <= 0; //stop forwarding the packet in the network
                    right_data_out <= 8'bz;
                    vc0 <= 0;
                    //send host
                end
                else if (right_in_buffer_full == 1) //check if next router has empty buffers, if 1 don't forward
                begin
                    right_enable_out <= 0; //don't forward packet
                    right_data_out <= 1'bz;
                end
                else //if current router is not destination and packet can be forwarded
                begin
                    right_data_out <= vc1[PACKET_SIZE:1];
                    right_enable_out <= 1'b1;
                    vc1 <= 0; //free the VC after packet is sent out
                end
            end
            else
            begin
                right_data_out <= 8'bz;
                right_enable_out <= 1'b0;
            end
            
            //indicate to the previous router if current router has free VCs
            left_full_vc <= 0;
            if(vc0[0] == 1)
            left_full_vc <= left_full_vc + 1;
            if(vc1[0] == 1)
            left_full_vc <= left_full_vc + 1;
            
            if(left_full_vc == NUM_VC/2)
                left_out_buffer_full <= 1;
            else
                left_out_buffer_full <= 0;
        end
    end





    endmodule
