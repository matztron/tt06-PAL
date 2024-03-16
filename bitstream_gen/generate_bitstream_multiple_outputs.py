# the idea here is quite similar to the single_output case
# we need to generate an pool of AND-terms
# then we loop through each output and select the terms we need
# this does allow term reusing as we can delete duplicates from the term-pool in an intermediatory step just before output mapping

# ---

# for pyeda see:
# https://pyeda.readthedocs.io/en/latest/boolalg.html
# https://stackoverflow.com/questions/27312328/disjunctive-normal-form-in-python

from pyeda.inter import *

# shape of the PAL device
INPUT_NUM = 8 # N
INTERMED_SIG_NUM = 14 # P
OUTPUT_NUM = 4 # M

#---
# Variables

# Inputs (you have to keep this in sync with INPUT_NUM above)
I0 = exprvar('I0')
I1 = exprvar('I1')
I2 = exprvar('I2')
I3 = exprvar('I3')
I4 = exprvar('I4')
I5 = exprvar('I5')
I6 = exprvar('I6')
I7 = exprvar('I7')

Inputs = [I0, I1, I2, I3, I4, I5, I6, I7]

#---

#---
# Equations (one for each output)
# You can use these operators (probably even more -> check the website of PyEDA):
# ~: NOT
# |: OR
# ^: XOR
# &: AND 

# For now: There should only be one equation
O0 = ~I0 | I1 & ~(I2 & I3) 
O1 = ~I0 | I1 & ~(I2 & I3) & I7 
O2 = ~I0

Equations = [O0, O1, O2]
#---

# Display Truth table
# just for fun :)
for eq in Equations:
    a = expr2truthtable(eq)
    print(a)

print("Converting equation(s) to DNF for PAL mapping")
Eq_DNF = []
for eq in Equations:
    print(eq.to_dnf())
    Eq_DNF.append(eq.to_dnf())
    #print(type(str(eq.to_dnf())))

# Limitations:
# You can only have as many ORs as there are outputs
# You can only have as many ANDs as you have inputs
# PER TERM IN DNF

# Term reuse is possible if multiple equations are desired
    
# Algo:
# Start with first equation (maybe naive...
# Look at first TERM -> configure column accordingly
# Look at second TERM -> configure column accordingly
# ...
    
#debug
print(Eq_DNF)

Eq_DNF_str = []
Terms_per_Outp = []
# convert DNF to string
for eq in Equations:
    Eq_DNF_str.append(str(eq.to_dnf()))

# march through string - char by char!
# If you encounter an "AND("-substring take everything until the closing parenthasis
# -> this is one term
# Set the current column accordingly
print(Eq_DNF_str)

# pattern
pattern_and = "And("
pattern_cl_brckt_ = ")"
for eq_str in Eq_DNF_str:
    # get stuff between 'AND(' and ')'
    and_indices = [i for i in range(len(eq_str)) if eq_str.startswith(pattern_and, i)]
    cl_brckt_indices = [i for i in range(len(eq_str)) if eq_str.startswith(pattern_cl_brckt_, i)] # closing bracket indices
    
    # Maybe there is only one term such as '~I1'
    if (len(and_indices) == 0 and len(cl_brckt_indices) == 0):
        Terms_per_Outp.append([eq_str])
        break

    print(and_indices)
    print(cl_brckt_indices)

    terms = []
    for i, a_idx in enumerate(and_indices):
        terms.append(eq_str[and_indices[i]+len(pattern_and):cl_brckt_indices[i]])
    #!
    Terms_per_Outp.append(terms)

# Terms: Here we only have the operands that are 'and'ed together
#print(f"Extracted terms: {terms}")

Term_pool = []
for eq in Terms_per_Outp:
    for term in eq:
        Term_pool.append(term)
        
# Make term pool unique
Term_pool = list(dict.fromkeys(Term_pool)) # If two terms are "I1, I2" and the other "I2 and I1" this would be two different terms... Lets keep the naive version for now... :D


# !!!
# IMPORTANT CHECK (because naive implementation!)
if (len(Term_pool) > INTERMED_SIG_NUM):
    print("ERROR! The number of terms is larger than the number of intermediate stages. The naive mapping does not support that!")
    quit
# !!!

# Now go through each terms operands and set the bitstream accordingly!
bitstream =  "0" * (2*INPUT_NUM*INTERMED_SIG_NUM + INTERMED_SIG_NUM*OUTPUT_NUM)
bitstream = list(bitstream)

print(f"Length of bitstream: {len(bitstream)}")

for term_index, term in enumerate(Term_pool):
    # split string at commas!
    # and remove trailing spaces
    operands = term.split(', ')

    # show them
    print(operands)

    for op in operands:
        use_inverted = 0
        input_num = -1
        # EXPECTED SYNTAX: <optional tilde>I<uinput number>
        if (op[0] == "~"):
            # the inverted input signal shall be used
            use_inverted = 1
            input_num = int(op[2])
        else:
            # signal is not inverted
            input_num = int(op[1])

        # And(I0, I1, I2, I3)
        # 100
        # 000
        # 100
        # 000
        # 100
        # 000
        # 100
        # 000
        # 000
        # 000
        # 000
            
        # Device structure
        # 0. I0    x x x
        # 1. ~I0   x x x
        # 2. I1    x x x
        # 3. ~I1   x x x
        # 4. I2    x x x
        # 5. ~I2   x x x
        # 6. I3    x x x
        # 7. ~I3   x x x
        #          & & &
        #          x x x | O1
        #          x x x | O2
        #          x x x | O3

        # determine bit in bitstream to set
        # we need a column per term TODO: Check if we have this before!

        bitstream[INTERMED_SIG_NUM*(2*input_num+use_inverted)+term_index] = '1'

# We filled the intermediate columns according to the order of the Term_pool list
# Now we have to look at the Terms_per_Outp to determine if an output needs the particular term
for o in range(OUTPUT_NUM):
    if (o < len(Equations)):
        # this is an output we configured
        for t in range(len(Term_pool)):
            if (Term_pool[t] in Terms_per_Outp[o]):
                bitstream[2*INPUT_NUM*INTERMED_SIG_NUM + INTERMED_SIG_NUM*o + t] = '1'
            else:
                bitstream[2*INPUT_NUM*INTERMED_SIG_NUM + INTERMED_SIG_NUM*o + t] = '0'
    else:
        # these are outputs that are unused -> keep all bits 0 here
        pass

# convert bitstream back to a string
bitstream = "".join(bitstream)

# print bitstream
print("Bitstream is:")
print(bitstream)

print("Visualization of bitstream:")
# Draw PAL in terminal    
# 1. Draw Input-And-Matrix
for inp in range(2*INPUT_NUM): # ROW
    #print(inp)

    line_str = ""

    # first write the signal name
    if (inp % 2 != 0):
        # uneven line: This is for an inverter element
        line_str = line_str + "~"
    line_str = line_str + f"I{int(inp/2)}"

    # followed by an arrow in "->"
    if (inp % 2 != 0):
        # inverted input
        line_str = line_str + "-> "
    else:
        # not inverted input - needs extra space to be displayed nicely
        line_str = line_str + " -> "

    # draw the row of bitstream elements (o and 1)
    for intermed in range(INTERMED_SIG_NUM): # COLUMN
        line_str = line_str + bitstream[INTERMED_SIG_NUM*(inp+use_inverted)+intermed]

    print(line_str)

# 2. Draw AND-gates
line_str = "      "
for intermed in range(INTERMED_SIG_NUM):
    line_str = line_str + "&"

print(line_str)

# 3. Draw Or-Output-Matrix
for out in range(OUTPUT_NUM):

    line_str = "      "
    # Matrix
    for intermed in range(INTERMED_SIG_NUM):
        line_str = line_str + bitstream[2*INPUT_NUM*INTERMED_SIG_NUM + INTERMED_SIG_NUM*out + intermed]

    # Output signal names
    line_str = line_str + f" -> O{out}"

    print(line_str)

print("---")
print("Bitstream for verilog is:")
#print(f"{len(bitstream)}'b{bitstream[::-1]}")
print(f"{len(bitstream)}'b{bitstream}")