.PHONY: build twist

build-image: govuln
	docker build -t pxt1/govuln:latest .
	touch $@

build govuln:
	go build .

twist:
	twist pxt1/govuln:latest
