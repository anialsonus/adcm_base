FROM python:3.10-alpine

COPY requirements*.txt /
COPY build*.sh /
COPY default-venv.sh /etc/profile.d/

RUN /build.sh

CMD ["/bin/bash -l"]
