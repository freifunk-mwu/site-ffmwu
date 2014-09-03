#site-ffmz.git

Gluon site.conf Repository for [Freifunk Mainz]("http://mainz.freifunk.net/") & [Freifunk Wiesbaden]("http://wiesbaden.freifunk.net/").

``site.conf``, ``site.mk`` & ``modules`` are edited for Mainz.

Calling ``python3 mkwi.py write`` replaces the files with the according values for Wiesbaden (use ``mkwi.py`` without any arguments for a preview).

##Building Gluon

FFctl solves the task to compile almost identical Gluon-Images for multiple Communities in a row.
Afterwards it can handle those Image batches in parallel for signing and releasing them for ``gluon-autoupdater``.

See the [documentation](https://ffctl.readthedocs.org/en/latest/gluonbuilder.html) or the [source code](https://github.com/freifunk-mwu/ffctl) of FFctl's `gluon_builder.sh` for furhther information on how we usually generate our (nightly) images.
