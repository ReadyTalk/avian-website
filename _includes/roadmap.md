## Roadmap

### Ideas for the future

* Add java.lang.invoke support
* Experiment with trace-based JIT compilation
* Improve ahead-of-time compilation using LLVM
* Add support for escape analysis to determine where objects may be safely
allocated on the stack instead of the heap
* Rework memory allocation in garbage collector to improve performance in
low memory situations (see [here](http://groups.google.com/group/avian/browse_thread/thread/5b3f13bf198334b3) for details)
* Support additional architectures such as 64-bit ARM
