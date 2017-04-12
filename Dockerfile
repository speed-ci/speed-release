FROM docker-artifactory-poc.sln.nc/node:6.10.1-alpine

# Setup release folder
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

RUN apk --no-cache add git

RUN npm config set registry https://artifactory-poc.sln.nc/artifactory/api/npm/npm/ -g

# Install release tools
RUN npm install -g git-semver-tags \
                   conventional-recommended-bump \
                   semver \
                   git-changelog \
                   cli-gitlab

RUN npm ls -g --depth=0

COPY docker-entrypoint.sh /docker-entrypoint.sh


CMD ["/docker-entrypoint.sh"]
