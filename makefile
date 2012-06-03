MAKEFLAGS = -s

rsync = rsync -rvz

build = build
out = $(build)/output
src = source
tpl = templates
work = ../

translator = ./translate.scm
tr = $(translator) --template-directory $(tpl) --output-directory $(out)

sources := $(shell find $(src) -name '[^.]*.xml')
results = $(foreach x,$(sources),$(patsubst $(src)/%.xml,$(out)/%.html,$(x)))

templates := $(shell find $(tpl) -name '[^.]*.xml')

extra_sources := $(shell find $(tpl) -name '[^.]*.css' -o -name '[^.]*.png')
extra_results = $(foreach x,$(extra_sources),$(patsubst \
	$(tpl)/%,$(out)/%,$(x)))

version = 0.6

host = oss.readytalk.com:/var/www/avian-$(version)
web-host = http://oss.readytalk.com/avian-$(version)

proguard-version = 4.6beta1
swt-version = 3.7
lzma-version = 920

programs = example graphics paint

swt-zip-map = \
	linux-x86_64:swt-$(swt-version)-gtk-linux-x86_64.zip \
	linux-i386:swt-$(swt-version)-gtk-linux-x86.zip \
	linux-arm:swt-$(swt-version)-gtk-linux-arm.zip \
	linux-powerpc:swt-$(swt-version)-gtk-linux-powerpc.zip \
	darwin-x86_64-cocoa:swt-$(swt-version)-cocoa-macosx-x86_64.zip \
	darwin-i386-carbon:swt-$(swt-version)-carbon-macosx.zip \
	darwin-powerpc-carbon:swt-$(swt-version)-carbon-macosx.zip \
	windows-x86_64:swt-$(swt-version)-win32-win32-x86_64.zip \
	windows-i386:swt-$(swt-version)-win32-win32-x86.zip

platforms = $(sort $(foreach x,$(swt-zip-map),$(word 1,$(subst :, ,$(x)))))

linux-build-host = localhost
darwin-build-host = macmini2-build2.e

examples = $(foreach x,$(platforms),$(build)/$(x)-example.d)
get-platform = $(word 1,$(subst -, ,$(1)))
get-arch = $(word 2,$(subst -, ,$(1)))
get-subplatform = $(word 3,$(subst -, ,$(1)))
full-platform = $(patsubst $(build)/%-example.d,%,$(1))
arch = $(call get-arch,$(call full-platform,$(1)))
platform = $(call get-platform,$(call full-platform,$(1)))
subplatform = $(call get-subplatform,$(call full-platform,$(1)))
extension = $(if $(filter windows,$(call platform,$(1))),.exe)
build-host = $(if $(filter darwin,$(call platform,$(1))),$(darwin-build-host),$(linux-build-host))
map-value = $(patsubst $(1):%,%,$(filter $(1):%,$(2)))
swt-zip = $(call map-value,$(call full-platform,$(1)),$(swt-zip-map))
windows-git-clone = $(if $(filter x86_64,$(call arch,$(1))),git clone git://oss.readytalk.com/win64.git || (cd win64 && git pull);,git clone git://oss.readytalk.com/win32.git || (cd win32 && git pull);)
git-clone = $(if $(filter windows,$(call platform,$(1))),$(call windows-git-clone,$(1)))

.PHONY: all
all: $(results) $(extra_results)

.PHONY: deploy
deploy: deploy-pages

.PHONY: deploy-pages
deploy-pages: $(results) $(extra_results)
	$(rsync) $(out)/ $(host)/

.PHONY: build-examples
build-examples: $(examples)

.PHONY: deploy-examples
deploy-examples: build-examples
	$(rsync) $(build)/swt-examples/ $(host)/swt-examples/

.PHONY: deploy-avian
deploy-avian:
	(cd $(work)/avian && make version=$(version) tarball javadoc)
	$(rsync) $(work)/avian/build/avian-$(version).tar.bz2 $(host)/
	$(rsync) $(work)/avian/build/javadoc/ $(host)/javadoc/
	(cd $(work)/avian-swt-examples && make version=$(version) tarball)
	$(rsync) $(work)/avian/build/avian-swt-examples-$(version).tar.bz2 $(host)/

build-sequence = \
	set -e; \
	rm -rf /tmp/$${USER}-avian-$(call full-platform,$(1)); \
	mkdir -p /tmp/$${USER}-avian-$(call full-platform,$(1)); \
	cd /tmp/$${USER}-avian-$(call full-platform,$(1)); \
	curl -Of $(web-host)/$(call swt-zip,$(1)); \
	mkdir -p swt/$(call full-platform,$(1)); \
	unzip -o -d swt/$(call full-platform,$(1)) $(call swt-zip,$(1)); \
	curl -Of $(web-host)/proguard$(proguard-version).tar.gz; \
	tar xzf proguard$(proguard-version).tar.gz; \
	curl -Of $(web-host)/lzma$(lzma-version).tar.bz2; \
	(mkdir -p lzma-$(lzma-version) \
		&& cd lzma-$(lzma-version) \
		&& tar xjf ../lzma$(lzma-version).tar.bz2); \
	curl -Of $(web-host)/avian-$(version).tar.bz2; \
	tar xjf avian-$(version).tar.bz2; \
	curl -Of $(web-host)/avian-swt-examples-$(version).tar.bz2; \
	tar xjf avian-swt-examples-$(version).tar.bz2; \
	$(call git-clone,$(1)) \
	cd avian-swt-examples; \
	make lzma=$$(pwd)/../lzma-$(lzma-version) \
		full-platform=$(call full-platform,$(1));

$(examples):
	@mkdir -p $(build)/swt-examples
	@echo "making examples for $(call full-platform,$(@))"
	ssh $(call build-host,$(@)) '$(call build-sequence,$(@))'
	set -e; for x in $(programs); do \
		$(rsync) $(call build-host,$(@)):/tmp/$${USER}-avian-$(call full-platform,$(@))/avian-swt-examples/build/$(call full-platform,$(@))-lzma/$${x}/$${x}$(call extension,$(@)) $(build)/swt-examples/$(call full-platform,$(@))/; \
		cp $(build)/swt-examples/$(call full-platform,$(@))/$${x}$(call extension,$(@)) $(build)/swt-examples/$(call full-platform,$(@))/$${x}-uncompressed$(call extension,$(@)); \
	done
	@mkdir -p $(dir $(@))
	@touch $(@)

$(out)/readme.txt: $(work)/avian/readme.txt
	@echo "generating $(@)"
	@mkdir -p $(dir $(@))
	sed -e 's/&/\&amp;/g' -e 's/>/\&gt;/g' -e 's/</\&lt;/g' < $(<) > $(@)

$(out)/%.html: $(src)/%.xml $(translator) $(templates) $(out)/readme.txt
	@echo "generating $(@)"
	@mkdir -p $(dir $(@))
	$(tr) $(<)

$(extra_results): $(out)/%: $(tpl)/%
	@echo "copying $(<) to $(@)"
	@mkdir -p $(dir $(@))
	cp $(<) $(@)

.PHONY: clean
clean:
	@echo "removing $(build)"
	rm -rf $(build)
