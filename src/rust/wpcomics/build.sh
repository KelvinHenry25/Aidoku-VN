#!/bin/bash

set -e  # dừng nếu gặp lỗi
ROOT_DIR=$(pwd)

build_target="wasm32-unknown-unknown"

if [ "$1" != "-a" ] && [ "$1" != "" ]; then
	# compile specified source
	cargo +nightly build --release --target $build_target
	
	echo "Packaging $1"
	mkdir -p target/$build_target/release/Payload
	cp res/* target/$build_target/release/Payload
	if [ -d "sources/$1/res" ]; then
		cp sources/$1/res/* target/$build_target/release/Payload
	fi
	cd target/$build_target/release
	cp "$1.wasm" Payload/main.wasm
	zip -r "$1.aix" Payload > /dev/null
	mv "$1.aix" "$ROOT_DIR/$1.aix"
	rm -rf Payload
	cd "$ROOT_DIR"
else
	# compile all sources
	cargo +nightly build --release --target $build_target

	for dir in sources/*/
	do
		dir=${dir%*/}; dir=${dir##*/}
		echo "Packaging $dir"

		mkdir -p target/$build_target/release/Payload
		cp res/* target/$build_target/release/Payload
		if [ -d "sources/$dir/res" ]; then
			cp sources/$dir/res/* target/$build_target/release/Payload
		fi
		cd target/$build_target/release
		cp "$dir.wasm" Payload/main.wasm
		zip -r "$dir.aix" Payload > /dev/null
		mv "$dir.aix" "$ROOT_DIR/$dir.aix"
		rm -rf Payload
		cd "$ROOT_DIR"
	done
fi
