/*
 */
module top;

//------------------------------------------------------------------------------
// Type definitions
//------------------------------------------------------------------------------


typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;

typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;

//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------

bit 		 		clk;
bit 		 		rst_n;
bit signed [15:0]   arg_a;
bit 		 		arg_a_parity;     // parity bit for arg b (even parity)
bit signed [15:0]   arg_b;       
bit 		 		arg_b_parity;      // parity bit for arg_a (even parity)
bit signed [31:0]   result;            // result of multiplication
bit 		 		result_parity;     // parity bit for result (even parity)

logic  		 		req;               // arguments are valid
logic   	 		ack;               // acknowledge for the arguments
logic 		 		result_rdy;        // result is ready
logic 		 		arg_parity_error;  // set to 1 when input data has parity errors

bit				    a_parity_err;
bit				    b_parity_err;
bit				    exp_parity_err;
test_result_t        test_result = TEST_PASSED;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

vdic_dut_2023 DUT (.rst_n, .clk, .arg_a, .arg_a_parity, .arg_b, .arg_b_parity, .req, .ack, .result, .result_parity, .result_rdy, .arg_parity_error);

//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

// Covergroup checking parity bits and reset
covergroup parity_rst_cov;

    option.name = "parity_err_cov";

    a_par_err: coverpoint a_parity_err {
        bins a_parity_err_0 = {'b0};
	    bins a_parity_err_1 = {'b1};
    }
    
    b_par_err: coverpoint b_parity_err {
        bins b_parity_err_0= {'b0};
	    bins b_parity__err_1 = {'b1};
    }
    
    c_rst: coverpoint rst_n {
	   bins rst_n = {['b0:'b1]}; 
    }
    
    par_err_cross: cross a_par_err, b_par_err {
	    
	    bins err_cross = binsof (a_par_err) && binsof (b_par_err);
	    
    }
    
endgroup

// Covergroup checking for min and max arguments of the ALU
covergroup cg_data_corners;

    option.name = "cg_data_corners";

    a_data: coverpoint arg_a {
	    bins min= {16'sh8000};
        bins max= {16'sh7FFF};
	    bins others= {[16'sh8001:16'sh7FFE]};
    }

    b_data: coverpoint arg_b {
	    bins min= {16'sh8000};
        bins max= {16'sh7FFF};
	    bins others= {[16'sh8001:16'sh7FFE]};
    }
    
    par_data_corn_cross: cross a_data, b_data {
	    
	    bins max_data_cross = binsof (a_data.max) && binsof (b_data.max);
	    bins min_data_cross = binsof (a_data.min) && binsof (b_data.min);  
    }
endgroup

covergroup cg_data_zero;
	
	option.name = "cd_data_zero";
	
	a_data_zero: coverpoint arg_a {
	bins zero= {16'sh0000};
	bins others= {[16'sh8000:16'sh0000]};	
	bins others_1= {[16'sh0000:16'sh7FFF]};	
	}
	b_data_zero: coverpoint arg_b {
	bins zero= {16'sh0000};
	bins others= {[16'sh8000:16'sh0000]};	
	bins others_1= {[16'sh0000:16'sh7FFF]};		
	}
	
    par_data_corn_cross: cross a_data_zero, b_data_zero {
	    
	    bins zero_a_cross = binsof (a_data_zero.zero) && binsof (b_data_zero.others);
	    bins zero_b_cross = binsof (a_data_zero.others_1) && binsof (b_data_zero.zero);  
    }	
	
endgroup

parity_rst_cov         c_par_rst;
cg_data_corners        c_7FFF_8000;
cg_data_zero           c_0000;
initial begin : coverage
    c_par_rst      = new();
    c_7FFF_8000    = new();
	c_0000         = new();
    forever begin : sample_cov
        @(posedge clk);
            c_par_rst.sample();
            c_7FFF_8000.sample();
            c_0000.sample();
            /* #1step delay is necessary before checking for the coverage
             * as the .sample methods run in parallel threads
             */
            #1step; 
            if($get_coverage() == 100) break; //disable, if needed
            
            // you can print the coverage after each sample
//            $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
    end
end : coverage

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------
initial begin : clk_gen_blk
    clk = 0;
    forever begin : clk_frv_blk
        #10;
        clk = ~clk;
    end
end

// timestamp monitor
initial begin
    longint clk_counter;
    clk_counter = 0;
    forever begin
        @(posedge clk) clk_counter++;
        if(clk_counter % 1000 == 0) begin
	        `ifdef DEBUG
            $display("%0t Clock cycles elapsed: %0d", $time, clk_counter);
	        `endif
        end
    end
end

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

// Random data generation functions


//---------------------------------
function logic signed [15:0] get_data();
    bit [2:0] zero_ones;

    zero_ones = 3'($random);

    if (zero_ones == 3'b000)
        return 16'sh8000;
    else if (zero_ones == 3'b111)
        return 16'sh7FFF;
    else
        return 16'($random);
endfunction : get_data

function bit [3:0] get_parity(bit signed [15:0] arg_a, bit signed [15:0] arg_b);

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

//------------------------
// Tester main

initial begin : tester
	bit signed [31:0] expected;
	bit exp_parity;
    reset();
	
    repeat (100000) begin : tester_main_blk
        @(negedge clk);
        arg_a      = get_data();
        arg_b      = get_data();
	    {arg_a_parity,arg_b_parity,a_parity_err,b_parity_err} = get_parity(arg_a, arg_b);
	    
	    if(a_parity_err || b_parity_err) begin
		    exp_parity_err = 1;
		end
	    else begin
		    exp_parity_err = 0;
	    end
	    
	    req = 1'b1;
	    while(!ack )@(negedge clk);
	   	req = 1'b0;
	    while(!result_rdy)@(negedge clk);
	    
	    expected = get_expected(arg_a, arg_b);
	    exp_parity = get_expected_parity(result);

	        if (arg_parity_error === 1'b1) begin
		        `ifdef DEBUG
                $display("argument parity error for arg_a=%h arg_b=%h a_parity=%b b_parity=%b", arg_a, arg_b, arg_a_parity, arg_b_parity);
		        `endif
	        end
	        else begin
                assert(result_parity === exp_parity) begin
                    if(result === expected) begin
	                    `ifdef DEBUG
                        $display("Test passed for arg_a=%h arg_b=%h a_parity=%b b_parity=%b", arg_a, arg_b, arg_a_parity, arg_b_parity);
	                    `endif
                    end
                    else begin
	                    `ifdef DEBUG
                        $display("Test FAILED for arg_a=%h arg_b=%h a_parity=%b b_parity=%b", arg_a, arg_b, arg_a_parity, arg_b_parity);
                        $display("Expected: %d  received: %d", expected, result);
	                    `endif
                        test_result = TEST_FAILED;
                    end;
                end	
                else begin
	                `ifdef DEBUG
                    $display("Test FAILED, wrong parity bit for arg_a=%h arg_b=%h a_parity=%b b_parity=%b", arg_a, arg_b, arg_a_parity, arg_b_parity);
                    $display("Expected parity bit: %d  received: %d", exp_parity, result_parity);
	                `endif
                    test_result = TEST_FAILED;
                end
            end 
    end : tester_main_blk
    $finish;
end : tester

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------

task reset();
	`ifdef DEBUG
    $display("%0t DEBUG: reset", $time);
	`endif
    rst_n = 1'b0;
    @(negedge clk);
    	rst_n = 1'b1;
endtask : reset

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

function bit [31:0] get_expected(
        bit signed [15:0] arg_a,
        bit signed [15:0] arg_b
	);
	
    bit signed [31:0] ret;
	
    //$display("%0t DEBUG: get_expected(%0d,%0d)",$time, arg_a, arg_b);
    
    ret    = arg_a * arg_b;
    return(ret);
	
endfunction : get_expected

// calculate expected parity bit 

function logic get_expected_parity( bit signed [31:0] expected);
	
	bit ret;
	
	ret = ^expected;
	
	return(ret);
	
endfunction : get_expected_parity
//------------------------------------------------------------------------------

final begin : finish_of_the_test
    print_test_result(test_result);
end

//------------------------------------------------------------------------------
// Other functions
//------------------------------------------------------------------------------

// used to modify the color of the text printed on the terminal
function void set_print_color ( print_color_t c );
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

function void print_test_result (test_result_t r);
    if(r == TEST_PASSED) begin
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

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------

typedef struct packed {
    bit  [15:0] arg_a;
    bit  [15:0] arg_b;
	bit		    exp_parity_err;
    bit  [31:0] result;
} data_packet_t;

data_packet_t               sb_data_q   [$];

always @(posedge clk) begin:scoreboard_fe_blk
	    if(req == 1'b1) begin
                sb_data_q.push_front(
                    data_packet_t'({arg_a,arg_b,exp_parity_err,get_expected(arg_a,arg_b)})
                );
        end
end: scoreboard_fe_blk

always @(negedge clk) begin : scoreboard_be_blk
    if(result_rdy) begin:verify_result
        data_packet_t dp;

        dp = sb_data_q.pop_back();
	    if(!dp.exp_parity_err) begin
	        CHK_RESULT: assert(result === dp.result) begin
	           `ifdef DEBUG
	            $display("%0t Test passed for arg_a=%0d arg_b=%0d  exp_parity_err=%0d", $time, dp.arg_a, dp.arg_b, dp.exp_parity_err);
	           `endif
	        end
	        else begin
	            test_result = TEST_FAILED;
	            $error("%0t Test FAILED for arg_a=%0d arg_b=%0d exp_parity_err=%0d\nExpected: %d  received: %d parity_err: %d",
	            $time, dp.arg_a, dp.arg_b, dp.exp_parity_err, dp.result, result, arg_parity_error);
	        end;
	    end
	    else if (dp.exp_parity_err === arg_parity_error) begin
		    `ifdef DEBUG
	        $display("%0t Test passed for arg_a=%0d arg_b=%0d  arg_a_parity=%0d arg_b_parity=%0d", $time, dp.arg_a, dp.arg_b, dp.arg_a_parity, dp.arg_b_parity);
	        `endif
	    end
	    else begin
	        test_result = TEST_FAILED;
	        $error("%0t Test FAILED for arg_a=%0d arg_b=%0d exp_parity_err=%0d\nExpected: %d  received: %d parity_err: %d",
	        $time, dp.arg_a, dp.arg_b, dp.exp_parity_err, dp.result, result, arg_parity_error);		    
	    end    
    end
end : scoreboard_be_blk

endmodule : top
