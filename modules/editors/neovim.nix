{ pkgs, ... }:
{
  programs.neovim.plugins = [ pkgs.vimPlugins.nvim-treesitter.withAllGrammars ];
  home.packages = with pkgs; [
    neovim
    tree-sitter
  ];

  home.file.".config/nvim" = {
    target = ".config/nvim";
    source = ./nvim-config;
    recursive = true;
    force = true;
  };
}
