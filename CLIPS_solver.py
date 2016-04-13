from os import read,path,system
import platform
from subprocess import Popen, PIPE, check_output
from time import sleep
import sys
import re
from interpreter import *

class CLIPS_solver:
    def __init__(self):
        self.p = None
        self.launch_clips()

    def launch_clips(self):
        if platform.system() == 'Darwin':
            # print '\r\nLoading CLIPS for Mac OS X...'

            from fcntl import fcntl, F_GETFL, F_SETFL
            from os import O_NONBLOCK

            #For safety
            system('killall CLIPS_console_mac')

            exec_dir = path.dirname(path.realpath(__file__))
            exec_path = path.join(exec_dir,'CLIPS_console_mac')
            self.p = Popen(exec_path,
                      shell=False,
                      stdin=PIPE,
                      stdout=PIPE,
                      stderr= PIPE)
            flags = fcntl(self.p.stdout, F_GETFL) # get current p.stdout flags
            fcntl(self.p.stdout, F_SETFL, flags | O_NONBLOCK)

        elif platform.system() == 'Windows':
            print '\r\nLoading CLIPS for Windows...'
            self.p = Popen('CLIPS_console_windows.exe',
                      shell=False,
                      stdin=PIPE,
                      stdout=PIPE,
                      stderr= PIPE)
        else :
            print '\r\nOS not supported'
            return False
        return True

    def write_clips(self,cmd):
        self.p.stdin.write(cmd+'\n')

    def read_clips(self):
        try:
            s = read(self.p.stdout.fileno(), 2048)
            return s
        except OSError:
            return None

    def close_clips(self):
        print 'closing CLIPS'
        self.p.stdin.write('exit\n')
        self.p.terminate()
        Popen.terminate

    def print_progress(self,log):
        print 'Equation:'
        for s in log.splitlines():
            if s.find('FIRE')!=-1:
                rule_used = s[s.find('FIRE'):].split()[2]
                if rule_used!='final_result:':
                    print "Apply %s "%rule_used
            if s.find('==>')!=-1 and s.find('equation')!=-1:
                eq_str = s[s.find('equation')-1:]
                print '\t',
                print_equation(eq_str)

        if log.find('final_result')==-1:
            print "FAILED TO SOLVE FOR X"


    def get_progress_HTML(self,log):
        output = ''
        final_result_flag = 0
        for s in log.splitlines():
            if s.find('FIRE')!=-1:
                rule_used = s[s.find('FIRE'):].split()[2]
                if not rule_used in ['final_result:', 'final_result2:']:
                    output += "<div class='output-step'><div class='output-step-head'>Apply %s </div>"%rule_used
                else:
                    final_result_flag = 1
            if s.find('==>')!=-1 and s.find('equation')!=-1:
                eq_str = s[s.find('equation')-1:]
                output += "<div class='output-step-eqn'>$$ %s $$</div></div>"%interprete_equation(eq_str)
        print "\n\n log: \n\n ", log
        print ":log"
        if not final_result_flag:
            output += "FAILED TO SOLVE FOR X"
        return output

    def solve(self,equation_str):
        eqn = ClipsConverter(equation_str)
        eqn.parse()
        if eqn.output != 'error':
            self.write_clips('(clear)')
            self.write_clips('(load init.clp)')
            self.write_clips('(deffacts initial_equation (equation %s))'%eqn.output)
            self.write_clips('(bind ?*next_id* = %s)'%(eqn.nextOperatorId))
            self.write_clips('(load inversion.clp)')
            self.write_clips('(load first_order_solver.clp)')
            self.write_clips('(load second_order_solver.clp)')
            self.write_clips('(watch rules)')
            self.write_clips('(watch facts)')
            self.write_clips('(reset)')
            self.write_clips('(run)')
            sleep(0.2)

            try:
                s= ''
                tmp = ''
                while True:
                    tmp = self.read_clips()
                    if tmp!=None:
                        s += tmp
                        if 'CLIPS>' in s.splitlines()[-1].rstrip():
                            break
                    sleep(0.1)
                print s.replace("CLIPS> ","")
                self.print_progress(s)
                return self.get_progress_HTML(s)
            except KeyboardInterrupt:
                return None
        else:
            print "Please check equation syntax"
        return None