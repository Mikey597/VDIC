virtual class base_tpgen extends uvm_component;

//------------------------------------------------------------------------------
// port for sending the transactions
//------------------------------------------------------------------------------
    uvm_put_port #(command_s) command_port;


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
        command_port = new("command_port", this);
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
	
		command_s command;

		phase.raise_objection(this);
		command.rst_n = 0;
        command_port.put(command);
		command.rst_n = 1;


	    repeat (10000) begin : random_loop
	        command.arg_a = get_data();
	        command.arg_b = get_data();
		    {command.arg_a_parity,command.arg_b_parity,command.a_err_flg,command.b_err_flg} = get_parity(command.arg_a,command.arg_b);
		    
            command_port.put(command);		    
	    end : random_loop
	    command.rst_n = 0;
	    // reset until DUT finish processing data
	    command_port.put(command);
	    phase.drop_objection(this);
    endtask : run_phase


endclass : base_tpgen
