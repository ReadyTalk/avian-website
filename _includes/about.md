## About Avian

Avian is a lightweight virtual machine and class lbrary designed to provide a
useful subset of Java's features, suitable for building self-contained
applications.

### Efficient

The VM is implemented from scratch and designed to be both fast and small.

* Just-In-Time (JIT) compilation for fast method execution
* Generational, copying garbage collection ensures short pause times and good spatial locality
* Thread-local heaps provide O(1) memory allocation with no synchronization overhead
* Null pointer dereferences are handled via OS signals to avoid unecessary branches

The class library is designed to be as loosely coupled as possible, allowing tools like ProGuard to aggressively isolate the minimum code needed for an application. This translates to smaller downloads and faster startup.

### Portable

Platform-specific code is hidden behind a generic interface, so adding support
for new OSes is easy. Avian currently supports:

* Linux (i386, x86_64, and ARM),
* Windows (i386 and x86_64),
* OS X (i386 and x86_64),
* iOS (i386 and ARM), and
* FreeBSD (i386 and x86_64).

The only third party dependency beyond OS-provided libraries is zlib, which is
itself very portable. Although the VM is written in C++, it does not depend on
the C++ standard library, and is therefore robust in the face of ABI changes.

### Embeddable

Not only can applications embed the VM, but the VM itself supports class and
resource loading from embedded jar files. This means you can produce a single
executable containing your entire application, thus simplifying the installation
process.
