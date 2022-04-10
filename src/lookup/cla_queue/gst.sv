module gst(

    input clk,
    input rst_n,

    // Global State Table <-> BCP Engine
    input  cla_t       [`NUM_ENGINE-1:0] bcp2gst_curr_cla,
    input  logic       [`NUM_ENGINE-1:0] bcp2gst_curr_cla_valid,
    input  bcp_state_t [`NUM_ENGINE-1:0] bcp2gst_curr_state,
    output lit_state_t [`NUM_ENGINE-1:0] [`CLA_LENGTH-1:0] gst2bcp_lit_state,
    output logic       [`NUM_ENGINE-1:0] gst2bcp_update_finish,

    /*
        UC Arbiter <-> Global State Table
    */
    // From UC arbiter MUX in
    input  lit_t ucarb2gst_lit,
    input  logic ucarb2gst_valid,
    // From UC arbiter output initial decision
    input  lit_t ucarb2gst_init_lit,
    input  logic ucarb2gst_init_vaild,

    output logic gst2ucarb_pop

    
);

/*
ucarb: Unit Clause arbiter
gst:   Global status table -- stores all current statuses of each literal
bcp:   BCP process engine -- Engine would lookup literal status from gst
*/

lit_table_t lit_status_r;
lit_table_t lit_status_w;

typedef enum logic { 
    READ  = 1'b0,
    WRITE = 1'b1
} gst_state_t;

gst_state_t curr_state;
gst_state_t next_state;

logic [$clog2(`LIT_IDX_MAX)-1:0] uc_idx;
logic                            uc_polarity;

// assign uc_polarity = ucarb2gst_lit[$clog2(`LIT_IDX_MAX)];
// assign uc_idx      = uc_polarity? 
//     ~ucarb2gst_lit[$clog2(`LIT_IDX_MAX)-1:0] + 1 : 
//      ucarb2gst_lit[$clog2(`LIT_IDX_MAX)-1:0];

always_comb begin
    if (ucarb2gst_valid) begin
        uc_polarity = ucarb2gst_lit[$clog2(`LIT_IDX_MAX)];
        if (uc_polarity) begin
            uc_idx = ~ucarb2gst_lit[$clog2(`LIT_IDX_MAX)-1:0] + 1;
        end
        else begin
            uc_idx = ucarb2gst_lit[$clog2(`LIT_IDX_MAX)-1:0];
        end
    end
    else begin
        uc_polarity = ucarb2gst_init_lit[$clog2(`LIT_IDX_MAX)];
        if (uc_polarity) begin
            uc_idx = ~ucarb2gst_init_lit[$clog2(`LIT_IDX_MAX)-1:0] + 1;
        end
        else begin
            uc_idx = ucarb2gst_init_lit[$clog2(`LIT_IDX_MAX)-1:0];
        end
    end

end

always_comb begin
    lit_status_w          = lit_status_r;
    gst2bcp_update_finish = 'b0;
    gst2ucarb_pop         = 'b0;
    next_state            = curr_state;

    // case (curr_state)
    //     READ: begin
            for(int j = 0; j < `NUM_ENGINE ; j++) begin
                if (bcp2gst_curr_cla_valid[j]) begin        
                    for (int i=0; i<`CLA_LENGTH; i++) begin
                        // Return lookup results
                        if (bcp2gst_curr_cla[j][i] != 'b0) begin
                            gst2bcp_lit_state[j][i] = lit_status_r[bcp2gst_curr_cla[j][i]];
                        end
                        else begin
                            gst2bcp_lit_state[j][i] = FALSE;
                        end
                    end
                end
            end
        //     // Allow update of gst iff all engines are done
        //     if (&bcp2gst_curr_state) begin              
        //         next_state = WRITE;
        //     end
        //     else begin
        //         next_state = READ;
        //     end
        // end
        // WRITE: begin
            if(ucarb2gst_valid | ucarb2gst_init_vaild) begin
                lit_status_w[uc_idx]  = uc_polarity ? FALSE : TRUE;
                gst2ucarb_pop         = 'b1;
            end
            
            // if (!ucarb2gst_empty) begin
            //     next_state = WRITE;
            // end
            // else begin
                // gst2bcp_update_finish = 'b1;
                // next_state = READ;
            // end
        // end
    // endcase
end

always_ff @(posedge clk) begin
    if (rst_n) begin
        for (int i=0; i<`LIT_IDX_MAX; i++) begin
            lit_status_r[i] <= UNDEFINED;
        end
        curr_state <= READ;
    end
    else begin
        for (int i=0; i<`LIT_IDX_MAX; i++) begin
            lit_status_r[i] <= lit_status_w[i];
        end
        curr_state <= next_state;
    end
end

endmodule