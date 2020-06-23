# PixelInterface

Pixel-perfect fonts and user interface elements.

- <https://godotmarketplace.com/publisher/henry-software/>
- <https://bitbucket.org/rakkarage/pixelinterface/issues>
- <https://github.com/rakkarage/pixelinterface/issues>

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

- make new project @ <https://console.firebase.google.com/>
  - enable email authentication access
  - get api key from project settings
    - put api key in Connect/apikey.txt
  - get project id from project settings
    - put project id in Connect/Firebase.gd
  - create firestore database
    - test mode or rule: `allow read, write: if request.auth.uid != null;`
    - collection name is defined in Connect/Firebase.gd it will create this collection when data is saved

## Nakama Server

- install and setup docker
  - <https://docs.docker.com/engine/install/ubuntu/>
  - <https://docs.docker.com/engine/install/linux-postinstall/>
    - Container management software suggestions
      - <https://www.portainer.io/>
      - <https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker>

- <https://heroiclabs.com/docs/install-docker-quickstart/>
  - Make a folder and a docker-compose.yml as in nakama quickstart or edit the included example.
    - Map a sub folder to persist data as in nakama quickstart and add to .gitignore.
  - Start detached and let it run.
    - `docker-compose up -d`
