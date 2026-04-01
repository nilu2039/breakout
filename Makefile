.PHONY: all run web-build web-run

all:
	zig build --release=safe

run:
	zig build run

web-build:
	zig build -Dtarget=wasm32-emscripten

web-run:
	zig build run -Dtarget=wasm32-emscripten
