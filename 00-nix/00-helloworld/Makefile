.PHONY: build

instantiate:
	nix-instantiate	

build-longform:
	nix-store --realise $$(nix-instantiate)

build:
	nix-build
