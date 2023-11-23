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
class corner_tpgen extends random_tpgen;
    `uvm_component_utils(corner_tpgen)

//------------------------------------------------------------------------------
// function: get_op - generate random opcode for the tpgen
//------------------------------------------------------------------------------
protected function bit signed [15:0] get_data();
    bit [1:0] zero_ones;

    zero_ones = 2'($random);

    if (zero_ones == 2'b00)
        return 16'sh8000;
    else if (zero_ones == 2'b01)
        return 16'sh7FFF;
    else if (zero_ones == 2'b10 )
        return 16'sh0000;
    else 
        return 16'sh0000;
endfunction : get_data
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new


endclass : corner_tpgen
