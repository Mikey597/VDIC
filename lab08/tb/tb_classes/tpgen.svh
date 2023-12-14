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


		phase.raise_objection(this);
        command    = new("command");
		command.rst_n = 1;
        command_port.put(command);
	    
        command    = command_transaction::type_id::create("command");

        set_print_color(COLOR_BOLD_BLACK_ON_YELLOW);
        `uvm_info("TPGEN", $sformatf("*** Created transaction type: %s",command.get_type_name()), UVM_MEDIUM);
        set_print_color(COLOR_DEFAULT);

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


//	task run_phase(uvm_phase phase);
//		command_transaction command;
//	
//		phase.raise_objection(this);
//		command = new("command");
//		command.rst_n = 1;
//        command_port.put(command);
//		
//		command = command_transaction::type_id::create("command");
//		
//        set_print_color(COLOR_BOLD_BLACK_ON_YELLOW);
//        `uvm_info("TPGEN", $sformatf("*** Created transaction type: %s",command.get_type_name()), UVM_MEDIUM);
//        set_print_color(COLOR_DEFAULT);
//		
//	    repeat (5000) begin
//            assert(command.randomize());
//            command_port.put(command);
//	    end
//	    
//	    command = new("command");
//	    command.rst_n = 1;
//        command_port.put(command);
//
////	    #500;
//	    phase.drop_objection(this);
//	endtask : run_phase


endclass : tpgen
