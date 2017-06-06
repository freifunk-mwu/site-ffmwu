# sites-ffmwu.git
This repository holds the site configurations for the following Freifunk MWU (Mainz, Wiesbaden & Umgebung) communities:

* [Freifunk Mainz](http://www.freifunk-mainz.de)
* [Freifunk Wiesbaden](http://wiesbaden.freifunk.net)
* [Freifunk Rheingau-Taunus](https://www.freifunk-rtk.de)

## Repository structure
We maintain two branches `experimental` and `stable`.

All new commits go to the _experimental_ branch and if neccesary they are cherry-picked to _stable_.

The gluon version used to build the firmware is referenced as a git submodule in `gluon`.
To ensure that the submodule is initialized correctly, call `git submodule update --init` after a checkout.

To update gluon in the experimental branch to the latest `origin/master` use `git submodule update --remote`.

Each community has its own site configuration which is located in a subdirectory of `sites`.
We also maintain additional site configurations for things like mass deployment.

## Build the firmware
The firmware can be build using the `build.sh` script contained in the repository.
For example to do a full stable build for site _mainz_ use the following commands:

```
# clone repository and checkout at given tag
git clone --recursive --branch 2016.2.5+mwu1 https://github.com/freifunk-mwu/sites-ffmwu.git

# change to newly created directory
cd sites-ffmwu

# initialize submodule
git submodule update --init

# start the build
./build.sh -s mainz -b stable -r mwu1 -c update
./build.sh -s mainz -b stable -r mwu1 -c build
```

## Sign and deploy the firmware
To sign the new images as _testing_, use the following command:

```
./build.sh -s mainz -b testing -r mwu1 -c sign
```

To copy the build to the firmware directory, you can use the following command:

```
./build.sh -s mainz -b testing -r mwu1 -c deploy
```

## Version schema
For the versioning of our _stable_ and _testing_ releases we use the Gluon version as the base and append the string `mwu` followed by a counter. The counter starts at 1 and will only be increased if we do maintenance releases with the same gluon version as the previous release. For example the first release based on gluon v2016.1.3 would be `2016.1.3+mwu1`.

For _experimental_ builds this is slightly different. They also start with the Gluon version (as we don't have Git tag we use the latest branch name) followed by `mwu`. But the suffix doesn't include the regular counter instead we add a second suffix that reflects the build date followed by an incrementable counter incase we build several times a day. For example the experimental build for the 21.04.2016 would be called `2016.1+mwu~exp2016042101`.

## Where is the testing branch?
We decided to no longer build individual versions for _stable_ and _testing_ (formerly known as beta). Testing builds are promoted to stable by moving them to the stable directory and re-generate the manifest. This ensures we don't mess anything up between the testing and stable releases.
