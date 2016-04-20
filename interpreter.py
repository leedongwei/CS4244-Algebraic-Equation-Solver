import re

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

def is_number (token):
    try:
        float(token)
        return True
    except:
        return False

class ClipsConverter:
    def __init__(self, inp):
        self.input = inp.replace(' ', '')
        self.input = self.input.replace("x^2","x*x")

        self.operators = operators
        self.operatorStack = []
        self.variableStack = []
        self.shuntedTokens = []
        self.nextOperatorId = 1
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

        # print 'LHS: ' + LHS_RHS_out[0]
        # print 'RHS: ' + LHS_RHS_out[1]
        self.output = ' equal '.join(LHS_RHS_out)
        self.output = self.output.replace('\n', ' ').replace('\r', '').replace("    ", "")


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


    def build_CLIPS_eqn(self, tok):
        if is_number(tok) or 'x' in tok:
            return str(tok)

        if not isinstance(tok['calc'], str):
            return None
        else:
            rightOperand = self.build_CLIPS_eqn(
                                self.shuntedTokens.pop())
            leftOperand = self.build_CLIPS_eqn(
                                self.shuntedTokens.pop())
            depth = str(self.nextOperatorId)
            self.nextOperatorId += 1

            output = []
            output.append(tok['calc'])
            output.append(depth)
            output.append(leftOperand)
            output.append('split')
            output.append(depth)
            output.append(rightOperand)
            output.append('end')
            output.append(depth)

            return  ' '.join(output)

#sample usecase
# eqn =  ClipsConverter('(4 + 5* x) + (x * 8) * 16 = 2')
# eqn.parse()
# print eqn.output
# print eqn.nextOperatorId

CLIPS_operators = ['add','sub','mult','div']

def print_func(lq):
    x = lq.pop(0)
    if x in CLIPS_operators:
        x_id = lq.pop(0)
        operand1 = []
        operand2 = []    
        while not (lq[0]=='split' and lq[1]==x_id):
            operand1.append(lq.pop(0))
        lq.pop(0)
        lq.pop(0)
        while not (lq[0]=='end' and lq[1]==x_id):
            operand2.append(lq.pop(0))
        lq.pop(0)
        lq.pop(0)
        
        op = ''
        if x=='add':
            op = '+'
        elif x=='sub':
            op = '-'
        elif x=='mult':
            op = '\cdot '
        elif x=='div':
            op = '/'
        else:
            op = '_%s_'%x

        x1 = print_func(operand1)
        x2 = print_func(operand2)
        if x2=='x' and op=='\cdot ' and is_number(x1):
            sign = "" if int(x1) >= 0 else "-"
            return "%sx"%x1 if abs(int(x1)) != 1 else sign+"x"
        elif x1 == "x" and op=='\cdot ' and x2 == "x":
            return "x^2"
        elif x2=='x^2' and op=='\cdot ' and is_number(x1):
            sign = "" if int(x1) >= 0 else "-"
            return "%sx^2"%x1 if abs(int(x1)) != 1 else sign+"x^2"
        else:
            return "(%s%s%s)"%(x1,op,x2)
        
    else:
        return ", ".join([x] + lq)
    
def print_equation(s):
    s = s[10:-1]
    l = s.split('equal')
    LHS = print_func(l[0].split())
    RHS = print_func(l[1].split())
    if LHS[0]=='(' and LHS[-1]==")":
        LHS = LHS[1:-1]
    if RHS[0]=='(' and RHS[-1]==")":
        RHS = RHS[1:-1]
    print LHS,'=',RHS

def interprete_equation(s):
    s = s[10:-1]
    l = s.split('equal')
    LHS = print_func(l[0].split())
    RHS = print_func(l[1].split())
    if LHS[0]=='(' and LHS[-1]==")":
        LHS = LHS[1:-1]
    if RHS[0]=='(' and RHS[-1]==")":
        RHS = RHS[1:-1]
    return "%s=%s"%(LHS,RHS)