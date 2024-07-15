from flask import Flask, render_template

app = Flask(__name__)

@app.route("/clarin/cmd/mapping/check", methods=['GET'])
#  localhost/clarin/cmd/mapping/check?prof=<id>
def check():
    return render_template('index.html') #, person=name)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


if __name__ == "__main__": 
    app.run(debug=True) 
