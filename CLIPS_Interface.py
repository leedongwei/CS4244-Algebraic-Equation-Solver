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
        'calc' : lambda a,b: a / b },
    ')' : {
        'id'   : ')',
        'prec' : 0,
        'calc' : lambda a,b: a / b },
    # addition
    '+' : {
        'id'   : '+',
        'prec' : 1,
        'calc' : lambda a,b: a + b },
    # subtraction
    '-' : {
        'id'   : '-',
        'prec' : 1,
        'calc' : lambda a,b: a - b },
   # multiplication
    '*' : {
        'id'   : '*',
        'prec' : 2,
        'calc' : lambda a,b: a * b },
    # division
    '/' : {
        'id'   : '/',
        'prec' : 2,
        'calc' : lambda a,b: a / b },
}




## Load CLIPS based on Operating System
p = None
if platform.system() == 'Darwin':
    print '\r\nLoading CLIPS for Mac OS X...'

    from fcntl import fcntl, F_GETFL, F_SETFL
    from os import O_NONBLOCK
    exec_dir = path.dirname(path.realpath(__file__))
    exec_path = path.join(exec_dir,'CLIPS_console_mac')

    p = Popen('CLIPS_console_mac',
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
        self.input = inp
        self.operators = operators

    def parse(self):
        self.operatorStack = []
        self.variableStack = []
        self.postfixString = []
        tokens = self.input.replace(' ', '')
        tokens = [x for x in re.split('([+-/*\(\)])', tokens) if x != '']
        while tokens:
            self.parse_token(tokens.pop(0))
        while self.operatorStack:
            self.postfixString.append(self.operatorStack.pop())

    def parse_token (self, tok):
        if is_number(tok):
            self.postfixString.append(tok)
        elif 'x' in tok:
            self.postfixString.append(tok)
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
                if prevTok == '(':
                  break
                else:
                  self.postfixString.append(prevTok)
        elif (not self.operatorStack) or self.operatorStack[-1] == '(':
            self.operatorStack.append(tok)
        else:
            while self.operatorStack and weaker(tok, self.operatorStack[-1]):
                temp = self.operatorStack.pop()
                self.postfixString.append(temp)

            self.operatorStack.append(tok)





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

    if s.find('=>') != -1:
        temp = s.split('=>')
        if len(temp) > 2:
          return 'error'

        LHS = ClipsConverter(temp[0])
        RHS = ClipsConverter(temp[1])

        LHS.parse()
        RHS.parse()


        # TODO: DongWei
        print ' --- POSTFIXSTRING ---'
        print LHS.postfixString
        print RHS.postfixString
        # print LHS.operatorStack
        # print LHS.postfixString

    # user is  using CLIPS syntax
    elif s.find('equation') != -1:
        print 'equation'

    return 'error'

    # return '(equation ?rhs equal $?first ?operator1 ?id ?operand1&:(numberp ?operand1) split ?id mult ?id2 ?coef split ?id2 x $?last)'

def is_number (string):
    try:
        float(string)
        return True
    except ValueError:
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

