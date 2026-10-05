module testbench(); //even though the testbench doesn't create any hardware, it still needs to be a module
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    timeunit 10ns; // This is the amount of time represented by #1 
    timeprecision 1ns;

    //input for processor_top
    logic clk;
    logic reset;
    logic run_i;
    logic continue_i;
    logic [15:0] sw_i;
    
    //output from processor_top
    logic [15:0] led_o;
	logic [7:0]  hex_seg_left;
	logic [3:0]  hex_grid_left;
	logic [7:0]  hex_seg_right;
	logic [3:0]  hex_grid_right;

    //debug signals from cpu @@this is where the ghost signals come from
    //logic [15:0] ir;
    //logic [15:0] pc;
    // logic [15:0] mar;
    // logic [15:0] mdr;

    processor_top pt (
        .clk(clk),
        .reset(reset),
        .run_i(run_i),
        .continue_i(continue_i),
        .sw_i(sw_i),
        .led_o(led_o),
        .hex_seg_left(hex_seg_left),
        .hex_grid_left(hex_grid_left),
        .hex_seg_right(hex_seg_right),
        .hex_grid_right(hex_grid_right)
    );

    initial begin
        clk = 1'b0;
    end

    always begin
        #5 clk = ~clk; // delay 5 time units
    end

    initial begin
//        $monitor("t=%0t PC=%04h IR=%04h MAR=%04h MDR=%04h",
//             $time,
//             pt.slc3.cpu.pc,
//             pt.slc3.cpu.ir,
//             pt.slc3.cpu.mar,
//             pt.slc3.cpu.mdr);

        sw_i = 16'h0000; // Initialize sw_i to 0
        reset = 1'b1;
        run_i = 1'b0; // Initialize runi to 0
        continue_i = 1'b0;
        repeat (5) @(posedge clk);
        reset = 1'b0;
        sw_i = 16'hffff;
        repeat (5) @(posedge clk);
        run_i = 1'b1; // click on runi to runi = 1
        repeat (5) @(posedge clk);
        run_i = 1'b0; // Initialize runi to 0
        repeat (100) @(posedge clk);
        continue_i = 1'b1;
        repeat (100) @(posedge clk);
        continue_i = 1'b0;
        repeat (100) @(posedge clk);
        continue_i = 1'b1;
        repeat (100) @(posedge clk);
        continue_i = 1'b0;
        repeat (100) @(posedge clk);
        continue_i = 1'b1;

         $finish();
    end

endmodule
