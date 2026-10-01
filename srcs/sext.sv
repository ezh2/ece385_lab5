module sext (
    input  logic [10:0] data_in, // pls notice that not all data in might be actual data
                                    // its just just 11 is the max num of bits we are expected to extend,
                                    //i think this will work but feel free to question it
    input  logic [1:0] sel, //4 cases so 2 bits
    output logic [15:0] data_out // the extended final val
);

always_comb begin
    if (sel==2'b00) // this case mean if the in is of width 5
        data_out={{11{data_in[4]}},data_in[4:0]}; //notice that we extend the last bit to ptreserve the sigm

    else if (sel==2'b01)  // this case mean if the in is of width 6
        data_out={{10{data_in[5]}},data_in[5:0]};

    else if (sel==2'b10)  // this case mean if the in is of width 9
        data_out={{7{data_in[8]}},data_in[8:0]};

    else                    // this case mean if the in is of width 11
        data_out={{5{data_in[10]}},data_in[10:0]};
end

endmodule