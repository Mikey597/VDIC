`timescale 1ns/1ps

package mult_pkg;
    import uvm_pkg::*;
	`include "uvm_macros.svh"

//------------------------------------------------------------------------------
// package typedefs
//------------------------------------------------------------------------------
	typedef enum{
	    COLOR_BOLD_BLACK_ON_GREEN,
	    COLOR_BOLD_BLACK_ON_RED,
	    COLOR_BOLD_BLACK_ON_YELLOW,
	    COLOR_BOLD_BLUE_ON_WHITE,
	    COLOR_BLUE_ON_WHITE,
	    COLOR_DEFAULT
	} print_color_t;

	typedef struct packed {
		bit  		rst_n;
		bit signed [15:0] arg_a;
		bit signed [15:0] arg_b;
		bit		    arg_a_parity;
		bit		    arg_b_parity;
		bit			exp_par_err;
		bit 		a_err_flg;
		bit 		b_err_flg;
	} command_s;

	typedef struct packed {
		bit signed 	[31:0] 	    result;
		logic 					result_parity;
		logic 					arg_parity_error;
	} result_s;		

//------------------------------------------------------------------------------
// package functions
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

//------------------------------------------------------------------------------
// testbench classes
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// testbench classes
//------------------------------------------------------------------------------

`include "command_transaction.svh"
`include "corner_transaction.svh"
`include "result_transaction.svh"
`include "coverage.svh"
`include "tpgen.svh"
`include "scoreboard.svh"
`include "driver.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"
`include "env.svh"

//------------------------------------------------------------------------------
// test classes
//------------------------------------------------------------------------------

`include "random_test.svh"
`include "corner_test.svh"
	
endpackage : mult_pkg