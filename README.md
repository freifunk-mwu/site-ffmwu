# sites-ffmwu.git

This repository holds the site configurations for the following Freifunk MWU (Mainz, Wiesbaden & Umgebung) communities:

* [Freifunk Mainz](<http://www.freifunk-mainz.de)
* [Freifunk Wiesbaden](<http://wiesbaden.freifunk.net)
* [Freifunk Rheingau](<https://www.freifunk-rheingau.de)

Repository structure
--------------------

We maintain two branches ```experimental and ```testing```.

All new commits go to the ```experimental``` branch and if neccesary cherry-picked to ```testing``` otherwise they are merged with the next major release.

The gluon version used to build the firmware is referenced as a git submodule in ```gluon```.
To ensure that the submodule is initialized correctly, call ```git submodule update --init``` after a checkout.

To update the gluon submodule in the experimental branch to the latest origin/master use ```git submodule update --remote```.

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

To copy the firmware to the firmware repository, you can use the following command:

```
./build.sh -s <community> -b <branch> -r 1 -c deploy
```

Version schema
--------------
For the versioning of our ```stable``` and ```testing``` releases we use the gluon version as the base and append the site name followed by a counter. The counter starts at 1 and will only be increased if we do maintenance releases with the same gluon version as the previous release. For example the first release based on gluon v2016.1.3 for Mainz would be ```2016.1.3+mainz1```.

For ```experimental``` builds this is slightly different. They also start with the Gluon version followed by the site name (as we don't have Git tag we use the latest branch name). But the suffix doesn't include the regular counter instead we add a second suffix that reflects the build date followed by an incrementable counter incase we build several times a day. For example the experimental build for the 21.04.2016 would be ```2016.1+mainz~2016042101```.

Where is the stable branch?
---------------------------
We decided to no longer build individual versions for ```stable``` and ```testing``` (formerly known as beta). Testing builds are promoted to stable builds by moving them to the stable directory. This ensures we don't mess anything up between the testing and stable release.
