FROM ruby:2.3-slim

# Optionally set a maintainer name to let people know who made this image.
MAINTAINER Mohammed  <hassoun@outlook.com>

# Install dependencies:
# - build-essential: To ensure certain gems can be compiled
# - nodejs: Compile assets
# - libpq-dev: Communicate with postgres through the postgres gem
# - postgresql-client: In case you want to talk directly to postgres
RUN apt-get update 
RUN apt-get install -qq -y build-essential nodejs libpq-dev --fix-missing --no-install-recommends
RUN apt-get install -y --no-install-recommends postgresql-client 
RUN rm -rf /var/lib/apt/lists/*

#ENV <key> <value>
# Set an environment variable to store where the app is installed to inside of the Docker image.
ENV INSTALL_PATH /drkiq
RUN mkdir -p $INSTALL_PATH

# The WORKDIR instruction sets the working directory for any RUN, CMD, ENTRYPOINT, 
# COPY and ADD instructions that follow it in the Dockerfile
WORKDIR $INSTALL_PATH

COPY Gemfile Gemfile

RUN bundle install
# Copy in the application code from your work station at the current directory
# over to the working directory and ignore everthing in .dockerignore.
COPY . .

# Provide dummy data to Rails so it can pre-compile assets.
RUN bundle exec rake RAILS_ENV=production DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname SECRET_TOKEN=pickasecuretoken assets:precompile

# Expose a volume so that nginx will be able to read in assets in production.
VOLUME ["$INSTALL_PATH/public"]

# CMD allow you to specify the startup command for an image
# CMD ["rails", "server", "-b", "0.0.0.0"]
CMD bundle exec unicorn -c config/unicorn.rb
