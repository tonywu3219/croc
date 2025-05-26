# Define STA corners
sta::define_corners tt ff

# Load library
read_liberty -corner tt ../../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_typ_1p20V_25C.lib
read_liberty -corner tt ../../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_io/lib/sg13g2_io_typ_1p2V_3p3V_25C.lib
read_liberty -corner ff ../../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_stdcell/lib/sg13g2_stdcell_fast_1p32V_m40C.lib
read_liberty -corner ff ../../ihp13/pdk/ihp-sg13g2/libs.ref/sg13g2_io/lib/sg13g2_io_fast_1p32V_3p6V_m40C.lib


# Read netlist
read_verilog ../out/cve2_register_file_ff.v
link_design cve2_register_file_ff

# Constraints
read_sdc ../src/constraints.sdc

# Parasitics
read_spef ../out/cve2_register_file_ff.spef

# Report delays (max & min)
report_checks -path_delay max -fields {slew cap trans delay} > rf_max.rpt
report_checks -path_delay min -fields {slew cap trans delay} > rf_min.rpt

