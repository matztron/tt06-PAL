# this functions contain the neccessary function to get the things we need from a string

# finds all occurances of substring in a string and returns the indices
def find_all(a_str, sub):
    start = 0
    while True:
        start = a_str.find(sub, start)
        if start == -1: return
        yield start
        start += len(sub) # use start += 1 to find overlapping matches
        
def get_bracket_content(string, start_index):
    # start at start_index and go through string - count the number of opening brackets
    # start index gives the index of an operand such as "AND(...)" or "OR(...)"
    
    # find first opening bracket in substring
    initial_opening_bracket_index = -1
    
    for i, char in enumerate(string[start_index:]):
        if (char == "("):
            initial_opening_bracket_index = start_index + i
            break
    
    # return error if no opening bracket was found -> there should be one!
    if (initial_opening_bracket_index == -1):
        print("ERROR! No opening bracket was found")
        return -1
    else:
    
        bracket_count = 1 # we already found the initial opening bracket
        for i, char in enumerate(string[initial_opening_bracket_index+1:]):
            if (char == "("):
                bracket_count = bracket_count + 1
            elif (char == ")"):
                bracket_count = bracket_count - 1
                
            if (bracket_count == 0):
                # we found the closing bracket
                return string[initial_opening_bracket_index+1:initial_opening_bracket_index+i+1]
        
        # if we reach here then there was no closing bracket... this should not be the case!
        print("ERROR! No closing bracket was found")
        return -1