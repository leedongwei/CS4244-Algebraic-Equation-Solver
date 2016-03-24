# import os
from os import read
import platform
from subprocess import Popen, PIPE
from time import sleep

def write_clips(cmd):
  p.stdin.write(cmd+'\n')
  # print cmd

def read_clips():
  try:
    print read(p.stdout.fileno(),1024)
  except OSError:
    pass

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

print '\r\n\r\n************************************************************\r\n'

read_clips()

write_clips('(clear)')
write_clips('(load basic_solver.clp)')

read_clips()
# write_clips('(watch rules)')
# write_clips('(watch facts)')
# write_clips('(unwatch rules)')
# write_clips('(unwatch facts)')
write_clips('(reset)')
write_clips('(run)')



response = raw_input("Enter Equation: (eg. 3 = 2x + 1)\r\n ")

sleep(0.2)
read_clips()

write_clips('(exit)')
# p.terminate()
Popen.terminate
