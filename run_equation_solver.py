from CLIPS_solver import *

input_equation = "(4+5x)+2*(8x+x*16+2)*x=2"

solver = CLIPS_solver()
solver.solve(input_equation)
solver.close_clips()