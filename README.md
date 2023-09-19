# Personal ArchLinux Docker Setup for Development Environment

## This Docker setup provides a ready-to-use ArchLinux environment for development purposes. It includes essential tools and packages commonly used in development workflows. This image is based on ArchLinux and is designed to be used as a containerized development environment.

### Usage
Build the Docker Image
To build the Docker image, execute the following command:

```bash
Copy code
docker build -t arch-dev .
```

### Run the Docker Container
To start a container based on this image, run:

```bash
Copy code
docker run -it --rm arch-dev
```
This will drop you into a shell within the ArchLinux environment.

## Accessing Your Development Files
The `work` directory in the container is mapped to the `work` directory on your local machine. You can place your project files here, and they will be accessible from both inside and outside the container.

## Using Zsh
The default shell in this environment is Zsh. It's pre-configured with some aliases and settings for a smoother development experience.

## Additional Configuration
Feel free to customize the environment further by adding or removing packages in the Dockerfile according to your needs.

### Dockerfile Explanation
Below is an explanation of the key sections in the Dockerfile:

- Base Image: This Dockerfile is based on archlinux/base:latest.

- Locale Configuration: Sets up the system locale and keymap.

- Package Management: Updates package databases, adds the [multilib] and [community] repositories if not present, and installs necessary packages.

- Setting Up BlackArch Repository: Adds BlackArch repository for additional tools.

- Installing Docker: Installs Docker and related tools.

- Cleaning Up: Cleans up package cache to reduce image size.

- Copying Configuration Files: Copies custom Zsh configuration and the work directory.

## Contributing
If you find any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request.

---
Note: This setup is tailored to personal preferences. Feel free to modify it to suit your own needs and preferences.