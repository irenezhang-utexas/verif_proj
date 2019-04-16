# Begin_DVE_Session_Save_Info
# DVE view(Wave.1 ) session
# Saved on Wed Jan 2 14:33:35 2013
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Wave.1: 46 signals
# End_DVE_Session_Save_Info

# DVE version: E-2011.03
# DVE build date: Feb 23 2011 21:19:20


#<Session mode="View" path="/home/usr1/shahrzad/VLSI2/source/debug/session.inter.vpd.tcl" type="Debug">

#<Database>

#</Database>

# DVE View/pane content session: 

# Begin_DVE_Session_Save_Info (Wave.1)
# DVE wave signals session
# Saved on Wed Jan 2 14:33:35 2013
# 46 signals
# End_DVE_Session_Save_Info

# DVE version: E-2011.03
# DVE build date: Feb 23 2011 21:19:20


#Add ncecessay scopes
gui_load_child_values {tb.u_system.u_amber.u_coprocessor}

gui_set_time_units 1s
set Group1 Group1
if {[gui_sg_is_group -name Group1]} {
    set Group1 [gui_sg_generate_new_name]
}

gui_sg_addsignal -group "$Group1" { {Sim:tb.u_system.u_amber.u_coprocessor.quick_n_reset} {Sim:tb.u_system.u_amber.u_coprocessor.i_clk} {Sim:tb.u_system.u_amber.u_coprocessor.i_access_stall} {Sim:tb.u_system.u_amber.u_coprocessor.i_copro_opcode1} {Sim:tb.u_system.u_amber.u_coprocessor.i_copro_opcode2} {Sim:tb.u_system.u_amber.u_coprocessor.i_copro_crn} {Sim:tb.u_system.u_amber.u_coprocessor.i_copro_crm} {Sim:tb.u_system.u_amber.u_coprocessor.i_copro_num} {Sim:tb.u_system.u_amber.u_coprocessor.i_copro_operation} {Sim:tb.u_system.u_amber.u_coprocessor.i_copro_write_data} {Sim:tb.u_system.u_amber.u_coprocessor.i_fault} {Sim:tb.u_system.u_amber.u_coprocessor.i_fault_status} {Sim:tb.u_system.u_amber.u_coprocessor.i_fault_address} {Sim:tb.u_system.u_amber.u_coprocessor.o_copro_read_data} {Sim:tb.u_system.u_amber.u_coprocessor.o_cache_enable} {Sim:tb.u_system.u_amber.u_coprocessor.o_cache_flush} {Sim:tb.u_system.u_amber.u_coprocessor.o_cacheable_area} {Sim:tb.u_system.u_amber.u_coprocessor.copro15_reg1_write} {Sim:tb.u_system.u_amber.u_coprocessor.cache_control} {Sim:tb.u_system.u_amber.u_coprocessor.cacheable_area} {Sim:tb.u_system.u_amber.u_coprocessor.updateable_area} {Sim:tb.u_system.u_amber.u_coprocessor.disruptive_area} {Sim:tb.u_system.u_amber.u_coprocessor.fault_status} {Sim:tb.u_system.u_amber.u_coprocessor.fault_address} {Sim:tb.u_system.u_amber.fetch_stall} {Sim:tb.u_system.u_amber.mem_stall} {Sim:tb.u_system.u_amber.u_mem.uncached_wb_wait} {Sim:tb.u_system.u_amber.u_mem.cache_stall} }
set Group2 Group2
if {[gui_sg_is_group -name Group2]} {
    set Group2 [gui_sg_generate_new_name]
}

gui_sg_addsignal -group "$Group2" { {Sim:tb.u_system.u_amber.u_fetch.cache_stall} {Sim:tb.u_system.u_amber.u_fetch.o_wb_req} {Sim:tb.u_system.u_amber.u_fetch.wb_req_r} {Sim:tb.u_system.u_amber.u_fetch.i_wb_ready} {Sim:tb.u_system.u_amber.u_fetch.icache_wb_req} {Sim:tb.u_system.u_amber.u_fetch.uncached_instruction_read} {Sim:tb.u_system.u_amber.u_fetch.i_iaddress_valid} {Sim:tb.u_system.u_amber.u_fetch.sel_cache} {Sim:tb.u_system.u_amber.u_execute.o_iaddress_valid} {Sim:tb.u_system.u_amber.u_execute.iaddress_update} {Sim:tb.u_system.u_amber.u_execute.o_iaddress_nxt} {Sim:tb.u_system.u_amber.u_execute.pc_dmem_wen} {Sim:tb.u_system.u_amber.u_execute.i_access_stall} {Sim:tb.u_system.u_amber.u_execute.i_conflict} {Sim:tb.u_system.u_amber.u_fetch.i_system_rdy} {Sim:tb.u_system.u_amber.u_fetch.wait_wb} }
set Group3 Group3
if {[gui_sg_is_group -name Group3]} {
    set Group3 [gui_sg_generate_new_name]
}

gui_sg_addsignal -group "$Group3" { {Sim:tb.u_system.u_amber.u_mem.uncached_wb_wait} {Sim:tb.u_system.u_amber.u_mem.cache_stall} }
if {![info exists useOldWindow]} { 
	set useOldWindow true
}
if {$useOldWindow && [string first "Wave" [gui_get_current_window -view]]==0} { 
	set Wave.1 [gui_get_current_window -view] 
} else {
	gui_open_window Wave
set Wave.1 [ gui_get_current_window -view ]
}
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 1853445815 4217421615
gui_list_add_group -id ${Wave.1} -after {New Group} [list $Group1]
gui_list_add_group -id ${Wave.1} -after {New Group} [list $Group2]
gui_list_add_group -id ${Wave.1} -after {New Group} [list $Group3]
gui_list_select -id ${Wave.1} {tb.u_system.u_amber.u_mem.uncached_wb_wait }
gui_seek_criteria -id ${Wave.1} {Any Edge}


gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group $Group3  -item tb.u_system.u_amber.u_mem.cache_stall -position below

gui_marker_move -id ${Wave.1} {C1} 3034350625
gui_view_scroll -id ${Wave.1} -vertical -set 1001
gui_show_grid -id ${Wave.1} -enable false
#</Session>

