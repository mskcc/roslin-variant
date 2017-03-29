# Prerequisites

## Node.js

This step is necessary until sysadmin installs Node.js across all cluster nodes.

Log in to `selene.mskcc.org` and run the following command:

```bash
$ curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
```

Add the following lines to your profile (`~/.profile` or `~/.bash_profile`)

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
```

Log out and log back in. At this point, executing `command -v nvm` should return `nvm`.

Run the following:

```bash
$ nvm install 6.10
$ nvm use 6.10
$ nvm alias default node
```

Execute `node --version`, and you are all set if you see `v6.10.0`.
