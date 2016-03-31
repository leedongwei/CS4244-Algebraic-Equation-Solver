# import os
from os import read,path
import platform
from subprocess import Popen, PIPE
from time import sleep
import sys

p = None
if platform.system() == 'Darwin':
  print '\r\n Loading CLIPS for Mac OS X...'
  
  from fcntl import fcntl, F_GETFL, F_SETFL
  from os import O_NONBLOCK
  exec_dir = path.dirname(path.realpath(__file__))
  exec_path = path.join(exec_dir,'CLIPS_console_mac')
  p = Popen(exec_path, shell=False, stdin=PIPE, stdout=PIPE, stderr= PIPE)
  flags = fcntl(p.stdout, F_GETFL) # get current p.stdout flags
  fcntl(p.stdout, F_SETFL, flags | O_NONBLOCK)

elif platform.system() == 'Windows':
  print '\r\n Loading CLIPS for Windows...'
  p = Popen('CLIPS_console_windows.exe',
            shell=False, stdin=PIPE, stdout=PIPE, stderr= PIPE)
else:
  print '\r\n OS not supported'
  sys.exit()
print '\r\n\r\n************************************************************\r\n'

def write_clips(cmd):
  global p
  p.stdin.write(cmd+'\n')

def read_clips():
  global p
  try:
    s = read(p.stdout.fileno(),1024)
    return s
  except OSError:
    return None

# response = raw_input("Enter Equation: (eg. 3 = 2x + 1)\r\n ")

#LOAD CLIPS
read_clips()
write_clips('(clear)')
write_clips('(load init.clp)')
write_clips('(load inversion.clp)')
write_clips('(load association.clp)')
write_clips('(watch rules)')
write_clips('(watch facts)')
# write_clips('(unwatch rules)')
# write_clips('(unwatch facts)')
write_clips('(reset)')
write_clips('(run)')


#READ OUTPUT
log = ''
try:
  while True:
    out = read_clips()
    if out:
      out = out.replace('CLIPS> ','')
      print out,
      log+= out
    sleep(0.1)
except KeyboardInterrupt:
  print 'KeyboardInterrupt, exit clips'
  write_clips('(exit)')
  p.terminate()
  Popen.terminate

for s in log.splitlines():
  if s.find('==>')!=-1 and s.find('equation')!=-1:
    eq_str = s[s.find('equation')+9:-1]
    print eq_str

    