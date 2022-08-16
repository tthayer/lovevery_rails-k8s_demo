# Pulls down a stable Ruby version and installs sqlite3
FROM ruby:2.7.5
WORKDIR /app
# Copies in the Gemfile and Gemfile.lock files
COPY Gemfile* .
# Installs RoR and needed dependencies
RUN apt-get update && apt-get install -y sqlite3 && bundle update && bundle install

# Copy in the rails project
ADD hello-world /app/hello-world

# copies in the entrypoint.sh script that will clean up pids that are left over
# when doing local development work. This will be run prior to the CMD step.
COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Documentation step
EXPOSE 3000

# Runs the rails server and sets it to accept connections fromn any IP
WORKDIR /app/hello-world
RUN bundle install
CMD ["bundle", "exec", "bin/rails", "server", "-p", "3000", "-b", "0.0.0.0"] 
