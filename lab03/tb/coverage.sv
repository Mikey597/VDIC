module coverage(mult_bfm bfm);

logic signed 	[15:0] 	arg_a;
logic signed 	[15:0] 	arg_b;
logic               	a_parity_err;	
logic               	b_parity_err;
logic 					rst_n;

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

    option.name = "cg_data_corners1";

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
	
	option.name = "cg_data_zero1";
	
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
        @(posedge bfm.clk);
	    	arg_a = bfm.arg_a;
	    	arg_b = bfm.arg_b;
	    	a_parity_err = bfm.a_parity_err;
	    	b_parity_err = bfm.b_parity_err;
	    	rst_n = bfm.rst_n;
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

endmodule : coverage
