{
  description = "A basic flake with devShell and package for this first Go project with Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  };

  outputs = { nixpkgs, ... }:
    let
      forAllSystems = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f (import nixpkgs { inherit system; }));
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            go
            gopls
            gotools
            golangci-lint
            tree-sitter
            tree-sitter-grammars.tree-sitter-go
          ];
        };
      });

      packages = forAllSystems (pkgs:
        let
          name = "hello-go-nix";
          version = "0.1.0";
        in
        {
          default = pkgs.buildGoModule {
            inherit name version;
            pname = name;
            src = ./.;
            vendorHash = null;

            env.CGO_ENABLED = 0;
            ldflags = [ "-X main.Version=${version}" ];

            meta = {
              description = "Simple hello app in Go and built with Nix";
              homepage = "https://github.com/alexandregv/hello-go-nix";
              license = pkgs.lib.licenses.mit;
              maintainers = with pkgs.lib.maintainers; [ alexandregv ];
            };
          };
        }
      );
    };
}
