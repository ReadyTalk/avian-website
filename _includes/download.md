## Download

### Current Release

The latest release is version 1.2.0. As of this release, everything should work
as advertised on the supported platforms. Please post to the
[discussion group](http://groups.google.com/group/avian) if you have any problems.

[Download Avian 1.2.0](../avian-web/avian-1.2.0.tar.bz2)
({% filesize ../readytalk.github.io/avian-web/avian-1.2.0.tar.bz2 %})

Recent changes:

* Add support for ARM64 on Linux and iOS
* Lots of bugfixes throughout the code
* Improve compatibility with OpenJDK 8 class library
* Improve compatibility with Android class library
* Improve Gradle build support

### Avian-Pack Project (Avian plus Android class library)

This is a project for building Avian with the Android class library, providing more complete support for functionality such as regular expressions, SSL, localization, etc..  It does not include any Android platform support such as UI and system components.

All the components are patched to work on Windows and OS X (while the vanilla Android classpath is Linux-only) and tested (a bit).  There are some minor known issues that hopefully will be fixed in the next releases.

[Avian-pack project page on GitHub](https://github.com/bigfatbrowncat/avian-pack)

Major features:

* All-in-one. Many simple Java projects and libraries should already work with this package (if they don't, you are welcome to [submit an issue](https://github.com/bigfatbrowncat/avian-pack/issues).)
* The Android class library is has neither a proprietary, nor a copyleft-style license, thus may be freely used and embedded in both proprietary and open-source projects, and may also be modified freely (the authors would be happy for any pull requests submitted).  Most non-Avian additional components are released under Apache license (the same as Android itself); others are mostly BSD.
* The library has been pached to support Microsoft Windows, which was a major challenge, especially sockets and other I/O.

[Avian-pack v0.1 (pre-release) with Avian 1.2.0 provided](https://github.com/bigfatbrowncat/avian-pack/releases/tag/v0.1-1.2.0)

Avian-pack is an independent project maintained by its creators: [@bigfatbrowncat](https://github.com/bigfatbrowncat) and [@JustAMan](https://github.com/JustAMan).  Please report issues and questions to that project.
