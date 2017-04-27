FROM docker-artifactory-poc.sln.nc/docker:17.03.0-ce

ARG YARN_VERSION=0.19.1
ARG NODE_VERSION=6.9.2-r1

ENV PATH /root/.yarn/bin:$PATH

RUN apk --no-cache add git curl jq bash yarn

RUN apk add --update --no-cache nodejs=${NODE_VERSION} \
	&& touch ~/.bashrc \
	&& apk add --no-cache --virtual .build-deps-yarn tar gnupg  \
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
RUN yarn global add git-semver-tags \
                    conventional-recommended-bump \
                    semver \
                    git-changelog \
                    msee

COPY template.md /template.md
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]
