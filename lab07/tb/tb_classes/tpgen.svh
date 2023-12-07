class tpgen extends uvm_component;
    `uvm_component_utils (tpgen)
//------------------------------------------------------------------------------
// port for sending the transactions
//------------------------------------------------------------------------------
    uvm_put_port #(command_transaction) command_port;


//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
    endfunction : build_phase    
//------------------------------------------------------------------------------
// function prototypes
//------------------------------------------------------------------------------
    // pure virtual protected function bit signed [15:0] get_data();
    // pure virtual protected function bit [3:0] get_parity(bit signed [15:0] arg_a,
    //                                                      bit signed [15:0] arg_b);

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
	
		command_transaction command;
        command    = new("command");

		phase.raise_objection(this);

		command.rst_n = 1;
        command_port.put(command);
        command    = command_transaction::type_id::create("command");
	    repeat (10000) begin : random_loop
		    command.rst_n = 1;
            assert(command.randomize());
            command_port.put(command);
        end
        command    = new("command");
	    command.rst_n = 0;
	    // reset until DUT finish processing data
	    command_port.put(command);

	    phase.drop_objection(this);
    endtask : run_phase


endclass : tpgen
