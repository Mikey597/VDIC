import mult_pkg::*;

interface mult_bfm;
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
	
command_monitor command_monitor_h;
result_monitor result_monitor_h;	
	
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
endtask


//------------------------------------------------------------------------------
// send_data
//------------------------------------------------------------------------------
task send_data(
	input bit signed 	[15:0] 	i_arg_a,
	input bit signed 	[15:0] 	i_arg_b,
	input bit               	i_arg_a_parity,
	input bit               	i_arg_b_parity,
	input bit 					i_rst_n
	);

    arg_a = i_arg_a;
	arg_b = i_arg_b;
	arg_a_parity = i_arg_a_parity;
	arg_b_parity = i_arg_b_parity;
	rst_n = i_rst_n;
	error_record(i_arg_a, i_arg_b, i_arg_a_parity, i_arg_b_parity);
	req = 1'b1;
	while(!ack )@(negedge clk);
	req = 1'b0;
	while(!result_rdy)@(negedge clk);
	@(negedge result_rdy);

endtask 

task error_record(		input bit signed 	[15:0] 	i_arg_a,
						input bit signed 	[15:0] 	i_arg_b,
						input bit               	i_arg_a_parity,
						input bit               	i_arg_b_parity);
	a_parity_err = 0;
	b_parity_err = 0;
	if(^i_arg_a != i_arg_a_parity)
		a_parity_err = 1;
	if(^i_arg_b != i_arg_b_parity)
		b_parity_err = 1;
	
endtask 

//------------------------------------------------------------------------------
// write command monitor
//------------------------------------------------------------------------------
always @(posedge clk) begin
//    command_transaction command;
    if (ack) begin
//	    command.rst_n = rst_n;
//        command.arg_a = arg_a;
//		command.arg_b = arg_b;
//	    command.arg_a_parity = arg_a_parity;
//	    command.arg_b_parity = arg_b_parity;
//	    command.a_err_flg = a_parity_err;
//	    command.b_err_flg = b_parity_err;
        command_monitor_h.write_to_monitor(arg_a,arg_b,arg_a_parity,arg_b_parity,rst_n);
    end
end

always @(negedge rst_n) begin
//    command_transaction command;
//    command.rst_n = 0;
    if (command_monitor_h != null) //guard against VCS time 0 negedge
        command_monitor_h.write_to_monitor(arg_a,arg_b,arg_a_parity,arg_b_parity,rst_n);
end

//------------------------------------------------------------------------------
// write result monitor
//------------------------------------------------------------------------------
initial begin : result_monitor_thread
	// result_s res;
    forever begin
        @(posedge clk) ;
        if (result_rdy) begin
	        // res.result = result;
	        // res.result_parity = result_parity;
	        // res.arg_parity_error = arg_parity_error;
            result_monitor_h.write_to_monitor(result, result_parity, arg_parity_error);
	    end
    end
end : result_monitor_thread



endinterface : mult_bfm


