# site-ffmwu.git
This repository holds the site configuration for the following Freifunk MWU (Mainz, Wiesbaden & Umgebung) Communities:

* [Freifunk Mainz](http://www.freifunk-mainz.de)
* [Freifunk Wiesbaden](http://wiesbaden.freifunk.net)
* [Freifunk Rheingau-Taunus](https://www.freifunk-rtk.de)
* [Freifunk Bingen](https://www.freifunk-bingen.de)
* [Freifunk Limburg](https://www.freifunk-limburg.de/)

## Repository structure
In addition to the _master_ branch we maintain one branch for each Gluon major release.

All new commits should go to the _master_ branch first and cherry-picked to other branches.

## Version schema
For the versioning of our _stable_ and _testing_ releases we use the Gluon version and append the string `+mwu` followed by a counter. The counter starts at 1 and will be increased if we do maintenance releases with the same gluon version as the previous release. For example the first release based on gluon v2021.1 would be `2021.1+mwu1`.

For _experimental_ builds this is slightly different. They also start with the Gluon version but as we don't have a Git tag we use a predefined prefix higher than the latest Gluon release. The suffix doesn't include the regular counter instead we add a second suffix that reflects the build date followed by an incremental counter in case we build several times a day. For example the first experimental build of 23.07.2021 would be called `2021.2+mwu~exp2021072301`.

## Build the firmware
The firmware can be build using the `contrib/build.sh` script contained in this repository.

To do a full build with the latest Gluon `master` use the following commands:

```
# clone the gluon repository
git clone https://github.com/freifunk-gluon/gluon.git

# change to the new directory
cd gluon

# clone the site repository
git clone https://github.com/freifunk-mwu/sites-ffmwu.git site

# start the build process
./site/contrib/build.sh -b experimental -c update
./site/contrib/build.sh -b experimental -c build
```

## Sign and deploy the firmware
**This is only needed if the firmware is deployed via the autoupdater**

To create and sign the _experimental_ manifest for the new images use the following command:

```
./site/contrib/build.sh -b experimental -c sign
```

To copy the images and packages to the firmware directory, you can use the following command:

```
./site/contrib/build.sh -b experimental -c deploy
```

## Automated builds
To automate builds the `build.sh` script provides the _auto_ command which will call necessary commands in a row.

For example to do a full build _(update, build, sign, deploy)_ use the following commands:

```
./site/contrib/build.sh -b experimental -c auto
```

In addition to the _auto_ command their are two more commands: _autoc_ (includes _clean_) and _autocc_ (includes _dirclean_).
