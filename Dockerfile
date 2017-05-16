FROM docker-artifactory.sln.nc/node:6.10.1-alpine

# Setup release folder
RUN mkdir -p /usr/src/app
WORKDIR /srv/speed
VOLUME /srv/speed

RUN apk --no-cache add git curl jq bash

RUN npm config set registry https://artifactory.sln.nc/artifactory/api/npm/npm/ -g

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