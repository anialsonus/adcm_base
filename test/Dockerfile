ARG BASE_IMAGE
ARG BASE_TAG

FROM $BASE_IMAGE:$BASE_TAG

COPY requirements-test.txt /
COPY linters.sh /
RUN apk add --update --no-cache shellcheck
RUN pip install -r /requirements-test.txt

CMD ["/bin/sh"]
