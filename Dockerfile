FROM docker-artifactory.sln.nc/node:6.10.1-alpine

# Setup release folder
RUN mkdir -p /usr/src/app
WORKDIR /srv/speed
VOLUME /srv/speed

RUN apk --no-cache add git curl jq bash

ARG ARTIFACTORY_URL
ARG ARTIFACTORY_USER
ARG ARTIFACTORY_PASSWORD

RUN curl --noproxy '*' -u $ARTIFACTORY_USER:$ARTIFACTORY_PASSWORD $ARTIFACTORY_URL/artifactory/api/npm/auth > ~/.npmrc && \
    npm config set registry $ARTIFACTORY_URL/artifactory/api/npm/npm/ -g && \
    npm set strict-ssl false

# Install release tools
RUN npm install -g git-semver-tags \
                   conventional-recommended-bump \
                   semver \
                   git-changelog \
                   msee

RUN npm ls -g --depth=0

COPY template.md /template.md
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

RUN touch /usr/bin/docker

CMD ["/docker-entrypoint.sh"]