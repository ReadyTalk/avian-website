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

.PHONY: all
all: $(results) $(extra_results)

.PHONY: deploy
deploy: $(results) $(extra_results)
	$(rsync) $(out)/ oss.readytalk.com:/var/www/avian/

.PHONY: deploy-examples
deploy-examples:
	$(rsync) $(work)/avian-swt-examples/build/windows-i386/example/example.exe oss.readytalk.com:/var/www/avian/swt-examples/windows-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/windows-i386/graphics/graphics.exe oss.readytalk.com:/var/www/avian/swt-examples/windows-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/windows-i386/paint/paint.exe oss.readytalk.com:/var/www/avian/swt-examples/windows-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/linux-i386/example/example oss.readytalk.com:/var/www/avian/swt-examples/linux-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/linux-i386/graphics/graphics oss.readytalk.com:/var/www/avian/swt-examples/linux-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/linux-i386/paint/paint oss.readytalk.com:/var/www/avian/swt-examples/linux-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/linux-x86_64/example/example oss.readytalk.com:/var/www/avian/swt-examples/linux-x86_64/ || true
	$(rsync) $(work)/avian-swt-examples/build/linux-x86_64/graphics/graphics oss.readytalk.com:/var/www/avian/swt-examples/linux-x86_64/ || true
	$(rsync) $(work)/avian-swt-examples/build/linux-x86_64/paint/paint oss.readytalk.com:/var/www/avian/swt-examples/linux-x86_64/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-i386/example/example oss.readytalk.com:/var/www/avian/swt-examples/darwin-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-i386/graphics/graphics oss.readytalk.com:/var/www/avian/swt-examples/darwin-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-i386/paint/paint oss.readytalk.com:/var/www/avian/swt-examples/darwin-i386/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-powerpc/example/example oss.readytalk.com:/var/www/avian/swt-examples/darwin-powerpc/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-powerpc/graphics/graphics oss.readytalk.com:/var/www/avian/swt-examples/darwin-powerpc/ || true
	$(rsync) $(work)/avian-swt-examples/build/darwin-powerpc/paint/paint oss.readytalk.com:/var/www/avian/swt-examples/darwin-powerpc/ || true

.PHONY: deploy-avian
deploy-avian:
	(cd $(work)/avian && make tarball javadoc)
	$(rsync) $(work)/avian/build/avian-*.tar.bz2 oss.readytalk.com:/var/www/avian/
	$(rsync) $(work)/avian/build/javadoc/ oss.readytalk.com:/var/www/avian/javadoc/

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
