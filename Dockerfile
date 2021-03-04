# Create an image based on this existing ruby image
FROM ruby:2.5.7

# Install the software you need
RUN apt-get update && apt-get install -y netcat

# Create a directory for your app
RUN mkdir -p /app

# Set the working directory for all following commands
WORKDIR /app

# Copy the files needed for the bundle install
COPY ./Gemfile /app/Gemfile
COPY ./Gemfile.lock /app/Gemfile.lock

# Install gems
RUN bundle install

COPY . /app
RUN chmod +x /app/entrypoint.sh
EXPOSE 3000

