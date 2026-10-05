`timescale 1ns/1ps
// Simulation top: slc3_tb. Add this file as a Simulation Source in Vivado.
// Add the supplied design files and all missing datapath/mux modules as sources.
// types.sv must be in the include search path. Do NOT define SYNTHESIS.
// The supplied CPU/control are incomplete: complete them before running this TB.
// Observe the 16-bit display register rather than multiplexed segment pins.
// Select one test with simulator plusarg +TEST=1 through +TEST=8; default: all.
// Test IDs: 1 IO, 2 paused IO, 3 self-modifying, 4 auto count, 5 XOR,
//           6 multiply, 7 sort, 8 act once.
// Optional +FAST_AUTO shortens ONLY the auto-counter's delay constants in RAM.
// Default uses original memory image, including its original counter delays.
// Hierarchy dependencies are collected in the aliases below. Preserve these
// internal names, or update the aliases after refactoring the CPU.
// Button inputs are active high. Stimulus passes through the real synchronizers.
// This verifies CPU/program behavior, not electrical seven-segment encoding.
module slc3_tb;
    logic clk = 0;
    always #5 clk = ~clk; // 100 MHz
    logic reset = 0, run_i = 0, continue_i = 0;
    logic [15:0] sw_i = 0;
    wire [15:0] led_o;
    wire [7:0] hex_seg_left, hex_seg_right;
    wire [3:0] hex_grid_left, hex_grid_right;

    processor_top dut (.*);

    wire [15:0] display_value = dut.slc3.io_bridge.hex_display;
    wire [15:0] pc = dut.slc3.cpu.pc;
    wire [15:0] ir = dut.slc3.cpu.ir;
    wire [4:0] state = dut.slc3.cpu.state_out;
    // Matches the enum ordering in the uploaded control.sv.
    localparam logic [4:0] PAUSE_PRESS = 5'd1, PAUSE_RELEASE = 5'd2;
    localparam int LIMIT = 200000;
    localparam int AUTO_LIMIT = 20000000;
    localparam int BUTTON_CYCLES = 16; // sync.sv uses COUNTER_WIDTH=1 in simulation
    int failures = 0, checks = 0, selected = 0;
    string current_test;
    logic [15:0] unsorted [0:15];
    logic [15:0] sorted [0:15];

    // Sample after posedge sequential logic has settled; drive at negedges.
    task automatic tick(input int n = 1);
        repeat (n) @(negedge clk);
    endtask

    task automatic check16(input string label_text,
                           input logic [15:0] got, expected);
        checks++;
        if (got !== expected) begin
            failures++;
            $error("%s: %s got=%h expected=%h PC=%h IR=%h state=%0d",
                   current_test, label_text, got, expected, pc, ir, state);
        end else
            $display("PASS %s: %s = %h", current_test, label_text, got);
    endtask

    task automatic timeout_fail(input string label_text);
        $fatal(1, "%s: timeout %s PC=%h IR=%h state=%0d HEX=%h LED=%h",
               current_test, label_text, pc, ir, state, display_value, led_o);
    endtask

    task automatic switches(input logic [15:0] value);
        sw_i = value;
        tick(BUTTON_CYCLES);
    endtask

    task automatic launch(input logic [15:0] address);
        // Start at PC=0 and execute the provided switch-selected boot program.
        // No PC force or instruction injection is used.
        run_i = 0;
        continue_i = 0;
        reset = 0;
        tick(BUTTON_CYCLES); // establish debounce counters before asserting reset
        reset = 1;
        tick(BUTTON_CYCLES);
        sw_i = address;
        reset = 0;
        tick(BUTTON_CYCLES);
        if ($test$plusargs("FAST_AUTO") && address == 16'h009c) begin
            dut.mem_subsystem.test_mem_subsystem.mem_array[173] = 16'd3;
            dut.mem_subsystem.test_mem_subsystem.mem_array[174] = 16'd2;
            $display("FAST_AUTO: delay constants changed to 3 and 2 for simulation");
        end
        run_i = 1;
        tick(BUTTON_CYCLES);
        run_i = 0;
        // Leave switches at the program address until the boot JMP completes.
        for (int n = 0; n < LIMIT; n++) begin
            if (pc === address || pc === (address + 16'd1)) return;
            tick();
        end
        timeout_fail("boot JMP to selected program");
    endtask

    task automatic pause_at(input logic [11:0] checkpoint);
        for (int n = 0; n < LIMIT; n++) begin
            if (state === PAUSE_PRESS && ir === {4'hd, checkpoint}) begin
                tick(2); // allow LED register to settle
                check16("pause LEDs [11:0]", {4'b0,led_o[11:0]},
                        {4'b0,checkpoint});
                return;
            end
            tick();
        end
        timeout_fail($sformatf("checkpoint %h", checkpoint));
    endtask

    task automatic resume_cpu(input int held_cycles = BUTTON_CYCLES);
        // Consume one press/release, and require departure from this pause.
        continue_i = 1;
        for (int n = 0; n < LIMIT; n++) begin
            if (state === PAUSE_RELEASE) break;
            if (n == LIMIT-1) timeout_fail("Continue press recognition");
            tick();
        end
        tick(held_cycles);
        continue_i = 0;
        for (int n = 0; n < LIMIT; n++) begin
            tick();
            if (state !== PAUSE_PRESS && state !== PAUSE_RELEASE
                && !$isunknown(state)) return;
        end
        timeout_fail("Continue release recognition");
    endtask

    task automatic expect_display(input logic [15:0] expected);
        for (int n = 0; n < LIMIT; n++) begin
            if (display_value === expected) begin
                check16("HEX", display_value, expected);
                return;
            end
            tick();
        end
        timeout_fail($sformatf("HEX=%h", expected));
    endtask

    task automatic hold_display(input int cycles);
        logic [15:0] saved;
        saved = display_value;
        repeat (cycles) begin
            tick();
            if (display_value !== saved) begin
                check16("HEX remains stable while paused", display_value, saved);
                return;
            end
        end
        check16("HEX remains stable while paused", display_value, saved);
    endtask

    task automatic test_io;
        current_test = "1 Basic I/O";
        launch(16'h0003);
        switches(16'h1234); expect_display(16'h1234);
        switches(16'hffff); expect_display(16'hffff);
        switches(16'h0000); expect_display(16'h0000);
        switches(16'ha55a); expect_display(16'ha55a);
        switches(16'h8001); expect_display(16'h8001);
    endtask

    task automatic test_paused_io;
        current_test = "2 Paused I/O";
        launch(16'h0006); pause_at(12'h801);
        switches(16'h1234); hold_display(100);
        resume_cpu(); pause_at(12'hc02);
        check16("captured input", display_value, 16'h1234);
        switches(16'hbeef); hold_display(100);
        resume_cpu(); pause_at(12'hc02);
        check16("next captured input", display_value, 16'hbeef);
        switches(16'h0000); hold_display(100);
        resume_cpu(); pause_at(12'hc02);
        check16("zero input", display_value, 16'h0000);
    endtask

    task automatic test_self_modify;
        current_test = "3 Self-modifying code";
        launch(16'h000b); pause_at(12'h801);
        for (int i = 0; i < 5; i++) begin
            switches(16'h1200 + i);
            resume_cpu(); pause_at(12'hc02 + i);
            check16("input transfer", display_value, 16'h1200 + i);
            check16("modified instruction at RAM[16]",
                    dut.mem_subsystem.test_mem_subsystem.mem_array[16],
                    16'hdc02 + i);
        end
    endtask

    task automatic test_auto;
        int count, cycles;
        bit previous_write, writing;
        current_test = "4 Auto counter";
        launch(16'h009c);
        count = 0; cycles = 0; previous_write = 0;
        // Observe write transactions, so the initial output of zero cannot
        // falsely pass merely because reset already cleared the HEX register.
        while (count < 4 && cycles < AUTO_LIMIT) begin
            @(posedge clk);
            writing = (dut.slc3.cpu_mem_ena === 1'b1 &&
                       dut.slc3.cpu_wr_ena === 1'b1 &&
                       dut.slc3.cpu_addr === 16'hffff);
            if (writing && !previous_write) begin
                check16("counter write", dut.slc3.cpu_wdata, count);
                count++;
            end
            previous_write = writing;
            cycles++;
            @(negedge clk);
        end
        if (count != 4) timeout_fail("four automatic counter writes");
    endtask

    task automatic binary_case(input logic [15:0] a, b,
                               input bit multiplication);
        logic [15:0] expected;
        pause_at(12'h801); switches(a); resume_cpu();
        pause_at(12'h802); switches(b); resume_cpu();
        pause_at(multiplication ? 12'h403 : 12'h405);
        expected = multiplication ? (a * b) : (a ^ b);
        check16($sformatf("%h %s %h", a, multiplication ? "*" : "^", b),
                display_value, expected);
        hold_display(100);
        resume_cpu();
    endtask

    task automatic test_xor;
        current_test = "5 XOR";
        launch(16'h0014);
        binary_case(16'h1234,16'h00ff,0);
        binary_case(16'haaaa,16'h5555,0);
        binary_case(16'hffff,16'hffff,0);
        binary_case(16'h0000,16'h8000,0);
        binary_case(16'h8000,16'h0001,0);
    endtask

    task automatic test_multiply;
        current_test = "6 Multiply";
        launch(16'h0031);
        // Uploaded program uses an 8-bit mask and signed handling of operand A.
        // These nonnegative cases agree with the documented unsigned behavior.
        binary_case(16'd0,16'd63,1);
        binary_case(16'd1,16'd42,1);
        binary_case(16'd7,16'd9,1);
        binary_case(16'd59,16'd63,1);
        binary_case(16'd127,16'd127,1);
    endtask

    task automatic show_list(input bit after_sort);
        switches(16'd3); resume_cpu();
        for (int i = 0; i < 16; i++) begin
            // Wait for any display PSE, then report index mismatches without
            // preventing remaining sort/data-entry checks from running.
            for (int n = 0; n < LIMIT; n++) begin
                if (state === PAUSE_PRESS && ir[15:12] === 4'hd) break;
                if (n == LIMIT-1) timeout_fail("sort display pause");
                tick();
            end
            tick(2);
            check16("display checkpoint/index",{4'b0,ir[11:0]},
                    16'h0802 + (i << 4));
            check16("display LED index",{12'b0,led_o[7:4]},i);
            check16($sformatf("display list[%0d]",i), display_value,
                    after_sort ? sorted[i] : unsorted[i]);
            resume_cpu();
        end
        pause_at(12'h3ff);
    endtask

    task automatic test_sort;
        current_test = "7 Sort";
        launch(16'h005a); pause_at(12'h3ff);
        switches(16'd0); resume_cpu(); pause_at(12'h3ff);
        switches(16'd4); resume_cpu(); pause_at(12'h3ff);
        show_list(0);
        switches(16'd2); resume_cpu(); pause_at(12'h3ff);
        for (int i = 0; i < 16; i++)
            check16($sformatf("sorted RAM[%0d]",74+i),
                    dut.mem_subsystem.test_mem_subsystem.mem_array[74+i],sorted[i]);
        // The provided display routine leaves its first PSE self-modified
        // after a full display pass. A second pass may report index 16 at
        // its first pause instead of index 0. This TB intentionally detects
        // that program-image discrepancy; it does not silently repair RAM.
        show_list(1);
        switches(16'd1); resume_cpu();
        for (int i = 0; i < 16; i++) begin
            pause_at(12'hc01);
            check16("entry index", display_value, i);
            switches(15-i); resume_cpu();
        end
        pause_at(12'h3ff);
        for (int i = 0; i < 16; i++)
            check16("entered RAM value",
                    dut.mem_subsystem.test_mem_subsystem.mem_array[74+i],15-i);
        switches(16'd2); resume_cpu(); pause_at(12'h3ff);
        for (int i = 0; i < 16; i++)
            check16("custom list sorted",
                    dut.mem_subsystem.test_mem_subsystem.mem_array[74+i],i);
    endtask

    task automatic test_once;
        current_test = "8 Act once";
        launch(16'h002a); pause_at(12'h401);
        check16("initial count",display_value,16'd0);
        for (int i = 1; i <= 5; i++) begin
            hold_display(100);
            continue_i = 1;
            tick(BUTTON_CYCLES);
            hold_display(200); // held button must not advance repeatedly
            continue_i = 0;
            for (int n = 0; n < LIMIT; n++) begin
                tick();
                if (state !== PAUSE_PRESS && state !== PAUSE_RELEASE
                    && !$isunknown(state)) break;
                if (n == LIMIT-1) timeout_fail("held Continue release");
            end
            pause_at(12'h401);
            check16("one increment per press",display_value,i);
        end
    endtask

    initial begin
        unsorted = '{16'h00ef,16'h001b,16'h0001,16'h008c,
                     16'h00db,16'h00fa,16'h0047,16'h0046,
                     16'h001f,16'h000d,16'h00b8,16'h0003,
                     16'h006b,16'h004e,16'h00f8,16'h0007};
        sorted = '{16'h0001,16'h0003,16'h0007,16'h000d,
                   16'h001b,16'h001f,16'h0046,16'h0047,
                   16'h004e,16'h006b,16'h008c,16'h00b8,
                   16'h00db,16'h00ef,16'h00f8,16'h00fa};
        if ($value$plusargs("TEST=%d", selected)) begin
            if (selected < 1 || selected > 8) $fatal(1,"TEST must be 1..8");
        end
        tick();
        if (selected == 0 || selected == 1) test_io();
        if (selected == 0 || selected == 2) test_paused_io();
        if (selected == 0 || selected == 3) test_self_modify();
        if (selected == 0 || selected == 4) test_auto();
        if (selected == 0 || selected == 5) test_xor();
        if (selected == 0 || selected == 6) test_multiply();
        if (selected == 0 || selected == 7) test_sort();
        if (selected == 0 || selected == 8) test_once();
        $display("Checks=%0d Failures=%0d", checks, failures);
        if (failures != 0) $fatal(1,"SLC3 tests failed");
        $display("All selected SLC3 tests passed");
        $finish;
    end
endmodule
