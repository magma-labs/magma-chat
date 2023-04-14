# Use the official Ruby image as the base image
FROM ruby:3.2.1

# Set environment variables
ENV LANG C.UTF-8
ENV APP_HOME /app
ENV BUNDLE_PATH /gems

# Install required packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs yarn

# Create the application directory
RUN mkdir $APP_HOME
# Set the working directory
WORKDIR $APP_HOME

# Copy Gemfile and Gemfile.lock to the working directory
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Start the Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
