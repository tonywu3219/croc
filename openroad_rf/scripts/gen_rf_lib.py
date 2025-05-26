import re
from collections import defaultdict

def parse_sta_report(report, path_type):
    paths = []
    blocks = report.split("Startpoint:")
    for block in blocks[1:]:
        lines = block.strip().splitlines()
        start = lines[0].split()[0]
        endpoint_line = next((l for l in lines if "Endpoint:" in l), None)
        if not endpoint_line:
            continue
        end = endpoint_line.split(":")[1].strip().split()[0]

        # Get data arrival time
        arrival_line = next((l for l in lines if "data arrival time" in l), None)
        if not arrival_line:
            continue
        arrival = float(re.findall(r"[-+]?\d*\.\d+|\d+", arrival_line)[0])
        paths.append((start, end, arrival, path_type))
    return paths

def generate_lib(delay_arcs, constraint_arcs, cell_name="rf_block"):
    pins = set()
    for i, o, *_ in delay_arcs + constraint_arcs:
        pins.add(i)
        pins.add(o)

    lib = [f"library({cell_name}_lib) {{", f"  cell ({cell_name}) {{"]

    for pin in sorted(pins):
        direction = "input" if any(pin == p[0] for p in delay_arcs + constraint_arcs) else "output"
        lib.append(f"    pin({pin}) {{ direction : {direction}; }}")

    # Merge arcs by input→output
    timing_arcs = defaultdict(lambda: {"max": None, "min": None})
    for i, o, val, arc_type in delay_arcs + constraint_arcs:
        timing_arcs[(i, o)][arc_type] = val

    for (i, o), arc in timing_arcs.items():
        lib.append(f"""    timing() {{
      related_pin : "{i}";
      timing_sense : positive_unate;""")

        if arc["max"] is not None:
            lib.append(f"""      cell_rise(scalar) {{ values("{arc['max']:.3f}"); }}
      cell_fall(scalar) {{ values("{arc['max']:.3f}"); }}""")

        if arc["min"] is not None:
            lib.append(f"""      rise_constraint(scalar) {{ values("{arc['min']:.3f}"); }}
      fall_constraint(scalar) {{ values("{arc['min']:.3f}"); }}""")

        lib.append("    }")

    lib.append("  }")
    lib.append("}")
    return "\n".join(lib)

if __name__ == "__main__":
    with open("rf_max.rpt") as f:
        max_paths = parse_sta_report(f.read(), "max")
    with open("rf_min.rpt") as f:
        min_paths = parse_sta_report(f.read(), "min")

    lib = generate_lib(max_paths, min_paths)
    with open("rf_generated.lib", "w") as f:
        f.write(lib)
    print("✅ rf_generated.lib created with {} delay arcs and {} constraints.".format(
        len(max_paths), len(min_paths)))
