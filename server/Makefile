# TODO: Make sure `entr` is on system (http://www.entrproject.org/)
#
SHELL 			= /bin/sh
CC      		= go
GENERATED		= .__gen__
GOA_DESIGN		= design/*
TARGET			= cpss
WATCHER			= entr

.PHONY: build clean deploy generate hooks reset-db serve watch

$(GENERATED): $(GOA_DESIGN)
	@echo [make] Generating Goa code, please be patient...
	@# Don't suppress the error if the following operation fails!
	@$(CC) generate
	@# We only want to modify the generated file when successful.
	@touch $(GENERATED)

$(TARGET): *.go sql/*.go $(GENERATED)
	$(CC) build -o $(TARGET)
	@echo [make] Success!

build: $(TARGET) | $(GENERATED)

clean:
	rm -rf cpss app client swagger tool

deploy:
	@echo [make] Cross-compiling to 64-bit amd architecture...
	@GOARCH=amd64 go build -o $(TARGET)
	echo "Deploying to cpss..."
	@rsync -avze ssh --progress cpss cpss:/var/www/html/cpss/
	@echo [make] Successfully deployed!

generate: $(GENERATED)

hooks:
	@echo [make] Installing git hook...
	@cd ../.git/hooks && \
		echo make generate >> post-merge && \
			chmod 755 post-merge

reset-db:
	@echo [make] Resetting db...
	@cd sql/tables && \
		sh reset_db.sh

serve: $(TARGET)
	./$(TARGET)

watch:
	@echo Watching filesystem for changes...
	@ag -l --depth 0 --go | $(WATCHER) make serve

