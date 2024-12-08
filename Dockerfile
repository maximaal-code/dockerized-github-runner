FROM debian:bookworm-slim

# based on tutorial from:
# https://www.youtube.com/watch?v=RcHGqCBofvw

# add version args
ARG RUNNER_VERSION="2.321.0"

# update packages
RUN apt-get update && \
    apt-get install -y ca-certificates curl sudo jq 
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

# instal docker cli
RUN apt-get update && \
    apt-get install -y docker-ce-cli

# Setup github user
RUN useradd -m github && \
    usermod -aG sudo github && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# setup github runner
USER github
WORKDIR /actions-runner
# Download the latest runner package
RUN curl -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz | tar xz
# Install .net dependancies 
RUN sudo ./bin/installdependencies.sh

# Setup workdir
RUN sudo mkdir /work
RUN sudo chown github /work

COPY --chown=github:github ./entrypoint.sh .
COPY ./entrypoint.sh .
RUN chmod +x ./entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]
