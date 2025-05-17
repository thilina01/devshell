# DevShell Docker Images

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/thilina01/devshell/release.yml?branch=main)](https://github.com/thilina01/devshell/actions)
[![Latest Release](https://img.shields.io/github/v/release/thilina01/devshell)](https://github.com/thilina01/devshell/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/thilina01/devshell)](https://hub.docker.com/r/thilina01/devshell)
[![Docker Image Size (latest)](https://img.shields.io/docker/image-size/thilina01/devshell/latest)](https://hub.docker.com/r/thilina01/devshell)
[![Nano Image Size](https://img.shields.io/docker/image-size/thilina01/devshell/nano?label=Nano%20Image%20Size)](https://hub.docker.com/r/thilina01/devshell)

This repository contains two Docker images for lightweight development environments:

* `thilina01/devshell:latest`: A full-featured development shell with Zsh, Oh My Zsh, Nano, syntax highlighting, and additional tools like `tmux`, `bat`, and `git`.
* `thilina01/devshell:nano`: A lightweight version focused on editing files with Nano, including syntax highlighting.

## Features

### Nano Version (`thilina01/devshell:nano`)

* Lightweight environment with:

  * Nano editor.
  * Syntax highlighting for various file types.
* Ideal for editing files within mounted volumes.

### DevShell Version (`thilina01/devshell:latest`)

* Includes all features of the Nano version plus:

  * Zsh with Oh My Zsh and plugins (`zsh-autosuggestions` and `zsh-syntax-highlighting`).
  * Additional tools like `tmux`, `bat`, `curl`, `wget`, and `git`.
* Suitable for full-featured development and scripting tasks.

## Build Instructions

### Build the Nano Version

```
docker build --target nano -t thilina01/devshell:nano .
```

### Build the Full DevShell Version

```
docker build -t thilina01/devshell .
```

### Verify Images

```
docker image ls thilina01/devshell:latest
docker image ls thilina01/devshell:nano
```

## Push to Docker Hub

Push the images to Docker Hub:

```
docker push thilina01/devshell:latest
docker push thilina01/devshell:nano
```

## Run Instructions

### Run the Nano Version

Run the Nano-specific container:

```
docker run -it --rm thilina01/devshell:nano
```

### Run the Full DevShell Version

Run the full-featured DevShell container:

```
docker run -it --rm thilina01/devshell:latest
```

### Use with a Mounted Volume

#### Nano Version

Edit a specific file within a mounted volume:

```
docker run --rm -it -v demo_config:/data thilina01/devshell:nano sh -c "nano system_config.json"
```

#### DevShell Version

Start a full-featured shell with a mounted volume:

```
docker run --rm -it -v demo_config:/data thilina01/devshell:latest
```

## Example Commands Inside the DevShell Container

### Zsh with Oh My Zsh

* Enjoy features like autosuggestions and syntax highlighting:

```
git status
echo "Hello, DevShell!"
```

### Edit Files with Nano

* Use Nano with syntax highlighting:

```
nano /data/system_config.json
```

### Explore Files with `bat`

* Use `bat` for enhanced file viewing:

```
bat /etc/passwd
```

### Use `tmux` for Session Management

* Start a `tmux` session:

```
tmux
```

### Manage Files with `git`

* Use Git to manage repositories:

```
git clone https://github.com/example/repo.git
```

## Using the Installer Script

### Overview

The installer script simplifies the setup process by installing helper scripts (`ds` and `dsn`), updating the system PATH, and making these commands globally accessible.

### Installation

To install the helper scripts and configure your environment:

```
docker run --rm thilina01/devshell cat /installer > installer && chmod +x installer && ./installer && source ./installer
```

### Uninstallation

To remove the installed scripts and cleanup the PATH:

```
./installer -u
```

### Installer Behavior

* The script automatically installs helper scripts (`ds` and `dsn`) to `$HOME/.local/bin/devshell`.
* Updates the `PATH` variable in the current session and shell configuration files (`.bashrc` and `.zshrc`).
* Prevents duplicate PATH entries during installation.
* During uninstallation, removes all associated files and PATH entries.

## Using the `ds` and `dsn` Scripts

To simplify running these containers, two helper scripts are provided:

### `ds`: Start a DevShell Session

The `ds` script starts a DevShell session. It supports running with or without a volume mounted.

#### Usage:

* Run without a volume:

  ```
  ./ds
  ```

  This will start the container without mounting any volume.

* Run with a volume:

  ```
  ./ds <volume_name>
  ```

  This will mount the specified volume to `/data` in the container.

#### Examples:

* Start a DevShell session without a volume:

  ```
  ./ds
  ```

* Start a DevShell session with the `demo_config` volume:

  ```
  ./ds demo_config
  ```

### `dsn`: Edit a File with Nano

The `dsn` script opens a specific file in Nano inside the container.

#### Usage:

```
./dsn <volume_name> <file_path>
```

#### Example:

```
./dsn demo_config system_config.json
```

This will mount the `demo_config` volume and open `system_config.json` for editing in Nano.

### Add Scripts to PATH Manually

To use `ds` and `dsn` globally, move them to `/usr/local/bin`:

```
sudo mv ds /usr/local/bin/
sudo mv dsn /usr/local/bin/
sudo chmod +x /usr/local/bin/ds /usr/local/bin/dsn
```

Now you can run:

```
ds
ds demo_config
dsn demo_config system_config.json
```

## Enhanced Remote Dev Experience with `remote-dev.sh` and VSCode

A new helper script `remote-dev.sh` supports a full-featured remote dev experience with SSH and optional VPN support. Enhancements include:

* **Auto-starting** containers with SSH and VPN.
* **Encrypted VPN credentials/configs** with a unified passphrase.
* **Automatic SSH readiness detection**.
* **New VSCode integration**:

  * Launches a VSCode window using `code --remote ssh-remote+...`.
  * Supports folder selection UI if VSCode is already running.
  * Works even with running VSCode by spawning a new window with `--new-window`.

#### Usage:

```bash
./remote-dev.sh start        # Starts the container with VPN/SSH setup
./remote-dev.sh vscode       # Launches a new VSCode remote session
./remote-dev.sh stop         # Stops and cleans up the container
```

---

# Demonstrating the devshell usage using the demo stack

Here’s a **comprehensive set of use cases** for the ds script using the `demo-docker-compose.yml` stack:

### **0. starting the stack and services**

#### **0.1. deploy the stack**

```bash
docker stack deploy -c demo-docker-compose.yml demo
```

this will deploy the stack as demo and starts the two web services, `web-service-1`, and `web-service-2`.
the `devshell` will not be started automatically as the replica count is set to `0`

### **1. Debugging and Inspecting Web Services**

#### **1.1. Inspect `web-service-1` Volume**

* Scenario: You need to check or modify files in the `web-service-1` volume.

Commands:

```bash
# Start the devshell service on-demand
./ds -s demo_devshell

# Once inside the devshell container, navigate to the volume
cd /data/web-service-1

# List files in the volume
ls -la

# Modify a file (example: editing an HTML file)
echo "<h1>Hello from DevShell</h1>" > index.html

# Exit the container (triggers idle timeout monitoring)
exit
```

Outcome:

* The `devshell` service is stopped after exit.

---

#### **1.2. Check Network Connectivity Between Services**

* Scenario: Verify that `web-service-1` and `web-service-2` can communicate over the shared network.

Commands:

```bash
# Start the devshell service
./ds -s demo_devshell

# Ping web-service-1 from inside devshell
ping -c 4 web-service-1

# Ping web-service-2 from inside devshell
ping -c 4 web-service-2

# Use curl to check web-service-1 from devshell
curl http://web-service-1

# Use curl to check web-service-2 from devshell
curl http://web-service-2

# Exit the container
exit
```

Outcome:

* Confirms network connectivity between the services.

---

### **2. Maintenance Tasks**

#### **2.1. Perform Updates on Shared Volumes**

* Scenario: Update files for both web services via shared volumes.

Commands:

```bash
# Start the devshell service
./ds -s demo_devshell

# Update files in web-service-1's volume
cd /data/web-service-1
echo "<p>Updated content for web-service-1</p>" > index.html

# Update files in web-service-2's volume
cd /data/web-service-2
echo "<p>Updated content for web-service-2</p>" > index.html

# Use curl to verify the update on HTTP endpoints
curl http://web-service-1
curl http://web-service-2

# Exit the container
exit
```

Outcome:

* Files in the shared volumes are updated, and changes reflect in the web services.

---

## Contributions

Feel free to submit issues or pull requests for improvements and additional features.

## License

This project is licensed under the MIT License.
