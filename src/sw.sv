module sw(
    input  cla_t carb2sw,
    input  carb2sw_valid,
    input  cla_t eng2sw,
    input  eng2sw_valid,
    output cla_t sw2clq,
    output logic sw2clq_valid,
    output logic sw2eng_stall
);

/*
carb: Clause Arbiter
sw:   Switch
eng:  Engine
*/

always_comb begin
    sw2clq_valid = 'b0;
    sw2eng_stall = 'b0;

    case({carb2sw_valid, eng2sw_valid})
        'b00: begin
            sw2clq = carb2sw;
            sw2clq_valid = 'b0;
        end
        'b01: begin
            sw2clq = eng2sw;
            sw2clq_valid = 'b1;
        end
        'b10: begin
            sw2clq = carb2sw;
            sw2clq_valid = 'b1;
        end
        'b11: begin
            sw2clq = carb2sw;
            sw2clq_valid = 'b1;
            sw2eng_stall = 'b1;
        end
    endcase
end

endmodule