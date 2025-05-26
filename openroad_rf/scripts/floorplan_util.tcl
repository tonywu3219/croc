# Copyright 2023 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Tobias Senti <tsenti@ethz.ch>
# - Jannis Schönleber <janniss@iis.ee.ethz.ch>
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

# Some useful functions for floorplaning

# place_macro only allows R0, R180, MX, MY
# Example: placeInstance $sram 25 50 R90
rtl_macro_placer 
