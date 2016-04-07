# import os
from os import read,path
import platform
from subprocess import Popen, PIPE
from time import sleep
import sys
import re





## Strings to guide users
promptClear = (
    '\r\n'
    '******************************'
    '******************************'
    '\r\n'
)
promptHelp = (
    'AVAILABLE COMMANDS:\r\n'
    'help: Display this help screen \r\n'
    'exit: Close CLIPS \r\n\r\n'

    'Please use exit to quit this program to ensure that CLIPS\r\n'
    'does not continue to in the background and consume resources\r\n'
)
promptInput = 'CLIPS> '
promptInputError = (
    'ERROR: Does not recognize command or wrong syntax for equation\r\n'
)
operators = {
    '(' : {
        'id'   : '(',
        'prec' : 0,
        'calc' : '' },
    ')' : {
        'id'   : ')',
        'prec' : 0,
        'calc' : '' },
    # addition
    '+' : {
        'id'   : '+',
        'prec' : 1,
        'calc' : 'add' },
    # subtraction
    '-' : {
        'id'   : '-',
        'prec' : 1,
        'calc' : 'sub' },
   # multiplication
    '*' : {
        'id'   : '*',
        'prec' : 2,
        'calc' : 'mult' },
    # division
    '/' : {
        'id'   : '/',
        'prec' : 2,
        'calc' : 'div' },
    '=' : {
        'id'   : '=',
        'prec' : 5,
        'calc' : 'equal'
    }
}




## Load CLIPS based on Operating System
p = None
if platform.system() == 'Darwin':
    print '\r\nLoading CLIPS for Mac OS X...'

    from fcntl import fcntl, F_GETFL, F_SETFL
    from os import O_NONBLOCK
    exec_dir = path.dirname(path.realpath(__file__))
    exec_path = path.join(exec_dir,'CLIPS_console_mac')

    p = Popen(exec_path,
              shell=False,
              stdin=PIPE,
              stdout=PIPE,
              stderr= PIPE)
    flags = fcntl(p.stdout, F_GETFL) # get current p.stdout flags
    fcntl(p.stdout, F_SETFL, flags | O_NONBLOCK)

elif platform.system() == 'Windows':
    print '\r\nLoading CLIPS for Windows...'
    p = Popen('CLIPS_console_windows.exe',
              shell=False,
              stdin=PIPE,
              stdout=PIPE,
              stderr= PIPE)

else :
    print '\r\nOS not supported'
    exit()

print promptClear
print promptHelp





class ClipsConverter:
    def __init__(self, inp):
        self.input = inp.replace(' ', '')
        self.operators = operators
        self.operatorStack = []
        self.variableStack = []
        self.shuntedTokens = []
        self.maxDepth = 1
        self.output = ''

    def parse(self):
        ## Converts "5x" to "(5*x)"
        operand = re.compile(r'(\d+)x')
        self.input = operand.sub(r'(\1*x)', self.input)

        LHS_RHS = self.input.split('=')
        LHS_RHS_out = []

        for side in LHS_RHS:
            self.operatorStack = []
            self.variableStack = []
            self.shuntedTokens = []
            tokens = [x for x in re.split('([+-/*\(\)=])', side) if x != '']

            ## Shunting-yard Algorithm
            while tokens:
                self.parse_token(tokens.pop(0))
            while self.operatorStack:
                self.shuntedTokens.append(self.operatorStack.pop())

            ## Convert into CLIPS program syntax
            convert = self.build_CLIPS_eqn(self.shuntedTokens.pop())
            LHS_RHS_out.append(convert)

        print 'LHS: ' + LHS_RHS_out[0]
        print 'RHS: ' + LHS_RHS_out[1]
        self.output = ' equal '.join(LHS_RHS_out)


    def parse_token (self, tok):
        if is_number(tok) or 'x' in tok:
            self.shuntedTokens.append(tok)
        elif self.operators.has_key(tok):
            actual_tok = self.operators[tok]
            self.parse_op(actual_tok)
        else:
            print ("ERROR: ", tok)
            raise SyntaxError('Unrecognized token ' + str(tok));


    def parse_op (self, tok):
        def weaker (left, right):
            return left['prec'] < right['prec']

        if tok['id'] == '(':
            self.operatorStack.append(tok)
        elif tok['id'] == ')':
            while self.operatorStack :
                prevTok = self.operatorStack.pop()
                if prevTok['id'] == '(':
                    break
                else:
                    self.shuntedTokens.append(prevTok)
        elif (not self.operatorStack) or self.operatorStack[-1] == '(':
            self.operatorStack.append(tok)
        else:
            while self.operatorStack and weaker(tok, self.operatorStack[-1]):
                temp = self.operatorStack.pop()
                self.shuntedTokens.append(temp)

            self.operatorStack.append(tok)


    def build_CLIPS_eqn(self, tok, depth=-1):
        if depth < 0:
            depth = self.maxDepth

        if is_number(tok) or 'x' in tok:
            if self.maxDepth < depth:
                self.maxDepth = depth
            return str(tok)

        if not isinstance(tok['calc'], str):
            return None
        else:
            rightOperand = self.build_CLIPS_eqn(
                                self.shuntedTokens.pop(), depth+1)
            leftOperand = self.build_CLIPS_eqn(
                                self.shuntedTokens.pop(), depth+1)
            depth = str(depth)

            output = []
            # output.append("(")
            output.append(tok['calc'])
            output.append(depth)
            output.append(leftOperand)
            output.append('split')
            output.append(depth)
            output.append(rightOperand)
            output.append('end')
            output.append(depth)
            # output.append(")")

            return  ' '.join(output)








def write_clips(cmd):
    global p
    p.stdin.write(cmd+'\n')

def read_clips():
    global p
    try:
        s = read(p.stdout.fileno(), 99999)
        return s
    except OSError:
        return None

def close_clips():
    write_clips('(exit)')
    p.terminate()
    Popen.terminate
    print 'Close CLIPS and exit'
    sys.exit()

def convert_input(s):

    if s.find('=') != -1:
        temp = s.split('=')
        if len(temp) > 2:
          return 'error'

        eqn = ClipsConverter(s)
        eqn.parse()

        converted = '(equation ' + eqn.output + ')'

        print '\nEQN: ' + converted
        return converted


    # user is using CLIPS syntax
    elif s.find('equation') != -1:
        return s

    return 'error'

    # return '(equation ?rhs equal $?first ?operator1 ?id ?operand1&:(numberp ?operand1) split ?id mult ?id2 ?coef split ?id2 x $?last)'

def is_number (token):
    try:
        float(token)
        return True
    except:
        return False




write_clips('(clear)')
write_clips('(load basic_solver.clp)')
write_clips('(reset)')
write_clips('(run)')
read_clips()

# write_clips('(watch rules)')
# write_clips('(watch facts)')
# write_clips('(unwatch rules)')
# write_clips('(unwatch facts)')

try:
    while True:
        userInput = raw_input(promptInput)

        if userInput == '':
            continue
        elif userInput == 'exit':
            break
        elif userInput == 'help':
            print promptHelp
            continue

        userInput = convert_input(userInput)

        if userInput != 'error':
            write_clips(userInput)
            sleep(0.2)
            read_clips()
        else:
            print promptInputError

except KeyboardInterrupt:
    print 'KeyboardInterrupt, exit clips'
    close_clips()

close_clips()

