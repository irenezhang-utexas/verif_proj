class uart_dut_config extends uvm_object;
    `uvm_object_utils(uart_dut_config)

    virtual uart_in dut_vi_in;
    virtual uart_out dut_vi_out;

endclass: uart_dut_config


class amber_dut_config extends uvm_object;
    `uvm_object_utils(amber_dut_config)

    virtual dut_in dut_vi_in;
    virtual dut_out dut_vi_out;

endclass: amber_dut_config


