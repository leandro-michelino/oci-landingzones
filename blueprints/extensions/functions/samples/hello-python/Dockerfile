FROM fnproject/python:3.11-dev AS build-stage

WORKDIR /function
ENV PYTHONPATH=/function:/python

COPY requirements.txt /function/
RUN pip3 install --target /python --no-cache-dir -r requirements.txt

COPY func.py func.yaml /function/

FROM fnproject/python:3.11

WORKDIR /function
ENV PYTHONPATH=/function:/python

COPY --from=build-stage /python /python
COPY --from=build-stage /function /function

HEALTHCHECK NONE
USER 1000

ENTRYPOINT ["/python/bin/fdk", "/function/func.py", "handler"]
