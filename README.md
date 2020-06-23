# PixelInterface

Pixel-perfect fonts and user interface elements.

- <https://godotmarketplace.com/publisher/henry-software/>
- <https://bitbucket.org/rakkarage/pixelinterface/issues>
- <https://github.com/rakkarage/pixelinterface/issues>

![Screenshot](https://imgur.com/V6YELkN.png)

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

- <https://heroiclabs.com/docs/install-docker-quickstart/>
  - install and setup docker
    - <https://docs.docker.com/engine/install/ubuntu/>
    - <https://docs.docker.com/engine/install/linux-postinstall/>
  - make a folder and a docker-compose.yml as in nakama quick start or edit the **included example**
    - map a folder to persist data as in nakama quick start
  - start detached and let it run
    - `./up.sh` or `docker-compose up -d`
