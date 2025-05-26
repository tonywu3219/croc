# Read LEFs
read_lef ../../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_tech.lef
read_lef ../../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_stdcell/lef/sg13g2_stdcell.lef
read_lef ../../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_io/lef/sg13g2_io.lef

# Define STA corners
sta::define_corners tt ff

# Read Liberty files
sta::read_liberty -corner tt ../../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib
sta::read_liberty -corner tt ../../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_io/lib/sg13g2_io_typ_1p2V_3p3V_25C.lib
sta::read_liberty -corner ff ../../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_fast_1p32V_m40C.lib
sta::read_liberty -corner ff ../../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_io/lib/sg13g2_io_fast_1p32V_3p6V_m40C.lib

# Read netlist
read_verilog ../out/cve2_register_file_ff.v

# Link the design
link_design cve2_register_file_ff

puts "Current design is: [sta::current_design]"

# Confirm design is loaded
puts "Current design is: [sta::current_design]"

# Load SDC constraints
read_sdc ../src/constraints.sdc

# Write Liberty (use correct 2-argument syntax)
sta::write_liberty -file ../out/cve2_register_file_ff.lib -cells {cve2_register_file_ff}
