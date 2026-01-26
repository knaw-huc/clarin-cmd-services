import uuid
import hashlib
import logging
import httpx
import os
import urllib
from pydantic import BaseModel
from fastapi.staticfiles import StaticFiles
from fastapi import FastAPI, Query, HTTPException, Request, Response
from fastapi.responses import JSONResponse, PlainTextResponse, HTMLResponse
from urllib.parse import urlparse, unquote, parse_qs
from fastapi.templating import Jinja2Templates
from saxonche import PySaxonProcessor, PyXdmValue, PySaxonApiError


logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = FastAPI()

templates = Jinja2Templates(directory="templates")


@app.get("/")
def is_running():
    return PlainTextResponse("Cmdi Server running")


@app.get("/clarin/cmd/mapping/", response_class=HTMLResponse)
def index(request: Request):
    return templates.TemplateResponse(request=request, name="index.html")


@app.get("/clarin/cmd/mapping/check", response_class=HTMLResponse)
def check(prof: str = None):
    logger.info(f"Check {prof}")
    p_url = f"https://catalog.clarin.eu/ds/ComponentRegistry/rest/registry/1.x/profiles/{prof}/xml"
    decoded_url = unquote(p_url)
    logger.info(f"decoded_url {decoded_url}")
    parsed_url = urlparse(decoded_url)
    logger.info(f"parsed_url {parsed_url}")
    try:
        response = httpx.get(decoded_url, follow_redirects=Query(True))
        if 199 < response.status_code < 300:
            content = response.content
            logger.debug(f"Origin Content: {content}")
            content = parse_content(content)
            logger.debug(f"Result Content: {content}")
        else:
            content = f"Error: Received status code {response.status_code} from {decoded_url}"
            logger.error(content)
        return HTMLResponse(content=content, status_code=200)
    except httpx.RequestError as e:
        raise HTTPException(status_code=502, detail=str(e))



def parse_content(content):
    prof_result = content
    profile = prof_result.decode("utf8")
    # facet
    f_url = "https://raw.githubusercontent.com/clarin-eric/VLO-mapping/master/mapping/facetConcepts.xml"
    fp = urllib.request.urlopen(f_url) #,context=context)
    facet_result = fp.read()
    facet = facet_result.decode("utf8")
    fp.close()
    #
    with PySaxonProcessor(license=False) as proc:
        print(f"Processor: {proc.version}")
        xsltproc = proc.new_xslt30_processor()
        xsltproc.set_cwd(os.getcwd())
        executable = xsltproc.compile_stylesheet(stylesheet_file="data/check.xsl")
        config = proc.parse_xml(xml_text=facet)
        executable.set_parameter("conf", config)
        node = proc.parse_xml(xml_text=profile)
        result = executable.transform_to_string(xdm_node=node)
    return result




