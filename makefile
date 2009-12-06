MAKEFLAGS = -s

rsync = rsync -rvz

out = output
src = source
tpl = templates
work = /tmp/work

translator = ./translate.scm
tr = $(translator) --template-directory $(tpl) --output-directory $(out)

sources = $(shell find $(src) -name '[^.]*.xml')
results = $(foreach x,$(sources),$(patsubst $(src)/%.xml,$(out)/%.html,$(x)))

templates = $(shell find $(tpl) -name '[^.]*.xml')

extra_sources = $(shell find $(tpl) -name '[^.]*.css' -o -name '[^.]*.png')
extra_results = $(foreach x,$(extra_sources),$(patsubst \
	$(tpl)/%,$(out)/%,$(x)))

#host = oss.readytalk.com:/var/www/avian
host = jdpc.ecovate.com:/usr/local/tomcat/webapps/palomar/avian

.PHONY: all
all: $(results) $(extra_results)

.PHONY: deploy
deploy: $(results) $(extra_results)
	$(rsync) $(out)/ $(host)/

.PHONY: deploy-examples
deploy-examples:
	$(rsync) $(work)/avian-swt-examples/build/windows-i386/example/example.exe $(host)/swt-examples/windows-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/windows-i386/graphics/graphics.exe $(host)/swt-examples/windows-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/windows-i386/paint/paint.exe $(host)/swt-examples/windows-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/windows-x86_64/example/example.exe $(host)/swt-examples/windows-x86_64/ || true
	$(rsync) $(work)/avian-swt-examples/build/windows-x86_64/graphics/graphics.exe $(host)/swt-examples/windows-x86_64/ || true
	$(rsync) $(work)/avian-swt-examples/build/windows-x86_64/paint/paint.exe $(host)/swt-examples/windows-x86_64/ || true
	$(rsync) $(work)/avian-swt-examples/build/linux-i386/example/example $(host)/swt-examples/linux-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/linux-i386/graphics/graphics $(host)/swt-examples/linux-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/linux-i386/paint/paint $(host)/swt-examples/linux-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/linux-x86_64/example/example $(host)/swt-examples/linux-x86_64/ || true
	$(rsync) $(work)/avian-swt-examples/build/linux-x86_64/graphics/graphics $(host)/swt-examples/linux-x86_64/ || true
	$(rsync) $(work)/avian-swt-examples/build/linux-x86_64/paint/paint $(host)/swt-examples/linux-x86_64/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-i386/example/example $(host)/swt-examples/darwin-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-i386/graphics/graphics $(host)/swt-examples/darwin-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-i386/paint/paint $(host)/swt-examples/darwin-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-x86_64/example/example $(host)/swt-examples/darwin-x86_64/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-x86_64/graphics/graphics $(host)/swt-examples/darwin-x86_64/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-x86_64/paint/paint $(host)/swt-examples/darwin-x86_64/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-powerpc/example/example $(host)/swt-examples/darwin-powerpc/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-powerpc/graphics/graphics $(host)/swt-examples/darwin-powerpc/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-powerpc/paint/paint $(host)/swt-examples/darwin-powerpc/ || true

.PHONY: deploy-avian
deploy-avian:
	(cd $(work)/avian && make tarball javadoc)
	$(rsync) $(work)/avian/build/avian-*.tar.bz2 $(host)/
	$(rsync) $(work)/avian/build/javadoc/ $(host)/javadoc/

$(out)/%.html: $(src)/%.xml $(translator) $(templates)
	@echo "generating $(@)"
	@mkdir -p $(dir $(@))
	$(tr) $(<)

$(extra_results): $(out)/%: $(tpl)/%
	@echo "copying $(<) to $(@)"
	@mkdir -p $(dir $(@))
	cp $(<) $(@)

.PHONY: clean
clean:
	@echo "removing $(out)"
	rm -rf $(out)
