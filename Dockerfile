# syntax=docker/dockerfile:1.7-labs

ARG RUBY_VERSION=3.4
ARG APP_VERSION=0.0
ARG APP_SOURCE="https://github.com/open-ews/open-ews-ivr"
FROM public.ecr.aws/lambda/ruby:$RUBY_VERSION AS build-image

RUN dnf update && \
    dnf -y install git openssl-devel gcc make xz tar

COPY Gemfile Gemfile.lock ${LAMBDA_TASK_ROOT}/

RUN gem install bundler && \
    bundle config --local deployment true && \
    bundle config --local path "vendor/bundle" && \
    bundle config --local without 'development test' && \
    bundle install

RUN rm -rf vendor/bundle/ruby/*/cache/ && find vendor/ -name "*.o" -delete && find vendor/ -name "*.c"

COPY app.rb ${LAMBDA_TASK_ROOT}/
COPY app/ ${LAMBDA_TASK_ROOT}/app/
COPY --exclude=*.key config/ ${LAMBDA_TASK_ROOT}/config/
COPY lib/ ${LAMBDA_TASK_ROOT}/lib/

# #############################

FROM public.ecr.aws/lambda/ruby:$RUBY_VERSION
ARG APP_VERSION
ARG APP_SOURCE

COPY --from=build-image ${LAMBDA_TASK_ROOT} ${LAMBDA_TASK_ROOT}

ENV RUBY_YJIT_ENABLE=true
ENV APP_VERSION=${APP_VERSION}
ENV APP_SOURCE=${APP_SOURCE}

CMD [ "app.App::Handler.process" ]
