`define UC_LENGTH 1024
`define UCA_SIZE 8

module uc_arbiter (
    input  logic clk,
    input  logic rst,
    input  logic [$clog2(UC_LENGTH)-1:0] mem2uca,
    input  logic [$clog2(UC_LENGTH)-1:0] eng2uca,
    output logic [$clog2(UC_LENGTH)-1:0] uca2ucq
);

uc_queue (


);


logic [$clog2(UCA_SIZE)-1:0][$clog2(UC_LENGTH)-1:0] buffer_r;
logic [$clog2(UCA_SIZE)-1:0][$clog2(UC_LENGTH)-1:0] buffer_w;

always_comb begin
    for(i=0; i<$clog2(UCA_SIZE); i++) begin
            buffer_w[i] = buffer_r[i];
    end
end


always_ff @(posedge clk or negedge rst) begin
    if (rst) begin
        for(i=0; i<$clog2(UCA_SIZE); i++) begin
            buffer_r[i] <= 0;
        end
    end
    else begin
        for(i=0; i<$clog2(UCA_SIZE); i++) begin
            buffer_r[i] <= buffer_w[i];
        end
    end
end

endmodule