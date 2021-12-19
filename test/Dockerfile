ARG BASE_IMAGE
ARG BASE_TAG

FROM $BASE_IMAGE:$BASE_TAG

COPY requirements-test.txt /
COPY linters.sh /
COPY install_reqs_to_default.sh /
RUN apk add --update --no-cache shellcheck
RUN /install_reqs_to_default.sh

CMD ["/bin/sh"]
