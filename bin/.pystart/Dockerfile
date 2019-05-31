FROM conda:0.5

RUN pip --no-cache-dir --disable-pip-version-check install \
    'flask>=1.0.2' \
    'celery>=4.3.0' \
    gunicorn \
    'meinheld>=1.0.1'

ARG PACKAGE_VERSION

RUN pip --no-cache-dir --disable-pip-version-check install \
    example==$PACKAGE_VERSION

COPY scripts/* /tmp/scripts/

WORKDIR /tmp
