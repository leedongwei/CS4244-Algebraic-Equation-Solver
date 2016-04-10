from CLIPS_solver import *

# input_equation = "(4+5x)+2*(8x+x*16+2)*x=2"

# ==================== Test equations ==========================
# Rule 1a 
# input_equation = "(10x-2)+2-(3x-5)=1" 
# input_equation = "(10x-2)+2+(3x-5)=1"

# Rule 1b 
# input_equation = "(10x*5)+2*(8x+16)=1"

# Rule 2a 

# Rule 2b
# input_equation = "(5*10x)+(2*(8x+16)) = 1"
# input_equation = "(5*10x)+(2/(8x+16)) = 1"
# input_equation = "(5/10x)+(2*(8x+16)) = 1"
# input_equation = "(5/10x)+(2/(8x+16)) = 1"

# Rule 3b
# input_equation = "(10x+5)+4x = 1"
# input_equation = "(10x-5)+4x = 1"
# input_equation = "(10x+5)-4x = 1"
# input_equation = "(10x+5)+4x = 1"

# Rule 3c1
# input_equation = "10x+(7-3x) = 3"
# input_equation = "10x+(7+3x) = 3"

# Rule 4a
# input_equation = "10x-3x = 4"
# input_equation = "10x+3x = 4"

# Rule 4b
# input_equation = "5x+(2*(8x+16)) = 2"
# input_equation = "5x+(2*(8x-16)) = 2"

# Rule 5
# input_equation = "(5+16)*x = 34"
# input_equation = "(5-16)*x = 34"
# input_equation = "(5*16)*x = 34"
input_equation = "(5/16)*x = 34"

# Rule 7

# ==================== Test equations ==========================

solver = CLIPS_solver()
solver.solve(input_equation)
solver.close_clips()



# equation = "(4+5x)+(x*8)*16=2"

# equation = "(4+5x)+(x*8)+16=2"

# equation = "(4+5x)+2*(16+8*x)=2"
# equation = "(5x+4)+2*(16+8x)=2"
# equation = "(4+5x)+2*(8x+x*16+2)=2"

# ==================== Test equations ==========================
# equation = "(5*10x)+2*(2x) = 1" # Associative_combine_num_2b
# equation = "(10x-2)+2 - (3x-5) = 1" # Commutative_reorder_Fx_1a
# equation = "(10x-2)+((-1*(3x-5))+2) = 1" 