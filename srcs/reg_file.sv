//last update 6:33pm 9/30
module reg_file (
    input  logic        clk,// needs clock
    input  logic        ld_reg,// will come from control

    input  logic [15:0] data_in, // the 16 bits to be stored COMES FROM BUS
    input  logic [2:0]  dr,     // destination register for the value to be stored (we have 8 to choose from)
    input  logic [2:0]  sr1,    //chose which register to read first
    input  logic [2:0]  sr2,    //chose ...... seconed

    output logic [15:0] sr1_data, // from registers[sr1]
    output logic [15:0] sr2_data  // from registers[sr2]
);

 logic [15:0] registers [8]; // i decided to use the behavioral way since it seemed easier

always_ff @(posedge clk) 
    begin
    if (ld_reg)
        registers[dr] <= data_in; // simply storing the val to its dr
    end

always_comb
    begin
    sr1_data = registers[sr1];
    sr2_data = registers[sr2];
    end
endmodule
