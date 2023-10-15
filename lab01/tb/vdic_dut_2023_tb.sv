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

logic 		 		clk;
logic 		 		rst_n;
logic signed [15:0] arg_a;
logic 		 		arg_a_parity;     // parity bit for arg b (even parity)
logic signed [15:0] arg_b;       
logic 		 		arg_b_parity;      // parity bit for arg_a (even parity)
logic  		 		req;               // arguments are valid
logic   	 		ack;               // acknowledge for the arguments
logic signed [31:0] result;            // result of multiplication
logic 		 		result_parity;     // parity bit for result (even parity)
logic 		 		result_rdy;        // result is ready
logic 		 		arg_parity_error;  // set to 1 when input data has parity errors

test_result_t        test_result = TEST_PASSED;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

vdic_dut_2023 DUT (.rst_n, .clk, .arg_a, .arg_a_parity, .arg_b, .arg_b_parity, .req, .ack, .result, .result_parity, .result_rdy, .arg_parity_error);

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
            $display("%0t Clock cycles elapsed: %0d", $time, clk_counter);
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

function logic get_parity(logic signed [15:0] arg);
	logic  arg_parity;
	assign arg_parity = ^arg;
	return arg_parity;
endfunction	: get_parity

//------------------------
// Tester main

initial begin : tester
	logic signed [31:0] expected;
	logic exp_parity;
	
    reset();
	
    repeat (1000) begin : tester_main_blk
        @(negedge clk);
        arg_a      = get_data();
	    arg_a_parity = get_parity(arg_a);
        arg_b      = get_data();
	    arg_b_parity = get_parity(arg_b);
	    req = 1'b1;
	    
	    wait( ack );
	    req = 1'b0;
	    wait(result_rdy);
	     
        expected = get_expected(arg_a, arg_b);
	    exp_parity = check_parity(result);
	            
	        if (arg_parity_error === 1'b1) begin
                $display("argument parity error for arg_a=%h arg_b=%h a_parity=%b b_parity=%b", arg_a, arg_b, arg_a_parity, arg_b_parity);
	        end
	        
	        assert(result_parity === exp_parity) begin
            	if(result === expected) begin
                   	$display("Test passed for arg_a=%h arg_b=%h a_parity=%b b_parity=%b", arg_a, arg_b, arg_a_parity, arg_b_parity);
               	end
               	else begin
	               	$display("Test FAILED for arg_a=%h arg_b=%h a_parity=%b b_parity=%b", arg_a, arg_b, arg_a_parity, arg_b_parity);
               		$display("Expected: %d  received: %d", expected, result);
               		test_result = TEST_FAILED;
               	end;
            end	
	        else begin
	            $display("Test FAILED, wrong parity bit for arg_a=%h arg_b=%h a_parity=%b b_parity=%b", arg_a, arg_b, arg_a_parity, arg_b_parity);
	            $display("Expected parity bit: %d  received: %d", exp_parity, result_parity);
	            test_result = TEST_FAILED;
            end 
    end : tester_main_blk
    $finish;
end : tester

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------

task reset();
    $display("%0t DEBUG: reset", $time);
    rst_n = 1'b0;
    @(negedge clk);
    	rst_n = 1'b1;
endtask : reset

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------

function logic [31:0] get_expected(
        logic signed [15:0] arg_a,
        logic signed [15:0] arg_b
	);
	
    logic signed [31:0] ret;
	
    $display("%0t DEBUG: get_expected(%0d,%0d)",$time, arg_a, arg_b);
    
    ret    = arg_a * arg_b;
    return(ret);
	
endfunction : get_expected

// calculate expected parity bit 

function logic check_parity( logic signed [31:0] expected);
	
	logic ret;
	
	ret = ^expected;
	
	return(ret);
	
endfunction : check_parity
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


endmodule : top
