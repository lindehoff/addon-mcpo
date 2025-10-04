ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install jq for JSON parsing in bash
RUN apk add --no-cache jq bash

COPY run.sh /
RUN chmod a+x /run.sh
CMD [ "/run.sh" ]

