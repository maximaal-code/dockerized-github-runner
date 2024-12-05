# Github Actions Runner

This project contains a simple Dockerfile I made that registers a container as a GitHub Actions runner for a repository. The Dockerfile is based on the tutorial by [That DevOps Guy](https://www.youtube.com/watch?v=RcHGqCBofvw).

# How to use

Follow the steps below to build and run the GitHub Actions runner in Docker.

### 1. Build the Docker Image

To build the Docker image from the root directory, run:

```bash
docker build -t github-runner .
```

### 2. Register the Runner with Your Github Repository

Next, you'll need to register the runner with a GitHub repository.

1. Navigate to your GitHub repository.
2. Go to **Settings** > **Actions** > **Runners**.
3. Under Self-hosted runners, click on Add runner.
4. Copy the registration URL and token provided.

### 3. Run the Docker Container

Use the following command to start the runner container. Be sure to replace the placeholders with your actual values.

```bash
docker run -e GITHUB_REPO_URL="<https://github.com/repo_you_wanna_add_a_runner_to>" \
           -e GITHUB_RUNNER_TOKEN="<your_token>" \
           -v /var/run/docker.sock:/var/run/docker.sock \
           -d --name runner-container github-runner
```

- `GITHUB_REPO_URL`: The URL of your GitHub repository (e.g., `https://github.com/your-username/your-repository`).
- `GITHUB_RUNNER_TOKEN`: The registration token copied from GitHub.
- `-v /var/run/docker.sock:/var/run/docker.sock`: Binds the Docker socket from the host to the container, allowing the runner to use the Docker engine.

### 4. Verify Runner Registration

Once the container is running, Verify that the runner has been registered successfully by going back to **Settings** > **Actions** > **Runners** in your GitHub repository. Your self-hosted runner should appear in the list.

## Restrictions

The runner does need a docker engine supplied before it can be used. You can pass the hosts docker engine with `-v /var/run/docker.sock:/var/run/docker.sock` or use a different docker engine.

## Docker Compose Example

Here’s an example of how to deploy a GitHub Actions runner using **docker compose**. This setup uses Docker-in-Docker (DinD) to provide the underlying Docker engine for the runner container.

```yml
services:
  runner:
    build:
      context: .
    environment:
      - GITHUB_REPO_URL=<https://github.com/repo_you_wanna_add_a_runner_to>
      - GITHUB_RUNNER_TOKEN=<your_token>
      - DOCKER_HOST=tcp://dind:2375
  dind:
    image: docker:dind
    privileged: true
    environment:
      DOCKER_TLS_CERTDIR: ""
    expose:
      - "2375"
```

### Explanation

- `github-actions-runner`: The service running the GitHub Actions runner.

  - `DOCKER_HOST=tcp://dind:2375`: Configures the GitHub Actions runner to use the Docker daemon exposed by the dind container.
  - `depends_on`: Ensures the `github-actions-runner` starts after the `dind` container is ready.

- `dind`: A container running Docker-in-Docker (DinD) to act as the Docker engine for the runner.
  - `privileged: true`: Allows the dind container to run Docker.
  - `expose: "2375"`: Exposes the Docker daemon over TCP on port 2375, allowing other containers to interact with it
