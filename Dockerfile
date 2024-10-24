FROM http://registry.gitlab.com/clarin-eric/docker-alpine-dog-uwsgi:1.0.2-a5

ADD scripts ./

RUN pip install -r requirements.txt

RUN pip install --trusted-host pypi.python.org gunicorn
ENV PYTHONPATH ./scripts
ENV PYTHONUNBUFFERED 1

CMD ["gunicorn", "-b", ":5000", "-t", "60", "-w", "1", "server:app"]

EXPOSE 5000
