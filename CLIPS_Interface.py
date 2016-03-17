from subprocess import Popen, PIPE
from time import sleep
from fcntl import fcntl, F_GETFL, F_SETFL
from os import O_NONBLOCK, read

p = Popen('/Users/louis/workspace/CS4244/CLIPS Console', 
           shell=False, stdin=PIPE, stdout=PIPE, stderr= PIPE)

flags = fcntl(p.stdout, F_GETFL) # get current p.stdout flags
fcntl(p.stdout, F_SETFL, flags | O_NONBLOCK)

def write_clips(cmd):
    p.stdin.write(cmd+'\n')
    print cmd
    
def read_clips():
    try:
        print read(p.stdout.fileno(),1024)
    except OSError:
        pass

write_clips('(clear)')
write_clips('(load basic_solver.clp)')
write_clips('(watch rules)')
write_clips('(watch facts)')
# write_clips('(unwatch rules)')
# write_clips('(unwatch facts)')
write_clips('(reset)')
write_clips('(run)')

sleep(0.1)
read_clips()

write_clips('(exit)')
p.terminate()

