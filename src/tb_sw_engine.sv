real PERIOD = 10.0;


module tb_sw_engine();

logic       clk;
logic       rst_n;

//To UCQ_OUT
lit_t       uca2ucq,
logic       push,

//UCQ_out fifo to engine
lit_t       litDec;
logic       UCQ_out_empty;

// C arbiter to swith
cla_t       carb2sw;
logic       carb2sw_valid;

// Engine to swith
cla_t       eng2sw;
logic       eng2sw_valid;

top DUT(
    .clk(clk),
    .rst_n(rst_n),
    
    .ucarb2UCQ_in_pop(ucarb2UCQ_in_pop),
    .carb2sw(),
    .carb2sw_valid(),
    .clq2sw(),
);

task initialize()
    clk           = 0;

    uca2ucq       = 0;
    push          = 0;

    cla_in        = 0;
    carb2sw_valid = 0;

endtask

task ucarbiter_send_UCQ_out(input lit_t in);
    uca2ucq = in;
    push    = 1;
endtask

task carb_send_sw(input cla_t in);
    cla_in        = in;
    carb2sw_valid = 1;
endtask

always begin
    #(`PERIOD/2);
    clk = ~clk;
end

initial begin
    initialize();

    @(negedge clk);
    ucarbiter_send_UCQ_out('b11111111111) // unit clause = (-1)

    @(negedge clk);
    carb_send_sw('b000000000000000000000000000000000);  //initial header from c arbiter
    @(negedge clk);
    carb_send_sw('b000000000010000000001000000000111); // clause = (1, 2, 7)
    @(negedge clk);
    carb_send_sw('b000000000101111111111100000000101); // clause = (2, -1, 5)
    @(negedge clk);
    carb_send_sw('b000000000000000000001100000000001); // clause = (0, 3, 1)
    @(negedge clk);
    carb_send_sw('b000000001100000000001100000000001); // clause = (6, 3, 1)
    @(negedge clk);
    carb2sw_valid = 0;  // Done with sending to SW



    //Expect output
    //In CLQ_FIFO
    // (0, 2, 7) (0, 3, 0) (6, 3, 0)

    //In UCQ_in_FIFO
    // (3)

    $finish;
end