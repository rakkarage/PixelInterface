# PixelInterface

Pixel-perfect fonts and user interface elements.

- <https://godotmarketplace.com/publisher/henry-software/>
- <https://bitbucket.org/rakkarage/pixelinterface/issues>

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

