# Copyright 2024 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

# Backend constraints

############
## Global ##
############

#source src/instances.tcl


#############################
## Driving Cells and Loads ##
#############################

# As a default, drive multiple GPIO pads and be driven by one.
# accomodate for driving up to 2 74HC pads plus a 5pF trace
set_load 0.5 [all_outputs]
#set_driving_cell [all_inputs] -lib_cell sg13g2_IOPadOut16mA pad


##################
## Input Clocks ##
##################
puts "Core Clocks..."

# We target 80 MHz
set TCK_SYS 12.5
create_clock -name clk_sys -period $TCK_SYS [get_ports clk_i]

# If core has separate debug clock interface
if {[llength [get_ports -quiet jtag_tck_i]] > 0} {
    set TCK_JTG 20.0
    create_clock -name clk_jtg -period $TCK_JTG [get_ports jtag_tck_i]
}

##################################
## Clock Groups & Uncertainties ##
##################################

# Define which clocks are asynchronous to each other
# -allow_paths re-activates timing checks between asyncs -> we must constrain CDCs!
if {[llength [get_ports -quiet jtag_tck_i]] > 0} {
    set_clock_groups -asynchronous -name core_clk_groups_async \
         -group {clk_jtg} \
         -group {clk_sys}
}


# We set reasonable uncertainties in their transistion timing
# and transition (rise/fall) times for all clocks (ns)
set_clock_uncertainty 0.1 [all_clocks]
set_clock_transition  0.2 [all_clocks]




#############
## Reset   ##
#############
puts "Reset constraints..."

# Reset should propagate to system domain within a clock cycle.
set_input_delay -max [ expr $TCK_SYS * 0.10 ] [get_ports rst_ni]  
set_false_path -hold   -from [get_ports rst_ni]
set_max_delay $TCK_SYS -from [get_ports rst_ni]


