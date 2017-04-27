FROM docker-artifactory-poc.sln.nc/docker:17.03.0-ce

ARG YARN_VERSION=0.19.1
ARG NODE_VERSION=6.10.1-alpine

ENV PATH /root/.yarn/bin:$PATH

RUN apk add --update --no-cache nodejs=${NODE_VERSION} \
	&& touch ~/.bashrc \
	&& apk add --no-cache --virtual .build-deps-yarn tar curl bash gnupg git jq  \
	&& rm -rf /var/cache/apk/* \
	&& curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version ${YARN_VERSION} \
	&& apk del .build-deps-yarn \
	&& npm uninstall -g npm \
	&& rm -rf ~/.gnupg ~/.npm

# Setup release folder
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
VOLUME /usr/src/app

RUN yarn config set registry https://artifactory-poc.sln.nc/artifactory/api/npm/npm/ -g

# Install release tools
RUN yarn install -g git-semver-tags \
                   conventional-recommended-bump \
                   semver \
                   git-changelog \
                   msee

RUN yarn ls -g --depth=0

COPY template.md /template.md
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]
