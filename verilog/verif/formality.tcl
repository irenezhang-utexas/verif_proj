
set golden_filelist "/home/usr1/shahrzad/VLSI2/source/a25_write_back.v"

set revised_filelist "/home/usr1/shahrzad/VLSI2/dc_netlist/a25_write_back.gate.v"

set library_file "/home/usr1/shahrzad/VLSI2/Artisan/verilog/tsmc18.v"



## These two commands are part of our flow to load the design into Conformal

set synopsys_auto_setup true
read_verilog -r $golden_filelist
set_top r:/WORK/a25_write_back

read_db "/home/usr1/shahrzad/VLSI2/Artisan/synopsys/typical.db"

read_verilog -i $revised_filelist
set_top i:/WORK/a25_write_back

#report_hdlin_mismatches
#report_designs

#print_message_info


verify

# Use the hierarchical compare method...
#write_hierarchical_verification_script -replace ivm-formality.hier.tcl

#source ivm-formality.hier.tcl

report_unmatched_points

#quit
