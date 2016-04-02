sites-ffmwu.git
===============

This repository holds the site configurations for the following Freifunk MWU communities:

* [Freifunk Mainz](<http://www.freifunk-mainz.de)
* [Freifunk Wiesbaden](<http://wiesbaden.freifunk.net)
* [Freifunk Rheingau](<https://www.freifunk-rheingau.de)

Repository structure
--------------------

The gluon version used to build the firmware is referenced as a git submodule.
To ensure that the submodule is initialized correctly, call ```git submodule update --init``` after a checkout.

Each community has its own site config which is located in a subdirectory of ```sites```.

Build the firmware
------------------

The firmware can be build using the ```./build.sh``` script contained in the repository.
To do a full build use the following commands:

```
./build.sh -s <community> -b <branch> -r 1 -c update
./build.sh -s <community> -b <branch> -r 1 -c build
```

Sign and deploy the firmware
----------------------------
To sign the images, use the following command:

```
./build.sh -s <community> -b <branch> -r 1 -c sign
```

To upload the firmware to the firmware repository, you can use the following command:

```
./build.sh -s <community> -b <branch> -r 1 -c deploy
```

Where is the stable branch?
---------------------------
We decided to no longer build individual versions for ```stable``` and ```testing``` (formerly known as beta). Testing builds ar promoted to stable builds by moving them to the stable directory. This makes shure we don't mess anything up between testing and stable.
