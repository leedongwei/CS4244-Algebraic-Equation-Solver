# import os
from os import read,path
import platform
from subprocess import Popen, PIPE
from time import sleep
import sys
import re
from interpreter import *


## Strings to guide users
promptClear = (
    '\r\n'
    '******************************'
    '******************************'
    '\r\n'
)
promptHelp = (
    'Enter equation to solve (3x+4)+5x=1 \r\n'
    'AVAILABLE COMMANDS:\r\n'
    'help: Display this help screen \r\n'
    'exit: Close CLIPS \r\n\r\n'

    'Please use exit to quit this program to ensure that CLIPS\r\n'
    'does not continue to in the background and consume resources\r\n'
)
promptInput = 'Solve> '
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

        eqn = ClipsConverter(userInput)
        eqn.parse()
        if eqn.output != 'error':
            write_clips('(clear)')
            write_clips('(load init.clp)')
            write_clips('(deffacts initial_equation (equation %s))'%eqn.output)
            write_clips('(defglobal ?*next_id* = %s)'%(eqn.nextOperatorId))
            write_clips('(load inversion.clp)')
            write_clips('(load association.clp)')
            write_clips('(watch rules)')
            write_clips('(watch facts)')
            write_clips('(reset)')
            write_clips('(run)')

            print eqn.output
            s = ''
            tmp = read_clips()
            while tmp!=None:
                s += tmp
                sleep(0.1)
                tmp = read_clips()
            print s.replace("CLIPS> ","")
        else:
            print promptInputError
            

except KeyboardInterrupt:
    print 'KeyboardInterrupt, exit clips'
    close_clips()
except Exception,e:
    print e
    close_clips()
    
close_clips()

