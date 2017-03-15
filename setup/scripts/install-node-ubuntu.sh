#!/bin/bash


sudo apt-get install -y build-essential checkinstall libssl-dev

curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash

command -v nvm

# nodejs
# export NVM_DIR="/home/chunj/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

source /home/ubuntu/.bashrc

# https://nodejs.org/en/download/releases/
nvm install 6.10
nvm use 6.10
nvm alias default node