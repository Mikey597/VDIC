class random_test extends uvm_test;
    `uvm_component_utils(random_test)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    env env_h;

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
        env_h = env::type_id::create("env",this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// end_of_elaboration_phase
//------------------------------------------------------------------------------
    function void end_of_elaboration_phase(uvm_phase phase);
        command_transaction tmp;               // transaction object to check the type generated

        // other printers available:
        // - uvm_default_line_printer
        // - uvm_default_tree_printer
        set_print_color(COLOR_BLUE_ON_WHITE);
        this.print(uvm_default_table_printer); // print test env topology
        set_print_color(COLOR_DEFAULT);

        // printing the type of the transaction generated
        tmp = command_transaction::type_id::create("command_transaction", this);
        set_print_color(COLOR_BOLD_BLACK_ON_YELLOW);
        `uvm_info("COMMAND TRANSACTION", tmp.get_type_name(), UVM_NONE)
        set_print_color(COLOR_DEFAULT);
    endfunction : end_of_elaboration_phase
    
endclass


