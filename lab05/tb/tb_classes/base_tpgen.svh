virtual class base_tpgen extends uvm_component;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
//------------------------------------------------------------------------------
// function prototypes
//------------------------------------------------------------------------------
    pure virtual protected function bit signed [15:0] get_data();
    pure virtual protected function bit [3:0] get_parity(bit signed [15:0] arg_a,
                                                         bit signed [15:0] arg_b);

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
		bit signed 	[15:0] 	arg_a;
        bit signed 	[15:0] 	arg_b;   
		bit               	arg_a_parity;
		bit               	arg_b_parity;
		bit					a_err_flg;
	    bit					b_err_flg;
		logic signed 	[31:0] 	result;
		logic               	result_parity;
	
		phase.raise_objection(this);
	    bfm.reset();
		
	    repeat (10000) begin : random_loop
	        arg_a = get_data();
	        arg_b = get_data();
		    {arg_a_parity,arg_b_parity,a_err_flg,b_err_flg} = get_parity(arg_a,arg_b);
		    
	        bfm.send_data(arg_a, arg_b, arg_a_parity, arg_b_parity);
		    bfm.error_record(a_err_flg, b_err_flg);
	    end : random_loop
	    
	    // reset until DUT finish processing data
	    bfm.send_data(arg_a, arg_b, arg_a_parity, arg_b_parity);
	    bfm.reset();

        phase.drop_objection(this);

    endtask : run_phase


endclass : base_tpgen
