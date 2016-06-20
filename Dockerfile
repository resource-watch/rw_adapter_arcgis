FROM ruby:2.3.0
MAINTAINER Sebastian Schkudlara "sebastian.schkudlara@vizzuality.com"

RUN apt-get update -qq && apt-get install -y build-essential nodejs npm nodejs-legacy postgresql-client libpq-dev libxml2-dev libxslt1-dev

RUN mkdir /rw_adapter_arcgis

WORKDIR /rw_adapter_arcgis
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

ADD . /rw_adapter_arcgis

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 3035

ENTRYPOINT ["./entrypoint.sh"]
