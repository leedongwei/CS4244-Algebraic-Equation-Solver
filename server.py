from flask import Flask,render_template,request
app = Flask(__name__)
app.debug = True

from CLIPS_solver import *

solver = CLIPS_solver()

@app.route("/")
def root():
    return render_template('index.html')

@app.route("/submit-equation", methods=['POST'])
def parse_data():
    input_equation = request.form.get('equation')
    res = solver.solve(input_equation)
    if res!=None:
        return res
    else:
        return "FAILED TO SOLVE"

if __name__ == "__main__":
    try:
        app.run()
    except Exception,e:
        print e
        pass
    solver.close_clips()