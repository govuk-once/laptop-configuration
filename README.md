# GOV.UK Once Laptop Configuration

Instructions on how to configure your GDS supplied developer laptop for use in GOV.UK Once.

The tools and scripts are generic and designed to aid users in their initial setup, it is advised that users review the software and scripts to ensure they understand what is being installed.

Contributions are welcome.


## Install base tools
Install Homebrew: [https://brew.sh/](https://brew.sh/)

## Setup your laptop
Install base tools
```bash
brew bundle --file=./brewfile
```

## Run configuration scripts

The `setup.sh` script will configure git and the gds-cli with commonly used settings, it is recommended you review the setup.sh script and understand the changes before running.
```bash
./setup.sh
```

## Install NPM

## Install NX
