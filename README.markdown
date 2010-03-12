Ruby in a Box
=============

Using Ruby in a development team poses several common problems:

1. Developers use OSX, administrators use Linux or BSD.
2. Different machines have different software versions
3. People make undocumented changes to development or production servers

All of these things reduce the ability to launch a fresh deployment of the software for development, staging, or production.

Ruby in a Box is a very simple build system to solve these problems:

1. Depend only on very fundamental packages (gcc, Bash, etc.) which can be relied upon (**no chicken/egg problems**).
2. Build everything else from the source checkout: Ruby, gems, etc.
3. Everything runs from inside the checkout. To un-install, just delete all the files.

Usage
-----

Ruby in a Box is meant to be a Git submodule of other projects. Developers can hook into the build process to add
their own gems, configuration files, etc.
