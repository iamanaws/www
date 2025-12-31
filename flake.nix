{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs, ... }:
    let
      forSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system: f (import nixpkgs { inherit system; })
        );
    in
    {
      formatter = forSystems (pkgs: pkgs.nixfmt-tree);

      packages = forSystems (pkgs: {
        default = pkgs.stdenvNoCC.mkDerivation {
          pname = "iamanaws-www";
          version = "1.0.0";

          src = pkgs.lib.cleanSource ./.;

          nativeBuildInputs = with pkgs; [ mandoc ];

          buildPhase = ''
            runHook preBuild

            # Generate HTML from manpages
            mandoc -T html -O style=assets/css/man-page.css iamanaws.7 > iamanaws.html
            mandoc -T html -O style=assets/css/man-page.css paranoia.7 > paranoia.html

            # Inject base target for external links
            sed -i 's/<head>/<head>\n  <base target="_blank">/' iamanaws.html
            sed -i 's/<head>/<head>\n  <base target="_blank">/' paranoia.html

            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            mkdir -p $out/assets
            cp *.html *.js $out/
            cp -r assets/. $out/assets/

            runHook postInstall
          '';
        };
      });

      devShells = forSystems (pkgs: {
        default = pkgs.mkShell {
          inputsFrom = [ self.packages.${pkgs.stdenv.hostPlatform.system}.default ];
          packages = [
            self.packages.${pkgs.stdenv.hostPlatform.system}.default
            pkgs.python3
          ];

          shellHook = ''
            echo ""
            echo "  serve   - Start local dev server on :8080"
            echo ""

            serve() {
              echo "Serving at http://127.0.0.1:8080/"
              python3 -m http.server 8080 --directory "${
                self.packages.${pkgs.stdenv.hostPlatform.system}.default
              }"
            }

            export -f serve
          '';
        };
      });
    };
}
