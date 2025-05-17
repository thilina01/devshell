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
  * Optional VSCode Remote-SSH integration for editing inside the container.

## Build Instructions

To build the images:

### Build the Nano Version

```bash
docker build --target nano -t thilina01/devshell:nano .
```

### Build the Full DevShell Version

```bash
docker build -t thilina01/devshell .
```

### Verify Images

```bash
docker image ls thilina01/devshell:latest
docker image ls thilina01/devshell:nano
```

## Push to Docker Hub

Push the images to Docker Hub:

```bash
docker push thilina01/devshell:latest
docker push thilina01/devshell:nano
```

## Run Instructions

### Run the Nano Version

Run the Nano-specific container:

```bash
docker run -it --rm thilina01/devshell:nano
```

### Run the Full DevShell Version

Run the full-featured DevShell container:

```bash
docker run -it --rm thilina01/devshell:latest
```

### Use with a Mounted Volume

#### Nano Version

Edit a specific file within a mounted volume:

```bash
docker run --rm -it -v demo_config:/data thilina01/devshell:nano sh -c "nano system_config.json"
```

#### DevShell Version

Start a full-featured shell with a mounted volume:

```bash
docker run --rm -it -v demo_config:/data thilina01/devshell:latest
```

## Example Commands Inside the DevShell Container

### Zsh with Oh My Zsh

* Enjoy features like autosuggestions and syntax highlighting:

```bash
git status
echo "Hello, DevShell!"
```

### Edit Files with Nano

* Use Nano with syntax highlighting:

```bash
nano /data/system_config.json
```

### Explore Files with `bat`

* Use `bat` for enhanced file viewing:

```bash
bat /etc/passwd
```

### Use `tmux` for Session Management

* Start a `tmux` session:

```bash
tmux
```

### Manage Files with `git`

* Use Git to manage repositories:

```bash
git clone https://github.com/example/repo.git
```

## Using the Installer Script

### Overview

The installer script simplifies the setup process by installing helper scripts (`ds` and `dsn`), updating the system PATH, and making these commands globally accessible.

### Installation

To install the helper scripts and configure your environment:

```bash
docker run --rm thilina01/devshell cat /installer > installer && chmod +x installer && ./installer && source ./installer
```

### Uninstallation

To remove the installed scripts and cleanup the PATH:

```bash
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

  ```bash
  ./ds
  ```

  This will start the container without mounting any volume.

* Run with a volume:

  ```bash
  ./ds <volume_name>
  ```

  This will mount the specified volume to `/data` in the container.

#### Examples:

* Start a DevShell session without a volume:

  ```bash
  ./ds
  ```

* Start a DevShell session with the `demo_config` volume:

  ```bash
  ./ds demo_config
  ```

### `dsn`: Edit a File with Nano

The `dsn` script opens a specific file in Nano inside the container.

#### Usage:

```bash
./dsn <volume_name> <file_path>
```

#### Example:

```bash
./dsn demo_config system_config.json
```

This will mount the `demo_config` volume and open `system_config.json` for editing in Nano.

### Add Scripts to PATH Manually

To use `ds` and `dsn` globally, move them to `/usr/local/bin`:

```bash
sudo mv ds /usr/local/bin/
sudo mv dsn /usr/local/bin/
sudo chmod +x /usr/local/bin/ds /usr/local/bin/dsn
```

Now you can run:

```bash
ds
ds demo_config
dsn demo_config system_config.json
```

## Using the `vscode` Command (Remote Editing via VSCode)

The enhanced script provides a `vscode` command that allows you to open a **Remote-SSH session into the running DevShell container using VSCode**, with an improved user experience:

* If no VSCode window is running, it will launch a new window and allow you to choose a folder.
* If VSCode is already open, it will still open a **new window** via Remote SSH (does not reuse an existing window).
* No manual folder prompts — VSCode’s built-in folder selector appears automatically.

### Prerequisites

* VSCode must be installed on the host machine.
* Remote-SSH extension must be installed in VSCode.
* `code` command must be available in your shell (e.g., `which code`).

### Example

```bash
./remote-dev.sh vscode
```

This opens a new VSCode window and lets you choose a folder inside the DevShell container running on a forwarded SSH port.

> 💡 The `vscode` integration is designed to work seamlessly with both newly launched containers and already running containers.

# Demonstrating the devshell usage using the demo stack

\[Remaining sections unchanged from original]
