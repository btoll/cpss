# TODO: Make sure `entr` is on system (http://www.entrproject.org/)
#
SHELL 		= /bin/sh
CC      	= go
GENERATED	= .__gen__
GOADESIGN	= design/api.go design/foo.go
TARGET		= cpss
WATCHER		= entr

.PHONY: build clean generate hooks serve watch

$(GENERATED): $(GOADESIGN)
	@echo [make] Generating Goa code, please be patient...
	# Don't suppress the error if the following operation fails!
	@$(CC) generate
	# We only want to modify the generated file when successful.
	@touch $(GENERATED)

$(TARGET): *.go
	-$(CC) build -o $(TARGET)

build: $(TARGET)

clean:
	rm -rf cpss app client swagger tool

generate: $(GENERATED)

hooks:
	@echo [make] Installing git hook...
	@cd ../.git/hooks && \
	echo make generate >> post-merge && \
		chmod 755 post-merge

serve: $(TARGET)
	./$(TARGET)

watch:
	@echo Watching filesystem for changes...
	@ag -l --depth 0 --go | $(WATCHER) -s 'make serve'

