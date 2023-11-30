class scoreboard extends uvm_subscriber #(result_s);
    `uvm_component_utils(scoreboard)

//------------------------------------------------------------------------------
// local typdefs
//------------------------------------------------------------------------------
    protected typedef enum bit {
        TEST_PASSED,
        TEST_FAILED
    } test_result_t;
	
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

//protected virtual mult_bfm bfm;
    uvm_tlm_analysis_fifo #(command_s) cmd_f;
    protected test_result_t test_result = TEST_PASSED; // the result of the current test


//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

    protected function bit [31:0] get_expected(
                                                bit signed [15:0] arg_a,
                                                bit signed [15:0] arg_b
                                                );
        
        bit signed [31:0] ret;
        
        //$display("%0t DEBUG: get_expected(%0d,%0d)",$time, arg_a, arg_b);
        
        ret    = arg_a * arg_b;
        return(ret);
        
    endfunction : get_expected

// calculate expected parity bit 

protected function logic get_expected_parity( bit signed [31:0] expected);
	
	bit ret;
	
	ret = ^expected;
	
	return(ret);
	
endfunction : get_expected_parity

protected function logic get_expected_parity_error(
										bit signed [15:0] arg_a,
										bit signed [15:0] arg_b,
										bit arg_a_parity,
										bit arg_b_parity
										);
	bit exp_par_err;
	
	if(arg_a_parity == ^arg_a && arg_b_parity == ^arg_b) begin
		exp_par_err = 0;
	end
	else exp_par_err = 1;

	return exp_par_err;
	
endfunction : get_expected_parity_error

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
    function void write(result_s t);
	    
        bit signed [31:0] expected_result;
		logic expected_parity;
	    logic expected_parity_error;

        command_s cmd;
	    cmd.rst_n = 0;
        cmd.arg_a = 0;
        cmd.arg_b = 0;
	    cmd.arg_a_parity = 0;
	    cmd.arg_b_parity = 0;
	    
        do
	        begin
            if (!cmd_f.try_get(cmd))begin
                $fatal(1, "Missing command in self checker");
            end
	        end 
        while (cmd.rst_n == 0);	// get commands until rst_n == 0

        expected_result = get_expected(cmd.arg_a, cmd.arg_b);
	    expected_parity = get_expected_parity(expected_result);
	    expected_parity_error = get_expected_parity_error(cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity);
            if(!expected_parity_error) begin
                CHK_RESULT: assert(t.result === expected_result) begin
                `ifdef DEBUG
                    $display("%0t Test passed for arg_a=%0d arg_b=%0d  exp_parity_err=%0d", $time, cmd.arg_a, cmd.arg_b, expected_parity_error);
                `endif
                end
                else begin
                    test_result = TEST_FAILED;
                    $error("Test FAILED for A=%0d B=%0d Ap=%0d Bp=%0d\nExpected: %d  received: %d",
                    $time, cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity, expected_parity_error, t.result_parity);
                end;
            end
            else if (t.arg_parity_error === expected_parity_error) begin
                `ifdef DEBUG
                $display("%0t Test passed for arg_a=%0d arg_b=%0d  arg_a_parity=%0d arg_b_parity=%0d", $time, cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity);
                `endif
            end
            else begin
                test_result = TEST_FAILED;
                $error("%0t Test FAILED for arg_a=%0d arg_b=%0d exp_parity_err=%0d\nExpected: %d  received: %d parity_err: %d",
                $time, cmd.arg_a, cmd.arg_b, expected_parity_error, t.result, expected_result, t.arg_parity_error);		    
            end  
	endfunction : write

//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
protected function void print_test_result (test_result_t r);
    if(test_result == TEST_PASSED) begin
        set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
        $write ("-----------------------------------\n");
        $write ("----------- Test PASSED -----------\n");
        $write ("-----------------------------------");
        set_print_color(COLOR_DEFAULT);
        $write ("\n");
    end
    else begin
        set_print_color(COLOR_BOLD_BLACK_ON_RED);
        $write ("-----------------------------------\n");
        $write ("----------- Test FAILED -----------\n");
        $write ("-----------------------------------");
        set_print_color(COLOR_DEFAULT);
        $write ("\n");
    end
endfunction

function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    print_test_result(test_result);
endfunction : report_phase


endclass : scoreboard