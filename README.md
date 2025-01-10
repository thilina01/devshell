# DevShell Docker Images

This repository contains two Docker images for lightweight development environments:
- `thilina01/devshell:latest`: A full-featured development shell with Zsh, Oh My Zsh, Nano, syntax highlighting, and additional tools like `tmux`, `bat`, and `git`.
- `thilina01/devshell:nano`: A lightweight version focused on editing files with Nano, including syntax highlighting.

## Features

### Nano Version (`thilina01/devshell:nano`)
- Lightweight environment with:
  - Nano editor.
  - Syntax highlighting for various file types.
- Ideal for editing files within mounted volumes.

### DevShell Version (`thilina01/devshell:latest`)
- Includes all features of the Nano version plus:
  - Zsh with Oh My Zsh and plugins (`zsh-autosuggestions` and `zsh-syntax-highlighting`).
  - Additional tools like `tmux`, `bat`, `curl`, `wget`, and `git`.
- Suitable for full-featured development and scripting tasks.

## Build Instructions

To build the images:

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
docker run --rm -it -v openresty_config:/data thilina01/devshell:nano sh -c "nano system_config.json"
```

#### DevShell Version
Start a full-featured shell with a mounted volume:
```
docker run --rm -it -v openresty_config:/data thilina01/devshell:latest
```

## Example Commands Inside the DevShell Container

### Zsh with Oh My Zsh
- Enjoy features like autosuggestions and syntax highlighting:
```
git status
echo "Hello, DevShell!"
```

### Edit Files with Nano
- Use Nano with syntax highlighting:
```
nano /data/system_config.json
```

### Explore Files with `bat`
- Use `bat` for enhanced file viewing:
```
bat /etc/passwd
```

### Use `tmux` for Session Management
- Start a `tmux` session:
```
tmux
```

### Manage Files with `git`
- Use Git to manage repositories:
```
git clone https://github.com/example/repo.git
```
## Using the `ds` and `dsn` Scripts

To simplify running these containers, two helper scripts are provided:

### `ds`: Start a DevShell Session
The `ds` script starts a DevShell session. It supports running with or without a volume mounted.

#### Usage:
- Run without a volume:
  ```
  ./ds
  ```
  This will start the container without mounting any volume.

- Run with a volume:
  ```
  ./ds <volume_name>
  ```
  This will mount the specified volume to `/data` in the container.

#### Examples:
- Start a DevShell session without a volume:
  ```
  ./ds
  ```

- Start a DevShell session with the `openresty_config` volume:
  ```
  ./ds openresty_config
  ```

### `dsn`: Edit a File with Nano
The `dsn` script opens a specific file in Nano inside the container.

#### Usage:
```
./dsn <volume_name> <file_path>
```

#### Example:
```
./dsn openresty_config system_config.json
```
This will mount the `openresty_config` volume and open `system_config.json` for editing in Nano.

### Add Scripts to PATH
To use `ds` and `dsn` globally, move them to `/usr/local/bin`:
```
sudo mv ds /usr/local/bin/
sudo mv dsn /usr/local/bin/
sudo chmod +x /usr/local/bin/ds /usr/local/bin/dsn
```

Now you can run:
```
ds
ds openresty_config
dsn openresty_config system_config.json
```

## Contributions

Feel free to submit issues or pull requests for improvements and additional features.

## License

This project is licensed under the MIT License.
