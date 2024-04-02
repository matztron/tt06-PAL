# the idea here is quite similar to the single_output case
# we need to generate an pool of AND-terms
# then we loop through each output and select the terms we need
# this does allow term reusing as we can delete duplicates from the term-pool in an intermediatory step just before output mapping

# ---

# for pyeda see:
# https://pyeda.readthedocs.io/en/latest/boolalg.html
# https://stackoverflow.com/questions/27312328/disjunctive-normal-form-in-python

from pyeda.inter import *
import parse_eq_str as str_parser

# shape of the PAL device
INPUT_NUM = 8 # N
INTERMED_SIG_NUM = 11 # P
OUTPUT_NUM = 5 # M

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
O0 = I1
O1 = I2
O2 = I3
O3 = (I3 & I2)
O4 = I0 & I1 & I2 & (I0 ^ I3) | I1 & ~I2 # a∧b∧c∧(a⊻d)∨b∧¬c

Equations = [O0, O1, O2, O3, O4]
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

# pattern (there can only be "and" & "or" gates because we have a DNF)
pattern_and = "And"
pattern_or = "Or"
for eq_str in Eq_DNF_str:

    terms = []
    # what can occure here:
    # I0
    # ~IO
    # And(I0, I1)
    # Or(And(I0, I2), I3)
    # Or(And(I0, I2), And(I2,I3))
    # Or(I1, I2)
    
    print("---")
    print(eq_str)
    
    # find all occurances of ORs
    # OR index can ever only be 0 (list has 1 element) or NONE (list has 0 elements)
    or_indices = list(str_parser.find_all(eq_str, pattern_or))
    print("or indices:")
    print(or_indices)
    
    # check if there is an and
    and_indices = list(str_parser.find_all(eq_str, pattern_and))
    print("and indices:")
    print(and_indices)
    
    if (len(or_indices) == 0):
        # something like:
        # I0
        # ~IO
        # And(I0, I1)
        
        if (len(and_indices) == 0):
            # something like:
            # I0
            # ~IO
            terms.append(eq_str)
        else:
            # something like:
            # And(I0, I1)
            for and_index in and_indices:
                new_term = str_parser.get_bracket_content(eq_str, and_index)
                terms.append(new_term)
            
    elif (len(or_indices) == 1):
        # something like:
        # Or(And(I0, I2), I3)
        # Or(And(I0, I2), And(I2,I3))
        # Or(I1, I2)
        
        # get content of OR-bracket!
        or_content = str_parser.get_bracket_content(eq_str, or_indices[0])
        
        # divide input at ","
        substrings = or_content.split(",")
        
        # we have free standing operands isolated now
        # like the I3 in: Or(And(I0, I2), I3)
        # However the AND is also separated...
        
        fused_substrings = []
        and_start_idx = -1
        for i, sub in enumerate(substrings):
            
            if (and_start_idx != -1):
                # we are currently looking for a closing bracket
                if (")" in sub):
                    # fuse
                    new_substring = ""
                    for j in range(and_start_idx, i+1):
                        new_substring = new_substring + "," + substrings[j]
                    fused_substrings.append(new_substring)
                    and_start_idx = -1
            
            elif ("And" in sub):
                    and_start_idx = i
            else:
                fused_substrings.append(sub)
        
        # remove spaces from substrings
        # add single terms directly
        
        # for AND()-terms look into the bracket and then add the content of that to terms
        for i, f_sub in enumerate(fused_substrings):
            if ("And" in f_sub):
                # find where the And starts
                and_indices = list(str_parser.find_all(f_sub, "And"))
                brckt_content = str_parser.get_bracket_content(f_sub, and_indices[0])
                
                # replace:
                fused_substrings[i] = brckt_content
        terms.extend(fused_substrings)
    
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
    operands = term.split(',')
    

    # show them
    print("operands:")
    print(operands)

    for op in operands:
        
        #remove spaces
        op = op.strip()
        
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
        
        # added a '+1' because for 0th row inversion does not work!
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