# import os
from os import read
import platform
from subprocess import Popen, PIPE
from time import sleep

def write_clips(cmd):
  p.stdin.write(cmd+'\n')

def read_clips():
  try:
    clipsOut =  read(p.stdout.fileno(), 99999)
    if clipsOut == '':
      print 'lol'
    else:
      print clipsOut
  except OSError:
    pass

def close_clips():
  write_clips('(exit)')
  Popen.terminate
  print 'Close CLIPS and exit'

def convert_input(userInput):
  return 'error'
  # return '(equation ?rhs equal $?first ?operator1 ?id ?operand1&:(numberp ?operand1) split ?id mult ?id2 ?coef split ?id2 x $?last)'




## Strings to guide users
promptClear = (
  '\r\n'
  '******************************'
  '******************************'
  '\r\n\r\n'
)
promptHelp = (
  '--help: Display this help screen \r\n'
  '--exit: Close CLIPS \r\n\r\n'

  'Please use --exit to quit this program to ensure that CLIPS\r\n'
  'does not continue to in the background and consume resources'
)
promptInput = '\r\n\r\nEnter command or equation:\r\n'
promptInputError = (
  'ERROR: Does not recognize command or wrong syntax for equation'
)


## Load CLIPS based on Operating System
if platform.system() == 'Darwin':
  print '\r\n\r\nLoading CLIPS for Mac OS X...'
  p = Popen('CLIPS_console_mac',
            shell=False,
            stdin=PIPE,
            stdout=PIPE,
            stderr= PIPE)
if platform.system() == 'Windows':
  print '\r\n\r\nLoading CLIPS for Windows...'
  p = Popen('CLIPS_console_windows.exe',
            shell=False,
            stdin=PIPE,
            stdout=PIPE,
            stderr= PIPE)



print promptClear
print promptHelp
print '\r\n'

write_clips('(clear)')
write_clips('(load basic_solver.clp)')
write_clips('(reset)')
write_clips('(run)')
read_clips()

# write_clips('(watch rules)')
# write_clips('(watch facts)')
# write_clips('(unwatch rules)')
# write_clips('(unwatch facts)')

while True:
  userInput = raw_input(promptInput)
  print ' '

  if userInput == 'exit':
    break
  if userInput == 'help':
    print promptHelp
    continue

  userInput = convert_input(userInput)

  if userInput != 'error':
    write_clips(userInput)
    sleep(0.25)
    read_clips()
  else:
    print promptInputError


close_clips()