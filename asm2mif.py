import re
import sys

VARS = dict()
WORDS = dict()
LABELS = dict()

MIF_FILE = []

WIDTH = 32
DEPTH = 2048
ADDRESS_RADIX = "HEX"
DATA_RADIX = "HEX"

REG_ALIASES = { #Registers and aliases mapped to same value
    'R0'    : 0,
    'A0'    : 0,
    'R1'    : 1,
    'A1'    : 1,
    'R2'    : 2,
    'A2'    : 2,
    'R3'    : 3,
    'A3'    : 3,
    'RV'    : 3,
    'R4'    : 4,
    'T0'    : 4,
    'R5'    : 5,
    'T1'    : 5,
    'R6'    : 6,
    'S0'    : 6,
    'R7'    : 7,
    'S1'    : 7,
    'R8'    : 8,
    'S2'    : 8,
    'R9'    : 9,
    'R10'   : 10,
    'R11'   : 11,
    'R12'   : 12,
    'GP'    : 12,
    'R13'   : 13,
    'FP'    : 13,
    'R14'   : 14,
    'SP'    : 14,
    'R15'   : 15,
    'RA'    : 15
}

SINGLE_REG = {
    'MVHI'  : 0x4F,
    'BEQZ'  : 0x22,
    'BLTZ'  : 0x2D,
    'BLTEZ' : 0x28,
    'BNEZ'  : 0x21,
    'BGTEZ' : 0x2E,
    'BGTZ'  : 0x2F
}

ISA = { #Instructions and their 0x[op][fn] values
    #ALU-R
    'ADD'   : 0xC7,
    'SUB'   : 0xC6,
    'AND'   : 0xC0,
    'OR'    : 0xC1,
    'XOR'   : 0xC2,
    'NAND'  : 0xC8,
    'NOR'   : 0xC9,
    'XNOR'  : 0xCA,
    #0xC Register

    #ALU-I
    'ADDI'  : 0x47,
    'SUBI'  : 0x46,
    'ANDI'  : 0x40,
    'ORI'   : 0x41,
    'XORI'  : 0x42,
    'NANDI' : 0x48,
    'NORI'  : 0x49,
    'XNORI' : 0x4A,
    # 0x4 Immediate

    'MVHI'  : 0x4F,
    #0x4 Single Register

    'LW'    : 0x70,
    #0x7 Regular Offset

    'SW'    : 0x30,
    #0x3 Modified Offset

    #CMP-R
    'F'     : 0xD3,
    'EQ'    : 0xD6,
    'LT'    : 0xD9,
    'LTE'   : 0xDC,
    'T'     : 0xD0,
    'NE'    : 0xD5,
    'GTE'   : 0xDA,
    'GT'    : 0xDF,
    #0xD Register

    #CMP-I
    'FI'    : 0x53,
    'EQI'   : 0x56,
    'LTI'   : 0x59,
    'LTEI'  : 0x5C,
    'TI'    : 0x50,
    'NEI'   : 0x55,
    'GTEI'  : 0x5A,
    'GTI'   : 0x5F,
    #0x5 Immediate

    'BF'    : 0x23,
    'BEQ'   : 0x26,
    'BLT'   : 0x29,
    'BLTE'  : 0x2C,
    'BT'    : 0x20,
    'BNE'   : 0x25,
    'BGTE'  : 0x2A,
    'BGT'   : 0x2B,
    #0x2 Immediate

    'BEQZ'  : 0x22,
    'BLTZ'  : 0x2D,
    'BLTEZ' : 0x28,
    'BNEZ'  : 0x21,
    'BGTEZ' : 0x2E,
    'BGTZ'  : 0x2F,
    #0x2 Single Register

    'JAL'   : 0x60
    #0x6 Regular Offset
}

ISA_PSEUDO = {
    'BR'    : 0xF0, ##
    'NOT'   : 0xF1, ##
    'BLE'   : 0xF2,
    'BGE'   : 0xF3,
    'CALL'  : 0xF4, ##
    'RET'   : 0xF5, ##
    'JMP'   : 0xF6  ##
}


# Instruction class
class Instruction:
    line = 0
    loc = 0
    raw = 0
    text = 0

    def __init__(self, line, loc, text, raw):
        self.line = line
        self.loc = loc
        self.raw = raw
        self.text = text


# Dead locations
class Dead:
    start = 0
    stop = 0

    def __init__(self, start, stop):
        self.start = start
        self.stop = stop


# Word location
class Word:
    loc = 0
    val = 0
    raw = 0

    def __init__(self, loc, val, raw):
        self.loc = loc
        self.val = val
        self.raw = raw


# Return the int representation fo a string
def getInt(string):
    if string.startswith('0x') or string.startswith('0X'):
        return int(string, 16)
    else:
        return int(string)


# Parse a register instruction
def registerInstruction(opcode, args, loc, linen, raw):
    machineCode = opcode << 12
    i = 2
    for arg in args:
        arg = int(arg)
        if (arg >= 0 and arg <= 15):
            machineCode |= (arg << (i*4))
            i -= 1
        else:
            print("Incorrect register at %d register = %d " % (linen, arg))
            exit(-1)
    machineCode <<= 12
    MIF_FILE.append("-- @ %s : %s\n%s : %s;\n" % (format(loc, '#010x'), raw.upper(), format(loc // 0x4, '08x'),
                                                  format(machineCode, '08x')))
    return machineCode


# Parse an immediate instruction
def immediateInstruction(opcode, args, loc, linen, raw):
    machineCode = opcode << 12
    i = 2
    for j in range(len(args) - 1):
        arg = int(args[j])
        if (arg >= 0 and arg <= 15):
            machineCode |= (arg << (i*4))
            i -= 1
        else:
            print("Arg = %s " % arg)
            print("Incorrect register at %d" % linen)
            exit(-1)
    machineCode <<= 12
    immediate = args[2].strip()
    if immediate in LABELS.keys():
        immediate = LABELS[immediate]
    elif immediate in VARS.keys():
        immediate = VARS[immediate]
    immediate = int(immediate)

    if ((opcode >> 4) == 0x2) or opcode == 0x60:
        immediate *= 0x4
        if opcode != 0x60:
            immediate -= (loc + 0x4)
        immediate //= 0x4
    if opcode == 0x4F:
        immediate >>= 16
        machineCode |= (immediate & 0x0000FFFF)
    else:
        if ((immediate >= -32768) and (immediate <= 32767)):
            machineCode |= (immediate & 0x0000FFFF)
        else:
            print("Invalid immediate at %s immediate = %s" % (linen, immediate))
            exit(-1)

    MIF_FILE.append("-- @ %s : %s\n%s : %s;\n" % (format(loc, '#010x'), raw.upper(), format(loc // 0x4, '08x'),
                                                  format(machineCode, '08x')))
    return machineCode


# Parse an instruction
def parseLine(instruction):
    if instruction.__class__.__name__ is "Instruction":
        instructionText = re.sub(r'.*?([A-Za-z]{1,5})\s+', r'\1|', instruction.text)
        instructionArr = re.split(r'\|', instructionText)

        opcode = instructionArr[0]
        arguments = []

        if len(instructionArr) > 1:
            arguments = re.split(r'\s*,\s*', instructionArr[1])

        if opcode not in SINGLE_REG.keys():
            opcodeBin = ISA[opcode]
            op = opcodeBin >> 4
            if (op == 0xC or op == 0xD):
                # ALU-R or CMP-R instruction
                return registerInstruction(opcodeBin, arguments, instruction.loc, instruction.line, instruction.raw)
            elif (op == 0x2 or op == 0x4 or op == 0x5):
                # Branch or ALU-I or CMP-I instruction
                return immediateInstruction(opcodeBin, arguments, instruction.loc, instruction.line, instruction.raw)
            else:
                # SW/LW
                swArgs = re.sub(r'\s*(.*?)\((.*?)\)\s*', r'\1|\2', arguments[1]).split("|")
                if swArgs[1] in REG_ALIASES.keys():
                    swArgs[1] = REG_ALIASES[swArgs[1]]
                arguments = [arguments[0], swArgs[1], swArgs[0]]
                return immediateInstruction(opcodeBin, arguments, instruction.loc, instruction.line, instruction.raw)
        else:
            # Single Register instruction
            opcodeBin = SINGLE_REG[opcode]
            arguments = [arguments[0], 0, arguments[1]]
            return immediateInstruction(opcodeBin, arguments, instruction.loc, instruction.line, instruction.raw)
    elif instruction.__class__.__name__ is "Dead":
        if (instruction.start == instruction.stop):
            MIF_FILE.append("%s : DEAD;\n" % format(instruction.start, '08x'))
        else:
            MIF_FILE.append("[%s..%s] : DEAD;\n" % (format(instruction.start, '08x'), format(instruction.stop, '08x')))
    else:
        MIF_FILE.append("-- @ %s : %s\n%s : %s;\n" % (format(instruction.loc*0x4, '#010x'), instruction.raw,
                                                    format(instruction.loc, '08x'), format(instruction.val, '08x')))


# Parse the source file
def parseFile(file):
    linen = 0
    curr = 0
    orig = 0
    lines = []

    fopen = open(file, 'r')
    for line in fopen:
        stripComment = re.sub(r';.*$', "", line).strip()
        if stripComment is not "":
            if re.search(r'\.[Oo][Rr][Ii][Gg]\s+', stripComment):
                # The line is a .ORIG
                origVal = re.sub(r'\.[Oo][Rr][Ii][Gg]\s+', "", stripComment)
                orig = getInt(origVal)
                if (orig > curr):
                    lines.append(Dead(curr//4, (orig-0x4)//4))
                curr = orig
            elif re.search(r'\.[Ww][Oo][Rr][Dd]\s+', stripComment):
                # The line is a .WORD
                wordDecl = re.split(r'\s+', stripComment.strip())
                if re.search(r'(0[xX][0-9a-fA-F]+)|(\-?[0-9]+)', wordDecl[1]):
                    # The .WORD is a literal
                    WORDS[curr//0x4] = getInt(wordDecl[1])
                elif wordDecl[1].upper() in VARS.keys():
                    # The .WORD is a .NAME
                    WORDS[curr//0x4] = VARS[wordDecl[1].upper()]
                elif wordDecl[1].upper() in LABELS.keys():
                    # The .WORD is a label
                    WORDS[curr//0x4] = LABELS[wordDecl[1].upper()]
                else:
                    print("'%s' at line %d is not a .NAME or a label (yet)" % (wordDecl[1], linen))
                    exit(-1)
                lines.append(Word(curr//0x4, int(WORDS[curr//0x4]), stripComment))
                curr += 0x4
            elif re.search(r'\.[Nn][Aa][Mm][Ee]\s+', stripComment):
                # The line is a .NAME
                nameLine = re.sub(r'\.[Nn][Aa][Mm][Ee]\s+', "", stripComment)
                varDecl = re.split(r'\s*=\s*', nameLine.strip())
                varName = varDecl[0].upper()
                VARS[varName] = getInt(varDecl[1])
            elif re.search(r'\s*[A-zA-z0-9]:\s*', stripComment):
                # The line is a label
                label = re.sub(r'[\s:]', "", stripComment).upper()
                LABELS[label] = curr//0x4
            else:
                # The line is an instruction
                instruction = re.sub(r'\s*([A-Za-z]{1,5})\s+', r'\1|', stripComment).split("|")
                opcodes = []
                args = []

                if instruction[0].upper() in ISA_PSEUDO.keys():
                    # The line is a pseudo instruction
                    pseudo = instruction[0].upper()
                    if pseudo == 'BR':
                        opArgs = (re.split(r'\s*,\s*', instruction[1]))
                        opcodes.append('BEQ')
                        args.append(['R6', 'R6', opArgs[0]])
                    elif pseudo == 'NOT':
                        opArgs = (re.split(r'\s*,\s*', instruction[1]))
                        opcodes.append('NAND')
                        args.append([opArgs[0], opArgs[1], opArgs[1]])
                    elif pseudo == 'BLE':
                        # Add two instructions, but keep the same raw text
                        opArgs = (re.split(r'\s*,\s*', instruction[1]))
                        opcodes.append('LTE')
                        args.append(['R6', opArgs[0], opArgs[1]])

                        opcodes.append('BNEZ')
                        args.append(['R6', opArgs[2]])
                    elif pseudo == 'BGE':
                        # Add two instructions, but keep the same raw text
                        opArgs = (re.split(r'\s*,\s*', instruction[1]))
                        opcodes.append('GTE')
                        args.append(['R6', opArgs[0], opArgs[1]])

                        opcodes.append('BNEZ')
                        args.append(['R6', opArgs[2]])
                    elif pseudo == 'CALL':
                        opArgs = (re.split(r'\s*,\s*', instruction[1]))
                        opcodes.append('JAL')
                        args.append(['RA', opArgs[0]])
                    elif pseudo == 'RET':
                        opcodes.append('JAL')
                        args.append(['R9', '0(RA)'])
                    else:
                        opArgs = (re.split(r'\s*,\s*', instruction[1]))
                        print("\"%s\"" % pseudo)
                        opcodes.append('JAL')
                        args.append([opArgs[0]])
                else:
                    # The instruction is a regular instruction
                    opcodes.append(instruction[0].upper())
                    if len(instruction) > 1:
                        args.append(re.split(r'\s*,\s*', instruction[1]))
                for i in range(len(opcodes)):
                    # Parse the arguments to the opcode
                    opcode = opcodes[i]
                    opargs = []
                    if len(args) > 0:
                        opargs = args[i]
                    for oparg in opargs:
                        oparg = oparg.upper().strip()
                        if (oparg in VARS.keys() or (not re.match(r'^(\-?\d+|0[xX][0-9A-Fa-f]+)$', oparg))):
                            if oparg in REG_ALIASES.keys():
                                oparg = REG_ALIASES[oparg]
                            elif re.match(r'(\-)?[A-Za-z\d]+\([A-Za-z][\d]{1,2}]\)', oparg):
                                immediate = re.split(r'\(', oparg)[0]
                                register = re.split(r'\(', oparg)[1]
                                register = re.sub(r'\)', "", register)

                                if register in REG_ALIASES.keys():
                                    register = REG_ALIASES[register]
                                else:
                                    print("Invalid instruction at %d" % linen)
                                oparg = str(immediate) + '(' + str(register) + ')'
                        else:
                            oparg = getInt(oparg)
                        opcode += " " + str(oparg) + ","
                    opcode = re.sub(r',$', "", opcode)
                    lines.append(Instruction(linen, curr, opcode, re.sub(r'\s+', " ", stripComment)))
                    curr += 0x4
        linen += 1
    fopen.close()
    return lines, orig, curr


if __name__ == "__main__":
    source = sys.argv[1]
    output = re.sub("\..*$", ".mif", source)
    lines, orig, curr = parseFile(source)
    mif = []
    fout = open(output, 'w')
    fout.write("WIDTH=%d;\n" % WIDTH)
    fout.write("DEPTH=%d;\n" % DEPTH)
    fout.write("ADDRESS_RADIX=%s;\n" % ADDRESS_RADIX)
    fout.write("DATA_RADIX=%s;\n" % DATA_RADIX)
    fout.write("CONTENT BEGIN\n")
    for line in lines:
        machinecode = parseLine(line)
    for mifLine in MIF_FILE:
        fout.write(mifLine)
    fout.write("[%s..%s] : DEAD;\nEND;\n" % (format(curr//0x4, '08x'), format(DEPTH-1, '08x')))