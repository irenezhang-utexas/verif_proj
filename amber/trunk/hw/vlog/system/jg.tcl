#Tcl script which can be used with JasperGold
#Use "source lab4_pb.tcl" in the console to source this script
clear -all

#Reading the files 
analyze -v2k uart.v
analyze -sv uart_jg.sv 

#Elaborating the design
elaborate -top uart

#Set the clock
clock i_clk

#Set Reset
reset -non_resettable_regs 0

#Prove all
prove -bg -all



