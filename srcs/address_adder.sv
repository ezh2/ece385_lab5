module address_adder(

input logic[15:0] addr1,
input logic[15:0] addr2,

output logic  [15:0] address_out

);

assign address_out = addr1+addr2;

endmodule
