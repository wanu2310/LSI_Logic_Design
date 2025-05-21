`default_nettype none
`timescale 1ns/1ps

module Mux #(parameter width = 5)(
    input wire [width-1:0] in0, in1,
    input wire sel,
    output wire [width-1:0] mux_out
);
    assign mux_out = sel ? in1 : in0;
endmodule
