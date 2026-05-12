{
  description = "A basic flake with devShell and package for this first Go project with Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        name = "hello-go-nix";
        version = "0.1.0";
      in
      with pkgs;
      {
        devShells.default = mkShell {
          buildInputs = [
            bashInteractive
            go
            gotools
            golangci-lint
          ];
        };

        packages.default = buildGoModule {
          inherit name version;
          pname = name;
          src = ./.;
          vendorHash = null;

          env.CGO_ENABLED = 0;
          ldflags = [ "-X main.Version=${version}" ];

          meta = {
            description = "Simple hello app in Go and built with Nix";
            homepage = "https://github.com/alexandregv/hello-go-nix";
            license = lib.licenses.mit;
            maintainers = with lib.maintainers; [ alexandregv ];
          };
        };
      }
    );
}
