ARG ruby_version
FROM ruby:${ruby_version}

ENV BUNDLE_JOBS=4 BUNDLE_PATH=/vendor/bundle LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y less git

RUN useradd --create-home --user-group --uid 1000 app
RUN mkdir -p /app/tmp /vendor/bundle/$RUBY_VERSION
RUN chown -R app /app /vendor

WORKDIR /app

USER app
