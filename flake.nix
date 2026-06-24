{
  description = "Custom Neovim setup with Nix";
           	
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      plugins = with pkgs.vimPlugins; [
        localPlugins
        nightfox-nvim
        nvim-lspconfig
        nvim-cmp
        cmp-nvim-lsp
        cmp-buffer
        cmp-path
        luasnip
        (nvim-treesitter.withPlugins (p: [
          p.c p.cpp p.python p.bash p.json p.yaml p.lua
        ]))
        plenary-nvim     # required dependency of telescope
        telescope-nvim
        lualine-nvim
        vim-fugitive
        vim-commentary
      ];

      extraPackages = with pkgs; [
        lazygit
        shellcheck
        xdg-utils
        clang-tools
        cscope
        pyright
        gdb
        lua-language-server
        bash-language-server
        yaml-language-server
	bash-language-server
	cmake-language-server
	docker-language-server
	systemd-language-server
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
