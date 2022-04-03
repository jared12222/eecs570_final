module gst(

    input clk,
    input rst_n,

    // Global State Table <-> BCP Engine
    input  cla_t                         bcp2gst_curr_cla,
    input  logic                         bcp2gst_curr_cla_valid,
    input  bcp_state_t [`NUM_ENGINE-1:0] bcp2gst_curr_state,
    output lit_state_t [`CLA_LENGTH-1:0] gst2bcp_lit_state,
    output logic                         gst2bcp_lit_state_valid,
    output logic       [`NUM_ENGINE-1:0] gst2bcp_update_finish,

    // UC Arbiter <-> Global State Table
    input  lit_t ucarb2gst_lit,
    input  logic ucarb2gst_empty,
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

logic [$clog2(`LIT_IDX_MAX)-2:0] uc_idx;
logic                            uc_polarity;

assign uc_polarity = ucarb2gst_lit[$clog2(`LIT_IDX_MAX)];
assign uc_idx      = uc_polarity? 
    ~ucarb2gst_lit[$clog2(`LIT_IDX_MAX)-1:0] + 1 : 
     ucarb2gst_lit[$clog2(`LIT_IDX_MAX)-1:0];

always_comb begin
    lit_status_w          = lit_status_r;
    gst2bcp_update_finish = 'b0;
    gst2ucarb_pop         = 'b0;
    next_state            = curr_state;

    case (curr_state)
        READ: begin
            if (bcp2gst_curr_cla_valid) begin        
                for (int i=0; i<`CLA_LENGTH; i++) begin
                    // Return lookup results
                    if (bcp2gst_curr_cla[i] != 'b0) begin
                        gst2bcp_lit_state[i] = lit_status_r[bcp2gst_curr_cla[i]];
                    end
                    else begin
                        gst2bcp_lit_state[i] = FALSE;
                    end
                end
            end
            // Allow update of gst iff all engines are done
            if (&bcp2gst_curr_state) begin              
                next_state = WRITE;
            end
            else begin
                next_state = READ;
            end
        end
        WRITE: begin
            lit_status_w[uc_idx]  = uc_polarity ? FALSE : TRUE;
            gst2ucarb_pop         = 'b1;
            
            if (!ucarb2gst_empty) begin
                next_state = WRITE;
            end
            else begin
                gst2bcp_update_finish = 'b1;
                next_state = READ;
            end
        end
    endcase
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