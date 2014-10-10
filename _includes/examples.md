## Examples

Avian is well suited to building small, self-contained applications. To
demonstrate this, we've taken a demo application from the Eclipse SCM repository
and built it using Avian, [ProGuard](http://proguard.sourceforge.net/), and
[LZMA](http://www.7-zip.org/sdk.html).

|Platform|Example|
|--------|-------|
|Linux/x86_64|[download](../avian-web/swt-examples/linux-x86_64/example)|
|Linux/i386|[download](../avian-web/swt-examples/linux-i386/example)|
|Linux/ARM|[download](../avian-web/swt-examples/linux-arm/example)|
|OS X/x86_64|[download](../avian-web/swt-examples/macosx-x86_64/example)|
|OS X/i386|[download](../avian-web/swt-examples/macosx-i386/example)|
|Windows/x86_64|[download](../avian-web/swt-examples/windows-x86_64/example.exe)|
|Windows/i386|[download](../avian-web/swt-examples/windows-i386/example.exe)|

### Building

If you'd like to build this example yourself, try the following:

{% highlight bash %}
# Set the platform and swt_zip environment variables according to the
# following table:
#
# platform               swt_zip
# --------               -------
# linux-x86_64           swt-4.3-gtk-linux-x86_64.zip
# linux-i386             swt-4.3-gtk-linux-x86.zip
# linux-arm              swt-4.3-gtk-linux-arm.zip
# macosx-x86_64          swt-4.3-cocoa-macosx-x86_64.zip
# macosx-i386            swt-4.3-cocoa-macosx.zip
# windows-x86_64         swt-4.3-win32-win32-x86_64.zip
# windows-i386           swt-4.3-win32-win32-x86.zip

mkdir work
cd work
curl -Of http://oss.readytalk.com/avian-web/proguard4.11.tar.gz
tar xzf proguard4.11.tar.gz
curl -Of http://oss.readytalk.com/avian-web/lzma920.tar.bz2
(mkdir -p lzma-920 && cd lzma-920 && tar xjf ../lzma920.tar.bz2)
curl -Of http://oss.readytalk.com/avian-web/${swt_zip}
mkdir -p swt/${platform}
unzip -d swt/${platform} ${swt_zip}
curl -Of http://oss.readytalk.com/avian-web/avian-1.1.0.tar.bz2
tar xjf avian-1.1.0.tar.bz2
curl -Of http://oss.readytalk.com/avian-web/avian-swt-examples-1.1.0.tar.bz2
tar xjf avian-swt-examples-1.1.0.tar.bz2
# needed only for 32-bit Windows builds:
git clone https://github.com/ReadyTalk/win32.git
# needed only for 64-bit Windows builds:
git clone https://github.com/ReadyTalk/win64.git
cd avian-swt-examples
make lzma=$(pwd)/../lzma-920 full-platform=${platform} example
{% endhighlight %}
