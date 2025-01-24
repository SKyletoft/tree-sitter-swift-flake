{
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
		flake-utils.url = "github:numtide/flake-utils";
		flake-compat = {
			url = "github:edolstra/flake-compat";
			flake = false;
		};
	};
	outputs = { self, nixpkgs, flake-utils, ... }@inputs: (flake-utils.lib.eachDefaultSystem (system:
		let
			pkgs = import nixpkgs {inherit system;};
			nativeBuildInputs = with pkgs; [
				nodejs
				tree-sitter
				git
			];
		in {
			defaultPackage = pkgs.callPackage (nixpkgs + "/pkgs/development/tools/parsing/tree-sitter/grammar.nix") { } {
				language = "swift";
				src = pkgs.fetchFromGitHub {
					owner = "alex-pinkus";
					repo = "tree-sitter-swift";
					rev = "f4be8072f18fb9704fd35d4b8154ae2b19e314c0";
					hash = "sha256-B/LtB+HyZKXra/Fs2ZyhVSjUXUJKQDgG8xuv/LpL6YA=";
				};
				inherit (pkgs.tree-sitter) version;
				inherit nativeBuildInputs;
				preBuild = ''
					sed -i "s/npx //g" Makefile
					make src/parser.c
				'';
				installPhase = ''
					mkdir -p $out/bin
					cp parser $out/bin/swift-grammar
				'';
			};
			devShell = pkgs.mkShell {
				inherit nativeBuildInputs;
			};
		}));
}
