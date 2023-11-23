class random_tpgen extends base_tpgen;
    `uvm_component_utils (random_tpgen)
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// function: get_data - generate random data for the tpgen
//------------------------------------------------------------------------------
protected function bit signed [15:0] get_data();
        return 16'($random);
endfunction : get_data

//------------------------------------------------------------------------------
// function: get_parity - generate correct or random wrong parity bit
//------------------------------------------------------------------------------

protected function bit [3:0] get_parity(bit signed [15:0] arg_a,
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

endclass : random_tpgen






