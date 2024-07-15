from flask import Flask, render_template, request

app = Flask(__name__)

@app.route("/clarin/cmd/mapping/check", methods=['GET'])
#  localhost/clarin/cmd/mapping/check?prof=<id>
def check():
    profile = request.args.get('prof', None)
    return f"<b>{profile}</b>"
#    return render_template('index.html', profile=profile)

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


if __name__ == "__main__": 
    app.run(debug=True) 
