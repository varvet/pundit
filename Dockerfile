
FROM ghcr.io/catthehacker/ubuntu:runner-22.04

# Set environment variables
ENV PATH=/home/runner/.local/bin:$PATH

# Create working directory and switch to 'runner' user
WORKDIR /usr/src/app
USER runner

# Install dependencies
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends --no-install-suggests \
    default-jre curl bzip2 build-essential libssl-dev libreadline-dev zlib1g-dev git && \
    sudo rm -rf /var/lib/apt/lists/*

# Clone ruby-build and add it to PATH
RUN git clone https://github.com/rbenv/ruby-build.git /home/runner/ruby-build && \
    mkdir -p /home/runner/.local/bin && \
    ln -s /home/runner/ruby-build/bin/ruby-build /home/runner/.local/bin/ruby-build

# Install jruby-9.4.7.0
RUN ruby-build jruby-9.4.7.0 /home/runner/jruby-9.4.7.0

# Update PATH to include the installed JRuby binaries
ENV PATH=/home/runner/jruby-9.4.7.0/bin:$PATH

RUN gem install bundler --no-document

COPY . .
RUN rm Gemfile.lock && bundle install && bundle rspec
