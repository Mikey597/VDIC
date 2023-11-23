class scoreboard extends uvm_component;
    `uvm_component_utils(scoreboard)

//------------------------------------------------------------------------------
// local typdefs
//------------------------------------------------------------------------------
protected typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;
	
protected typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;	

protected typedef struct packed {
    bit  [15:0] arg_a;
    bit  [15:0] arg_b;
	bit		    arg_a_parity;
	bit		    arg_b_parity;
	bit			exp_par_err;
    bit  [31:0] result;
} data_packet_t;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

protected virtual mult_bfm bfm;
protected test_result_t   test_result = TEST_PASSED; // the result of the current test

//fifo
protected data_packet_t   sb_data_q   [$];

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

protected function logic get_expected_parity( bit signed [31:0] expected );
	
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
// Scoreboard
//------------------------------------------------------------------------------

protected task store_cmd();
    forever begin : scoreboard_fe_blk
        @(posedge bfm.clk) 
        if(bfm.req == 1'b1) begin
                sb_data_q.push_front(
                    data_packet_t'({bfm.arg_a,bfm.arg_b,bfm.arg_a_parity,bfm.arg_b_parity,get_expected_parity_error(bfm.arg_a,bfm.arg_b,bfm.arg_a_parity,bfm.arg_b_parity),get_expected(bfm.arg_a,bfm.arg_b)})
                );
        end
    end : scoreboard_fe_blk
endtask

protected task process_data_from_dut();
    forever begin : scoreboard_be_blk
        @(negedge bfm.clk)
        if(bfm.result_rdy) begin:verify_result
            data_packet_t dp;
            
            dp = sb_data_q.pop_back();
            
            if(!dp.exp_par_err) begin
                CHK_RESULT: assert(bfm.result === dp.result) begin
                `ifdef DEBUG
                    $display("%0t Test passed for arg_a=%0d arg_b=%0d  exp_parity_err=%0d", $time, dp.arg_a, dp.arg_b, dp.exp_parity_err);
                `endif
                end
                else begin
                    test_result = TEST_FAILED;
                    $error("%0t Test FAILED for arg_a=%0d arg_b=%0d exp_parity_err=%0d\nExpected: %d  received: %d parity_err: %d",
                    $time, dp.arg_a, dp.arg_b, dp.exp_par_err, dp.result, bfm.result, bfm.arg_parity_error);
                end;
            end
            else if (dp.exp_par_err === bfm.arg_parity_error) begin
                `ifdef DEBUG
                $display("%0t Test passed for arg_a=%0d arg_b=%0d  arg_a_parity=%0d arg_b_parity=%0d", $time, dp.arg_a, dp.arg_b, dp.arg_a_parity, dp.arg_b_parity);
                `endif
            end
            else begin
                test_result = TEST_FAILED;
                $error("%0t Test FAILED for arg_a=%0d arg_b=%0d exp_parity_err=%0d\nExpected: %d  received: %d parity_err: %d",
                $time, dp.arg_a, dp.arg_b, dp.exp_par_err, dp.result, bfm.result, bfm.arg_parity_error);		    
            end    
        end
    end : scoreboard_be_blk
endtask

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
        fork
            store_cmd();
            process_data_from_dut();
        join_none
    endtask : run_phase


//------------------------------------------------------------------------------
// used to modify the color printed on the terminal
//------------------------------------------------------------------------------

protected function void set_print_color ( print_color_t c );
    string ctl;
    case(c)
        COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
        COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
        COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
        COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
        COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
        COLOR_DEFAULT : ctl              = "\033\[0m\n";
        default : begin
            $error("set_print_color: bad argument");
            ctl                          = "";
        end
    endcase
    $write(ctl);
endfunction

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