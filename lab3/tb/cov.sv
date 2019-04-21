`include "uvm_macros.svh"
package coverage;
import sequences::*;
import uvm_pkg::*;

class wb2uart_subscriber extends uvm_subscriber #(wb2uart);
    `uvm_component_utils(wb2uart)

    logic [31:0] 	i_wb_adr;
    logic		i_wb_we;
    logic		i_wb_stb;

    covergroup inputs;

	 



    endgroup: inputs

    function new(string name, uvm_component parent);
        super.new(name,parent);
        /* TODO: Uncomment*/
        inputs=new;
        
    endfunction: new


    function void write(wb2uart t);
        i_wb_adr ={t.i_wb_adr};
        i_wb_se  ={t.i_wb_we};
        i_wb_stb ={t.i_wb_stb};
        inputs.sample();
        
    endfunction: write

endclass: dut_subscriber_in


class dut_subscriber_in extends uvm_subscriber #(wb2uart);
    `uvm_component_utils(alu_subscriber_out)


endclass: dut_subscriber_in


endpackage: coverage
