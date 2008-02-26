MAKEFLAGS = -s

rsync = rsync -avz --rsync-path="sudo rsync" 

out = output
src = source
tpl = templates

translator = ./translate.scm
tr = $(translator) --template-directory $(tpl) --output-directory $(out)

sources = $(shell find $(src) -name '[^.]*.xml')
results = $(foreach x,$(sources),$(patsubst $(src)/%.xml,$(out)/%.html,$(x)))

templates = $(shell find $(tpl) -name '[^.]*.xml')

extra_sources = $(shell find $(tpl) -name '[^.]*.css' -o -name '[^.]*.png')
extra_results = $(foreach x,$(extra_sources),$(patsubst \
	$(tpl)/%,$(out)/%,$(x)))

all: $(results) $(extra_results)

deploy: $(results) $(extra_results)
	$(rsync) $(out)/ oss.readytalk.com:/var/www/avian/
	$(rsync) ../avian/build/javadoc/ oss.readytalk.com:/var/www/avian/javadoc/

$(out)/%.html: $(src)/%.xml $(translator) $(templates)
	@echo "generating $(@)"
	@mkdir -p $(dir $(@))
	$(tr) $(<)

$(extra_results): $(out)/%: $(tpl)/%
	@echo "copying $(<) to $(@)"
	@mkdir -p $(dir $(@))
	cp $(<) $(@)

clean:
	@echo "removing $(out)"
	rm -rf $(out)
