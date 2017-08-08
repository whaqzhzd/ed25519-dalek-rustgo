IMPORT_PATH ?= github.com/FiloSottile/ed25519-dalek-rustgo

edwards25519/edwards25519.a: edwards25519/rustgo.go edwards25519/rustgo.o target/release/libed25519_dalek_rustgo.a
		go tool compile -N -l -o $@ -p main -pack edwards25519/rustgo.go
		go tool pack r $@ edwards25519/rustgo.o
		mkdir -p target/release/libed25519_dalek_rustgo && rm -f target/release/libed25519_dalek_rustgo/*.o
		cd target/release/libed25519_dalek_rustgo && ar x "$(CURDIR)/target/release/libed25519_dalek_rustgo.a"
		go tool pack r $@ target/release/libed25519_dalek_rustgo/*.o

target/release/libed25519_dalek_rustgo.a: src/* Cargo.toml Cargo.lock .cargo/config
		cargo build --release

edwards25519/rustgo.o: edwards25519/rustgo.s
		go tool asm -I "$(shell go env GOROOT)/pkg/include" -o $@ $^

INSTALL_PATH := $(shell go env GOPATH)/pkg/$(shell go env GOOS)_$(shell go env GOARCH)/$(IMPORT_PATH)
.PHONY: install uninstall
install: edwards25519/edwards25519.a
		mkdir -p "$(INSTALL_PATH)"
		cp edwards25519/edwards25519.a "$(INSTALL_PATH)"
uninstall:
		rm -f "$(INSTALL_PATH)/edwards25519.a"

.PHONY: clean
clean:
		rm -rf edwards25519/*.[oa] target ed25519-dalek-rustgo
