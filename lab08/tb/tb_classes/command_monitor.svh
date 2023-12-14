class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;
    uvm_analysis_port #(command_transaction) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------

    function void build_phase(uvm_phase phase);
        mult_agent_config agent_config_h;

        // get the BFM
        if(!uvm_config_db #(mult_agent_config)::get(this, "", "config", agent_config_h))
            `uvm_fatal("COMMAND MONITOR", "Failed to get CONFIG");

        // pass the command_monitor handler to the BFM
        agent_config_h.bfm.command_monitor_h = this;

        ap = new("ap",this);
    endfunction : build_phase
//------------------------------------------------------------------------------
// access function for BMF
//------------------------------------------------------------------------------

    function void write_to_monitor(bit signed [15:0] arg_a,bit signed [15:0] arg_b, bit arg_a_parity,bit arg_b_parity, bit rst_n);
        command_transaction cmd;
        `uvm_info("COMMAND MONITOR",$sformatf("MONITOR: arg_a= %h, arg_b= %h, arg_a_parity= %d, arg_b_parity= %d",
                    arg_a, arg_b, arg_a_parity, arg_b_parity), UVM_HIGH);
        cmd    = new("cmd");
        cmd.arg_a  = arg_a;
        cmd.arg_b  = arg_b;
        cmd.arg_a_parity = arg_a_parity;
        cmd.arg_b_parity = arg_b_parity;
	    cmd.rst_n = rst_n;
        ap.write(cmd);
    endfunction : write_to_monitor


endclass : command_monitor