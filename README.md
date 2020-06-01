# PixelInterface

Pixel-perfect fonts and user interface elements.

- <https://godotmarketplace.com/publisher/henry-software/>
- <https://bitbucket.org/rakkarage/pixelinterface/issues>

## What this is

![Screenshot](https://imgur.com/V6YELkN.png)

- Example Godot theme to test & demo project.
- Example ui to test & demo theme.
- Example connection and storage to firebase or nakama to test and demo ui.

## Submodules

To include submodules, clone with the --recursive flag:

`git clone --recursive https://bitbucket.org/rakkarage/PixelInterface.git`

or download a zip from bitbucket (bitbucket-pipelines.yml) which includes all submodules.

<https://bitbucket.org/rakkarage/pixelinterface/downloads/>

## Firebase & Firestore

- Add api key in file @ res://PixelInterface/Connect/apikey.txt that is ignored by git.
- Replace 'godotconnect' Firestore project id in Firebase.gd.
- set Firestore project database rules to something like
  - `allow read, write: if request.auth.uid != null;`

## Nakama Server

- install and setup docker
  - <https://docs.docker.com/engine/install/ubuntu/>
  - <https://docs.docker.com/engine/install/linux-postinstall/>
    - Container management software suggestions
      - <https://www.portainer.io/>
      - <https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker>

- <https://heroiclabs.com/docs/install-docker-quickstart/>
  - make a folder and a docker-compose.yml as in nakama quickstart
  - map folder to persist data as in nakama quickstart and add to .gitignore
  - start detached and let it run
    - `docker-compose up -d`
