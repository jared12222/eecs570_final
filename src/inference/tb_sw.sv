module tb_sw();

real CLK = 10;

logic clk;
logic rst;
cla_t carb2sw;
logic carb2sw_valid;
cla_t eng2sw;
logic eng2sw_valid;
cla_t sw2clq;
logic sw2clq_valid;
logic sw2eng_stall;

sw sw(
    .carb2sw(carb2sw),
    .carb2sw_valid(carb2sw_valid),
    .eng2sw(eng2sw),
    .eng2sw_valid(eng2sw_valid),
    .sw2clq(sw2clq),
    .sw2clq_valid(sw2clq_valid),
    .sw2eng_stall(sw2eng_stall)
);

always begin
   #(CLK/2);
   clk = ~clk; 
end

task reset_sys();
    // Toggle reset
    rst = 1; 
    @(negedge clk);
    rst = 0; 
endtask

task carb_set(int data);
   carb2sw = data;
   carb2sw_valid = 'b1;
endtask

task eng_set(int data);
    eng2sw = data;
    eng2sw_valid = 'b1;
endtask

task all_reset();
    @(negedge clk);
    carb2sw = 0;
    eng2sw  = 0;
    carb2sw_valid = 0;
    eng2sw_valid = 0;
endtask

initial begin
    clk = 0;
    all_reset();
    reset_sys();

    @(negedge clk);
    carb_set(5);
    eng_set(10);

    all_reset();
    carb_set(20);

    all_reset();
    eng_set(30);

    repeat(10) begin
        @(negedge clk);
    end

    $finish;
end


endmodule