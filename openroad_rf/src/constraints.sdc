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
puts "timer_unit Clocks..."

# We target 80 MHz
set TCK_SYS 12.5
create_clock -name clk_sys -period $TCK_SYS [get_ports clk_i]


# We set reasonable uncertainties in their transistion timing
# and transition (rise/fall) times for all clocks (ns)
set_clock_uncertainty 0.1 [all_clocks]
set_clock_transition  0.2 [all_clocks]


##############################
## Input/Output Constraints ##
##############################

# Collect input ports excluding clk_i and rst_ni
set input_ports ""
foreach port [all_inputs] {
    set name [get_name $port]
    if { $name ne "clk_i" && $name ne "rst_ni" } {
        lappend input_ports $name
    }
}

# Apply input delays
set_input_delay -max 2.0 -clock clk_sys $input_ports
set_input_delay -min 0.5 -clock clk_sys $input_ports

# Set delays for outputs
set_output_delay -max 2.0 -clock clk_sys [all_outputs]
set_output_delay -min 0.5 -clock clk_sys [all_outputs]


#############
## Reset   ##
#############
puts "Reset constraints..."

# Reset should propagate to system domain within a clock cycle.
set_input_delay -max [ expr $TCK_SYS * 0.10 ] [get_ports rst_ni]  
set_false_path -hold   -from [get_ports rst_ni]
set_max_delay $TCK_SYS -from [get_ports rst_ni]


