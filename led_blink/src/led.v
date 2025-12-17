module led(
    input clock,
    output reg led);
    reg [23:0] counter;
    wire [23:0] target = 13_499_999;
    wire [23:0] added;
    LAadder#(6) adder(.a(counter),.b(24'b1),.cin(1'b0),.sum(added));
    assign eq = ~|(added^target);
    always@(posedge clock)begin
        counter <= added&{24{~eq}};
    end
    always@(posedge clock)begin
        led <= led^eq;
    end
endmodule

module CLA4b(
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] sum,
    output cout);

    wire [3:0] G;
    wire [3:0] P;
    wire [3:0] C;

    assign G = a&b;
    assign P = a^b;

    assign C[0] = cin;
    assign C[1] = G[0] | P[0]&C[0];
    assign C[2] = G[1] | P[1]&G[0] | P[1]&P[0]&C[0];
    assign C[3] = G[2] | P[2]&G[1] | P[2]&P[1]&G[0] | P[2]&P[1]&P[0]&C[0];
    assign cout = G[3] | P[3]&G[2] | P[3]&P[2]&G[1] | P[3]&P[2]&P[1]&G[0] | P[3]&P[2]&P[1]&P[0]&C[0];

    assign sum = P ^ C;

endmodule

module LAadder#(parameter width = 8)(
    input [width*4 - 1:0]a,
    input [width*4 - 1:0]b,
    input cin,
    output [4*width - 1:0] sum,
    output cout);

    wire [width:0] carry;
    assign carry[0] = cin;
    generate
        genvar i;
        for(i = 0; i < width; i=i+1) begin : adder_loop
            CLA4b adder(.a(a[4*i+3:4*i]),.b(b[4*i+3:4*i]),.cin(carry[i]),.sum(sum[4*i+3:4*i]),.cout(carry[i+1]));
        end
    endgenerate
    assign cout = carry[width];
endmodule
