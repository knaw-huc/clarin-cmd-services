import os
import ssl
import urllib.request
from flask import Flask, render_template, request
from saxonche import PySaxonProcessor, PyXdmValue, PySaxonApiError


app = Flask(__name__)


@app.route("/clarin/cmd/mapping",)
def index():
    return render_template("index.html")

@app.route("/clarin/cmd/mapping/check", methods=['GET'])
def check():
    # dirty trick to avoid "urlopen error [SSL: CERTIFICATE_VERIFY_FAILED] ... ":
    context = ssl._create_unverified_context()
    # profile
    prof = request.args.get('prof', None)
    p_url = f"https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/{prof}/xml"
    fp = urllib.request.urlopen(p_url,context=context)
    prof_result = fp.read()
    profile = prof_result.decode("utf8")
    fp.close()
    # facet
    f_url = "https://raw.githubusercontent.com/clarin-eric/VLO-mapping/master/mapping/facetConcepts.xml"
    fp = urllib.request.urlopen(f_url,context=context)
    facet_result = fp.read()
    facet = facet_result.decode("utf8")
    fp.close()
    #
    with PySaxonProcessor(license=False) as proc:
        print(f"Processor: {proc.version}")
        xsltproc = proc.new_xslt30_processor()
        xsltproc.set_cwd(os.getcwd())
        executable = xsltproc.compile_stylesheet(stylesheet_file="data/check.xsl")
        config = proc.make_string_value(facet)
        executable.set_parameter("conf", config)
        result = executable.apply_templates_returning_string(source_file=profile)
    return result

@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


if __name__ == "__main__": 
    app.run(debug=True) 
