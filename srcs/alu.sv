module alu (
    input  logic [15:0] a,    // first value
    input  logic [15:0] b,    // second value
    input  logic [1:0] aluk,  // chooses the operation
    
    output logic [15:0] result
);

always_comb begin
    if (aluk==2'b00) //ADD
        result =a + b; //we can use + right?
    else if (aluk==2'b01)//AND
        result = a&b;
    else if (aluk==2'b10) //NOT
        result =~a;
    else
        result=a; // 11 state passes A
end

endmodule