# cc-t-ctl
systemd of CC:T world
## Features
 - [x] Downloading from GitHub
 - [x] Downloading from Gists
 - [x] Downloading from other http(s) hosts
 - [x] Startup managing
    - [x] Safe mode for startups
## Install
Run following command in CraftOS shell:
```
wget run https://raw.githubusercontent.com/getkirill/cc-t-ctl/main/installer.lua
```
Or, if you use some kind of emulator (like Craft-OS PC):
```
wget run http://localhost:8080/installer.lua local
```
It expects localhost:8080 to be serving this repository. You can use python to do that:
```
python -m http.server 8080
```