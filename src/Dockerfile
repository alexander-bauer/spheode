# vim: filetype=dockerfile
FROM alpine:3

LABEL maintainer="Alexander Bauer sasha@linux.com"

RUN apk add \
       git \
       py3-pip \
       python3 \
       rsync

ARG INSTALL_ROOT=/usr/local

COPY pip.conf /etc/pip.conf
RUN mkdir ${INSTALL_ROOT}/share/spheode

# Install Python requirements.
COPY requirements.txt ${INSTALL_ROOT}/share/spheode/
RUN python3 -m pip install -r ${INSTALL_ROOT}/share/spheode/requirements.txt

# Install other Spheode resources.
COPY conf ${INSTALL_ROOT}/share/spheode/conf
COPY spheode.sh ${INSTALL_ROOT}/bin/spheode

EXPOSE 8000

VOLUME /export
VOLUME /repo
WORKDIR /repo
ENTRYPOINT [ "spheode" ]
CMD [ "autobuild" ]
