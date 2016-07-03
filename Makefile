PROJECT := fleet-ui
SCRIPTDIR := $(shell pwd)
ROOTDIR := $(shell cd $(SCRIPTDIR) && pwd)
VERSION:= $(shell cat $(ROOTDIR)/VERSION)
COMMIT := $(shell git rev-parse --short HEAD)

GOBUILDDIR := $(SCRIPTDIR)/.gobuild
SRCDIR := $(SCRIPTDIR)
BINDIR := $(ROOTDIR)
VENDORDIR := $(SCRIPTDIR)/deps

ORGPATH := github.com/pulcy
ORGDIR := $(GOBUILDDIR)/src/$(ORGPATH)
REPONAME := $(PROJECT)
REPODIR := $(ORGDIR)/$(REPONAME)
REPOPATH := $(ORGPATH)/$(REPONAME)
BIN := $(BINDIR)/$(PROJECT)

GOPATH := $(GOBUILDDIR)
GOVERSION := 1.6.2-alpine

ifndef GOOS
	GOOS := linux
endif
ifndef GOARCH
	GOARCH := amd64
endif

SOURCES := $(shell find $(SRCDIR) -name '*.go')

.PHONY: all clean deps docker

all: angular/dist $(BIN)

clean:
	rm -Rf $(BIN) $(GOBUILDDIR) angular/dist angular/npm-debug.log

veryclean: clean
		rm -Rf angular/node_modules angular/bower_components angular/.tmp angular/.sass-cache

deps:
	@${MAKE} -B -s $(GOBUILDDIR)

$(GOBUILDDIR):
	@mkdir -p $(ORGDIR)
	@rm -f $(REPODIR) && ln -s ../../../.. $(REPODIR)
	@GOPATH=$(GOPATH) pulsar go flatten -V $(VENDORDIR)

$(BIN): $(GOBUILDDIR) $(SOURCES)
	docker run \
		--rm \
		-v $(ROOTDIR):/usr/code \
		-e GOPATH=/usr/code/.gobuild \
		-e GOOS=$(GOOS) \
		-e GOARCH=$(GOARCH) \
		-e CGO_ENABLED=0 \
		-w /usr/code/ \
		golang:$(GOVERSION) \
		go build -a -installsuffix netgo -tags netgo -ldflags "-X main.projectVersion=$(VERSION) -X main.projectBuild=$(COMMIT)" -o /usr/code/$(PROJECT) $(REPOPATH)

angular/dist:
	docker build angular -t fleet-ui-angular-build -f angular/Dockerfile.build
	docker run \
		--rm \
		-v $(ROOTDIR)/angular:/usr/code \
		-w /usr/code/ \
		fleet-ui-angular-build \
		/usr/code/build.sh
