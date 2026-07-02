{
  description = "Custom Neovim setup with Nix";
           	
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      language-server-bitbake = pkgs.buildNpmPackage rec {
        pname = "language-server-bitbake";
        version = "2.9.0";

        src = pkgs.fetchurl {
          url = "https://registry.npmjs.org/language-server-bitbake/-/language-server-bitbake-${version}.tgz";
          hash = "sha512-LMNCcDTXqLjvxeKus8rZg5hTVaVGO+9eRTSIoNKS34y650RC6EQbijFxL4zCr0T/n/Y3rY4zRdn9Y3DFEkzwnw==";
        };

	postPatch = ''
	  cp ${./lsb-package.json} ./package.json
	  cp ${./lsb-package-lock.json} ./package-lock.json
	'';
        
	# First `nix build` will fail with a mismatch and print the correct
        # hash to paste here.
        npmDepsHash = "sha256-vAJaAP+Yx0Zx3y/srWqq3ocie7kCJmsRB6e8QpSpiWk=";

        dontNpmBuild = true;

        installPhase = ''
          runHook preInstall
          mkdir -p $out/lib/node_modules/${pname}
          cp -r . $out/lib/node_modules/${pname}
          mkdir -p $out/bin
          ln -s $out/lib/node_modules/${pname}/out/server.js $out/bin/language-server-bitbake
          chmod +x $out/bin/language-server-bitbake
          runHook postInstall
        '';
      };

      plugins = with pkgs.vimPlugins; [
        localPlugins
        nightfox-nvim
        nvim-lspconfig
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        luasnip
	nvim-lint
        (nvim-treesitter.withPlugins (p: [
          p.c p.cpp p.python p.bash p.json p.yaml p.lua
        ]))
        plenary-nvim     # required dependency of telescope
        telescope-nvim
        lualine-nvim
        vim-fugitive
        vim-commentary
	bitbake
      ];

      extraPackages = with pkgs; [
        lazygit
        shellcheck
        xdg-utils
        clang-tools
        cscope
        pyright
        gdb
	oelint-adv
        lua-language-server
        bash-language-server
        yaml-language-server
	bash-language-server
	cmake-language-server
	docker-language-server
	systemd-language-server
	language-server-bitbake
      ];

      customNeovim = pkgs.neovim.override {
        configure = {
	  customRC = ''
            lua << EOF
            ${builtins.readFile ./init.lua}
            EOF
          '';
          packages.myPlugins.start = plugins;
        };
      };

    nvimEnv = pkgs.symlinkJoin {
        name = "nix-nvim";
  	paths = [ customNeovim ];
  	buildInputs = [ pkgs.makeWrapper ];
  	postBuild = ''
    	wrapProgram $out/bin/nvim \
      	--prefix PATH : ${pkgs.lib.makeBinPath extraPackages}
	'';
    };

    localPlugins = pkgs.stdenv.mkDerivation {
        name = "local-nvim-plugins";
        src = ./lua;
        installPhase = ''
        mkdir -p $out/lua
        cp *.lua $out/lua/
        '';
    };

    in {
      packages.${system}.default = nvimEnv;

      apps.${system}.default = {
        type = "app";
        program = "${nvimEnv}/bin/nvim";
      };
    };
}
