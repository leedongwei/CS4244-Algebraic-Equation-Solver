import os
from os import read,path
import platform
from subprocess import Popen, PIPE
from time import sleep
import sys
import re
from interpreter import *

## Load CLIPS based on Operating System
p = None
if platform.system() == 'Darwin':
    print '\r\nLoading CLIPS for Mac OS X...'

    from fcntl import fcntl, F_GETFL, F_SETFL
    from os import O_NONBLOCK

    #For safety
    os.system('killall CLIPS_console_mac')

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

def print_progress(log):
    for s in log.splitlines():
        if s.find('FIRE')!=-1:
            rule_used = s.split()[2]
            print "Apply %s: "%rule_used,
        if s.find('==>')!=-1 and s.find('equation')!=-1:
            eq_str = s[s.find('equation')-1:]
            print_equation(eq_str)

#Test case 1:
# equation = "(4+5x)+(x*8)*16=2"
equation = "(4+5x)+(x*8)+16=2"
eqn = ClipsConverter(equation)
eqn.parse()

if eqn.output != 'error':
    write_clips('(clear)')
    write_clips('(load init.clp)')
    write_clips('(deffacts initial_equation (equation %s))'%eqn.output)
    write_clips('(defglobal ?*next_id* = %s)'%(eqn.nextOperatorId))
    write_clips('(load inversion.clp)')
    write_clips('(load first_order_solver.clp)')
    write_clips('(watch rules)')
    write_clips('(watch facts)')
    write_clips('(reset)')
    write_clips('(run)')
    sleep(0.2)

    print '(equation %s)'%eqn.output

    try:
        for wait_attempt in range(5):
            s = ''
            tmp = read_clips()
            while tmp!=None and s[:-7]!='CLIPS> ':
                s += tmp
                sleep(0.1)
                tmp = read_clips()
            if s!= '':
                print s.replace("CLIPS> ","")
                print_progress(s)
            else:
                print '....'
            sleep(1)
    except KeyboardInterrupt:
        pass
else:
    print "Please check equation syntax"

close_clips()