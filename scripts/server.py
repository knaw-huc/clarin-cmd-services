from flask import Flask, render_template, request
import os
from saxonche import PySaxonProcessor, PyXdmValue, PySaxonApiError

app = Flask(__name__)

@app.route("/clarin/cmd/mapping/check", methods=['GET'])
#  localhost/clarin/cmd/mapping/check?prof=<id>
def check():
    profile = request.args.get('prof', None)

    with PySaxonProcessor(license=False) as proc:
        print(f"Processor: {proc.version}")
        xsltproc = proc.new_xslt30_processor()
        xsltproc.set_cwd(os.getcwd())
        executable = xsltproc.compile_stylesheet(stylesheet_file="data/check.xsl")
        value = proc.make_string_value(profile)
        executable.set_parameter("prof", value)
        result = executable.apply_templates_returning_string(source_file="data/index.html")
    return f"<p>{profile}</p><br/><p>{result}</p>"

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


if __name__ == "__main__": 
    app.run(debug=True) 
