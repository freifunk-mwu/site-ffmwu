# sites-ffmwu.git
This repository holds the site configurations for the following Freifunk MWU (Mainz, Wiesbaden & Umgebung) communities:

* [Freifunk Mainz](http://www.freifunk-mainz.de)
* [Freifunk Wiesbaden](http://wiesbaden.freifunk.net)
* [Freifunk Rheingau-Taunus](https://www.freifunk-rtk.de)

## Repository structure
In addition to the _master_ branch we maintain one branch for each major release.

All new commits should go to the _master_ branch first and cherry-picked to other branches.

The gluon version used to build the firmware is referenced as a git submodule in `gluon`.
To ensure that the submodule is initialized correctly, call `git submodule update --init` after a checkout.

To update gluon to the latest `origin/master` use `git submodule update --remote`.

Each community has its own site configuration which is located in a subdirectory of `sites`.
We also maintain additional site configurations for things like mass deployment.

## Version schema
For the versioning of our _stable_ and _testing_ releases we use the Gluon version and append the string `mwu` followed by a counter. The counter starts at 1 and will be increased if we do maintenance releases with the same gluon version as the current release. For example the first release based on gluon v2017.1.4 would be `2017.1.4+mwu1`.

For _experimental_ builds this is slightly different. They also start with the Gluon version (as we don't have a Git tag we use a predefined prefix) followed by `mwu`. But the suffix doesn't include the regular counter instead we add a second suffix that reflects the build date followed by an incremental counter in case we build several times a day. For example the first experimental build of 17.11.2017 would be called `2017.2+mwu~exp2017111701`.

## Build the firmware
The firmware can be build using the `build.sh` script contained in the repository.

To do a full build for the site _mainz_ with the lastest `master` use the following commands:

```
# clone repository and checkout at given tag
git clone --recursive https://github.com/freifunk-mwu/sites-ffmwu.git

# change to newly created directory
cd sites-ffmwu

# initialize submodule and update to latest upstream
git submodule update --init --remote

# start the build
DATE=$(date +%Y%m%d)

./build.sh -s mainz -r 2017.2+mwu~exp${DATE}01 -c update
./build.sh -s mainz -r 2017.2+mwu~exp${DATE}01 -c clean
./build.sh -s mainz -r 2017.2+mwu~exp${DATE}01 -c build
```

## Sign and deploy the firmware
**This is only needed if the firmware is deloyed via autoupdater**

To create and sign the _testing_ manifest for the new images use the following command:

```
./build.sh -s mainz -c sign -r 2017.2+mwu~exp${DATE}01 -b experimental
```

To copy the images and packages to the firmware directory, you can use the following command:

```
./build.sh -s mainz -c deploy -r 2017.2+mwu~exp${DATE}01 -b experimental
```

## Automated builds
`autobuild.sh` acts as a wrapper-script for `build.sh` and also generates a proper version release name based on the git tag that was checked out in the `gluon` submodule. When building as _experimental_ it will automatically checkout the lastest `master` branch for `gluon` if  started with `-u`.

For example to do a full build _(update, clean ,build ,sign ,deploy)_ for sites _mainz_ and _wiesbaden_ use the following commands:

```
./autobuild.sh -s 'mainz wiesbaden' -b experimental -u -- -a
```
