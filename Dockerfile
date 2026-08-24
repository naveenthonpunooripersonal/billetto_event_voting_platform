FROM ruby:3.4

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y \
      build-essential \
      libpq-dev \
      curl \
      git \
      libyaml-dev \
      pkg-config \
      nodejs \
      npm && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler

COPY Gemfile Gemfile.lock* ./

RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]