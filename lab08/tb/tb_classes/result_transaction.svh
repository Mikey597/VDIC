/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
class result_transaction extends uvm_transaction;

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------

    bit signed [31:0] result;
	bit result_parity;
	bit arg_parity_error;
//	bit exp_par_err;
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// transaction functions: do_copy, do_compare, convert2string
//------------------------------------------------------------------------------

    extern function void do_copy(uvm_object rhs);
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();

endclass : result_transaction

//------------------------------------------------------------------------------
// external functions
//------------------------------------------------------------------------------
function void result_transaction::do_copy(uvm_object rhs);
    result_transaction copied_transaction_h;
    assert(rhs != null) else
        $fatal(1,"Tried to copy null transaction");
    super.do_copy(rhs);
    assert($cast(copied_transaction_h, rhs)) else
        $fatal(1,"Failed cast in do_copy");
    result = copied_transaction_h.result;
    result_parity = copied_transaction_h.result_parity;
    arg_parity_error = copied_transaction_h.arg_parity_error;
endfunction : do_copy

function string result_transaction::convert2string();
    string s;
    s = $sformatf("result: %8h result_parity: %1h arg_parity_error: %1h", result, result_parity, arg_parity_error);
    return s;
endfunction : convert2string

function bit result_transaction::do_compare(uvm_object rhs, uvm_comparer comparer);
    result_transaction compared_transaction_h;
    bit same;

    if (rhs==null) `uvm_fatal("RESULT TRANSACTION",
            "Tried to do comparison to a null pointer");
    if (!$cast(compared_transaction_h, rhs))
        same = 0;
    else
        same = super.do_compare(rhs, comparer) &&
        (compared_transaction_h.result == result && 
	    compared_transaction_h.result_parity == result_parity && 
	    compared_transaction_h.arg_parity_error == arg_parity_error);
    return same;
endfunction : do_compare