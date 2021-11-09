FROM ruby:3.0.2 AS builder

ARG RAILS_ROOT=/usr/src/app/
WORKDIR $RAILS_ROOT

  # build-base \
  # curl-dev \
RUN apt-get update && apt-get install -y \
  nodejs \
  postgresql-13 \
  tzdata \
  gcc \
  git \
  yarnpkg

COPY package*.json yarn.lock Gemfile* $RAILS_ROOT
RUN yarnpkg install --check-files --frozen-lockfile && \
      bundle config --global frozen 1 && bundle install

### BUILD STEP DONE ###

FROM ruby:3.0.2

ARG RAILS_ROOT=/usr/src/app/
WORKDIR $RAILS_ROOT

	# addgroup -S app; \
	# adduser -S -D -G app -H -h $RAILS_ROOT -s /bin/sh app; \
RUN set -eux; \
  groupadd -f app; \
  useradd -g app -d $RAILS_ROOT -s /bin/sh app; \
	chown -R app:app $RAILS_ROOT

  # su-exec \
RUN apt-get update && apt-get install -y \
  bash\
  nodejs \
  postgresql-client \
  tzdata \
  gcc \
  && rm -rf /var/cache/apk/*
  # Install latest su-exec
RUN  set -ex; \
  \
  curl -o /usr/local/bin/su-exec.c https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c; \
  \
  fetch_deps='gcc libc-dev'; \
  apt-get update; \
  apt-get install -y --no-install-recommends $fetch_deps; \
  rm -rf /var/lib/apt/lists/*; \
  gcc -Wall \
      /usr/local/bin/su-exec.c -o/usr/local/bin/su-exec; \
  chown root:root /usr/local/bin/su-exec; \
  chmod 0755 /usr/local/bin/su-exec; \
  rm /usr/local/bin/su-exec.c

COPY --from=builder $RAILS_ROOT $RAILS_ROOT
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

COPY . .

RUN chown -R app:app $RAILS_ROOT

EXPOSE 3000
EXPOSE 4040

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["abalone"]
