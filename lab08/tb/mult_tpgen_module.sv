module mult_tpgen_module(mult_bfm bfm);
import mult_pkg::*;

//---------------------------------
// Random data generation functions
//---------------------------------
function bit signed [15:0] get_data();
    bit [1:0] zero_ones;

    zero_ones = 2'($random);

    if (zero_ones == 2'b00)
        return 16'sh8000;
    else if (zero_ones == 2'b01)
        return 16'sh7FFF;
    else if (zero_ones == 2'b10 )
        return 16'sh0000;
    else 
        return 16'($random);
endfunction : get_data

//------------------------------------------------------------------------------
// get_parity - generate input parity bit with random error generation
//------------------------------------------------------------------------------
function bit [3:0] get_parity(bit signed [15:0] arg_a,
                              bit signed [15:0] arg_b);

	bit  		arg_a_parity;
	bit  		arg_b_parity;
	bit [2:0] 	err_a;
	bit [2:0] 	err_b;
	bit 		a_err_flg;
	bit 		b_err_flg;
	
	a_err_flg = 0;
	b_err_flg = 0;
	err_a = 3'($random);
	err_b = 3'($random);
	
	arg_a_parity = ^arg_a;
	arg_b_parity = ^arg_b;
	
	if (err_a == '0) begin
		arg_a_parity = ~arg_a_parity;
		a_err_flg = 1;
	end
	if (err_b == '0) begin
		arg_b_parity = ~arg_b_parity;
		b_err_flg = 1;
	end
	
	return {arg_a_parity, arg_b_parity, a_err_flg, b_err_flg};
endfunction	: get_parity
	
//------------------------------------------------------------------------------

initial begin
	bit signed [15:0] arg_a;
	bit signed [15:0] arg_b;
	bit 			  arg_a_parity;
	bit 			  arg_b_parity;
	bit 			  a_parity_err;
	bit 			  b_parity_err;
	bit				  rst_n;
    bfm.reset();
    repeat (10000) begin
        //@(negedge clk);
        rst_n = 1;
        arg_a      = get_data();
        arg_b      = get_data();
	    {arg_a_parity,arg_b_parity,a_parity_err,b_parity_err} = get_parity(arg_a, arg_b);
	    bfm.send_data(arg_a, arg_b, arg_a_parity, arg_b_parity, rst_n);
    end
    bfm.send_data(arg_a, arg_b, arg_a_parity, arg_b_parity, rst_n);
end

endmodule : mult_tpgen_module





