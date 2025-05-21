`default_nettype none
`timescale 1ns/1ps

`include "CPU.v"

module risc_test;

  reg  clk;
  reg  rst;
  wire halt;

  CPU risc_inst (clk, rst, halt);

  // Task to generate specified number of clock cycles
  task clock (input integer number);
    repeat (number) begin
      clk = 0; #1;
      clk = 1; #1;
    end
  endtask

  // Task to perform reset sequence
  task reset;
    begin
      rst = 1; clock(1);
      rst = 0; clock(1);
    end
  endtask

  // Task to check expected halt value
  task expect (input exp_halt);
    if (halt !== exp_halt) begin
      $display("TEST FAILED at time %0d: halt is %b, should be %b", $time, halt, exp_halt);
      $finish;
    end
  endtask

  // Opcode definitions
  localparam [2:0] HLT=0, SKZ=1, ADD=2, AND=3, XOR=4, LDA=5, STO=6, JMP=7;

  initial begin
    // Test 1: Verify reset functionality
    $display("Testing reset");
    risc_inst.memory_inst.D_mem[0] = { HLT, 5'bx };
    reset;
    expect(0);

    // Test 2: Verify HLT instruction stops CPU after 3 cycles
    $display("Testing HLT instruction");
    risc_inst.memory_inst.D_mem[0] = { HLT, 5'bx };
    reset;
    clock(2); expect(0); clock(1); expect(1);

    // Test 3: Verify JMP instruction jumps to address 2, halts after 11 cycles
    $display("Testing JMP instruction");
    risc_inst.memory_inst.D_mem[0] = { JMP, 5'd2 };
    risc_inst.memory_inst.D_mem[1] = { JMP, 5'd2 };
    risc_inst.memory_inst.D_mem[2] = { HLT, 5'bx };
    reset;
    clock(10); expect(0); clock(1); expect(1);

    // Test 4: Verify SKZ instruction skips JMP when Accumulator is 0, halts after 11 cycles
    $display("Testing SKZ instruction");
    risc_inst.memory_inst.D_mem[0] = { SKZ, 5'bx };
    risc_inst.memory_inst.D_mem[1] = { JMP, 5'd2 };
    risc_inst.memory_inst.D_mem[2] = { HLT, 5'bx };
    reset;
    clock(10); expect(0); clock(1); expect(1);

    // Test 5: Verify LDA instruction loads data from memory to Accumulator, halts after 19 cycles
    $display("Testing LDA instruction");
    risc_inst.memory_inst.D_mem[0] = { LDA, 5'd5 };
    risc_inst.memory_inst.D_mem[1] = { SKZ, 5'bx };
    risc_inst.memory_inst.D_mem[2] = { HLT, 5'bx };
    risc_inst.memory_inst.D_mem[3] = { JMP, 5'd4 };
    risc_inst.memory_inst.D_mem[4] = { HLT, 5'bx };
    risc_inst.memory_inst.D_mem[5] = { 8'd1 };
    reset;
    clock(18); expect(0); clock(1); expect(1);

    // Test 6: Verify STO instruction stores Accumulator to memory, halts after 35 cycles
    $display("Testing STO instruction");
    risc_inst.memory_inst.D_mem[0] = { LDA, 5'd7 };
    risc_inst.memory_inst.D_mem[1] = { STO, 5'd8 };
    risc_inst.memory_inst.D_mem[2] = { LDA, 5'd8 };
    risc_inst.memory_inst.D_mem[3] = { SKZ, 5'bx };
    risc_inst.memory_inst.D_mem[4] = { HLT, 5'bx };
    risc_inst.memory_inst.D_mem[5] = { JMP, 5'd6 };
    risc_inst.memory_inst.D_mem[6] = { HLT, 5'bx };
    risc_inst.memory_inst.D_mem[7] = { 8'd1 };
    risc_inst.memory_inst.D_mem[8] = { 8'd0 };
    reset;
    clock(34); expect(0); clock(1); expect(1);

    // Test 7: Verify AND instruction performs logical AND, halts after 59 cycles
    $display("Testing AND instruction");
    risc_inst.memory_inst.D_mem[0] = { LDA, 5'd10 };
    risc_inst.memory_inst.D_mem[1] = { AND, 5'd11 };
    risc_inst.memory_inst.D_mem[2] = { SKZ, 5'bx };
    risc_inst.memory_inst.D_mem[3] = { JMP, 5'd5 };
    risc_inst.memory_inst.D_mem[4] = { HLT, 5'bx };
    risc_inst.memory_inst.D_mem[5] = { AND, 5'd12 };
    risc_inst.memory_inst.D_mem[6] = { SKZ, 5'bx };
    risc_inst.memory_inst.D_mem[7] = { HLT, 5'bx };
    risc_inst.memory_inst.D_mem[8] = { JMP, 5'd9 };
    risc_inst.memory_inst.D_mem[9] = { HLT, 5'bx };
    risc_inst.memory_inst.D_mem[10] = { 8'hff };
    risc_inst.memory_inst.D_mem[11] = { 8'h01 };
    risc_inst.memory_inst.D_mem[12] = { 8'hfe };
    reset;
    clock(58); expect(0); clock(1); expect(1);

    // Test 8: Verify XOR instruction performs logical XOR, halts after 59 cycles
    $display("Testing XOR instruction");
    risc_inst.memory_inst.D_mem[0] = { LDA, 5'd10 };
    risc_inst.memory_inst.D_mem[1] = { XOR, 5'd11 };
    risc_inst.memory_inst.D_mem[2] = { SKZ, 5'bx };
    risc_inst.memory_inst.D_mem[3] = { JMP, 5'd5 };
    risc_inst.memory_inst.D_mem[4] = { HLT, 5'bx };
    risc_inst.memory_inst.D_mem[5] = { XOR, 5'd12 };
    risc_inst.memory_inst.D_mem[6] = { SKZ, 5'bx };
    risc_inst.memory_inst.D_mem[7] = { HLT, 5'bx };
    risc_inst.memory_inst.D_mem[8] = { JMP, 5'd9 };
    risc_inst.memory_inst.D_mem[9] = { HLT, 5'bx };
    risc_inst.memory_inst.D_mem[10] = { 8'h55 };
    risc_inst.memory_inst.D_mem[11] = { 8'h54 };
    risc_inst.memory_inst.D_mem[12] = { 8'h01 };
    reset;
    clock(58); expect(0); clock(1); expect(1);

    // Test 9: Verify ADD instruction performs addition, halts after 43 cycles
    $display("Testing ADD instruction");
    risc_inst.memory_inst.D_mem[0] = { LDA, 5'd9 };
    risc_inst.memory_inst.D_mem[1] = { ADD, 5'd11 };
    risc_inst.memory_inst.D_mem[2] = { SKZ, 5'bx };
    risc_inst.memory_inst.D_mem[3] = { HLT, 5'bx };
    risc_inst.memory_inst.D_mem[4] = { ADD, 5'd11 };
    risc_inst.memory_inst.D_mem[5] = { SKZ, 5'bx };
    risc_inst.memory_inst.D_mem[6] = { HLT, 5'bx };
    risc_inst.memory_inst.D_mem[7] = { JMP, 5'd9 };
    risc_inst.memory_inst.D_mem[8] = { HLT, 5'bx };
    risc_inst.memory_inst.D_mem[9] = { 8'hff };
    risc_inst.memory_inst.D_mem[11] = { 8'h01 };
    reset;
    clock(42); expect(0); clock(1); expect(1);

    $display("TEST PASSED");
    $finish;
  end
  
  // Monitor signals
  initial begin
    $dumpfile("testbench.vcd"); // Generate VCD file for waveform viewing
    $dumpvars(0, risc_test);    // Dump all signals in the testbench hierarchy
    $monitor("Time=%0t | clk=%b rst=%b halt=%b PC=%h Accumulator=%h zero=%b addr=%h data=%h phase=%b opcode=%b",
             $time, clk, rst, halt,
             risc_inst.counter_pc.cnt_out,           // Program Counter
             risc_inst.register_ac.data_out,         // Accumulator
             risc_inst.alu_inst.a_is_zero,           // Zero flag
             risc_inst.memory_inst.addr,             // Memory address
             risc_inst.memory_inst.data,             // Memory data
             risc_inst.controller_inst.phase,        // Controller phase
             risc_inst.register_ir.data_out[7:5]);   // Opcode
  end
  
  initial begin
    $recordfile ("waves");
    $recordvars ("depth=0", risc_test);
  end

endmodule