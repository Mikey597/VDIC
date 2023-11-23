interface mult_bfm;
import mult_pkg::*;
//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------

logic               clk;
logic               rst_n;
bit   signed [15:0] arg_a;
bit                 arg_a_parity;     // parity bit for arg b (even parity)
bit   signed [15:0] arg_b;        
bit                 arg_b_parity;     // parity bit for arg_a (even parity)
logic               req;              // arguments are valid
logic               ack;              // acknowledge for the arguments
bit   signed [31:0] result;           // result of multiplication
bit                 result_parity;    // parity bit for result (even parity)
logic               result_rdy;       // result is ready
bit                 arg_parity_error;  // set to 1 when input data has parity errors
bit a_parity_err;
bit b_parity_err;	
	
	
//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------
initial begin : clk_gen_blk
    clk = 0;
    forever begin : clk_frv_blk
        #10;
        clk = ~clk;
    end
end


//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------
task reset();
	`ifdef DEBUG
    $display("%0t DEBUG: reset", $time);
	`endif
    rst_n = 1'b0;
    @(negedge clk);
    	rst_n = 1'b1;
endtask : reset


//------------------------------------------------------------------------------
// wait for ready
//------------------------------------------------------------------------------
task wait_for_rdy();
	wait(result_rdy);
endtask : wait_for_rdy


//------------------------------------------------------------------------------
// send_data
//------------------------------------------------------------------------------
task send_data(
	input bit signed 	[15:0] 	i_arg_a,
	input bit signed 	[15:0] 	i_arg_b,
	input bit               	i_arg_a_parity,
	input bit               	i_arg_b_parity
	);

    arg_a = i_arg_a;
	arg_a_parity = i_arg_a_parity;
	arg_b = i_arg_b;
	arg_b_parity = i_arg_b_parity;
	req = 1'b1;
	while(!ack )@(negedge clk);
	req = 1'b0;
	while(!result_rdy)@(negedge clk);


endtask : send_data

task error_record(	input bit i_a_par_err,
					input bit i_b_par_err);
	
	a_parity_err = i_a_par_err;
	b_parity_err = i_b_par_err;
	
endtask : error_record

endinterface : mult_bfm


