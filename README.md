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
For example to do a full build for site _mainz_ as `2016.2.2+mwu1` use the following commands:

```
(cd gluon && git checkout v2016.2.2)
./build.sh -s mainz -c update
./build.sh -s mainz -c clean
./build.sh -s mainz -c build -r 2016.2.2+mwu1
```

## Sign and deploy the firmware
To sign the new images as _testing_, use the following command:

```
./build.sh -s mainz -c sign -r 2016.2.2+mwu1 -b testing
```

To copy the build to the firmware directory, you can use the following command:

```
./build.sh -s mainz -c deploy -r 2016.2.2+mwu1 -b testing
```

## Autobuild
`autobuild.sh` acts as a wrapper-script for `build.sh` and also generates a proper version release name based on the git tag that was checked out in the `gluon` submodule. When build as _experimental_ it will automatically checkout the lastest `master` branch for `gluon`.

For example to do a full build for sites _mainz_ and _wiesbaden_ use the following commands:

```
./autobuild.sh -s 'mainz wiesbaden' -b testing
```

`autobuild.sh` can pass extra options to `build.sh`. To do so you need to separate them by `--`.
For example if you want to do an _experimantal_ build that includes broken targets (`-a`).

```
./autobuild.sh -s 'mainz wiesbaden' -b experimental -- -a
```

## Version schema
For the versioning of our _stable_ and _testing_ releases we use the Gluon version as the base and append the string `mwu` followed by a counter. The counter starts at 1 and will only be increased if we do maintenance releases with the same gluon version as the previous release. For example the first release based on gluon v2016.2.2 would be `2016.2.2+mwu1`.

For _experimental_ builds this is slightly different. They also start with the Gluon version (as we don't have Git tag we use the latest branch name) followed by `mwu`. But the suffix doesn't include the regular counter instead we add a second suffix that reflects the build date followed by an incrementable counter incase we build several times a day. For example the experimental build for the 23.12.2016 would be called `2016.2+mwu~exp2016122301`.

## Where is the testing branch?
We decided to no longer build individual versions for _stable_ and _testing_ (formerly known as _beta_). Testing builds are promoted to stable by moving them to the stable directory and re-generate the manifest. This ensures we don't mess anything up between the testing and stable releases.
