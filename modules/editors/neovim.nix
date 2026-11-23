
{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    withPython3 = true;

    extraPython3Packages = ps: with ps; [
      jupyter-client
      nbformat
    ];

    plugins = [
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
    ];
  };

  home.packages = with pkgs; [
    tree-sitter
    python3Packages.jupytext
    imagemagick
  ];

  home.file.".config/nvim" = {
    target = ".config/nvim";
    source = ./nvim-config;
    recursive = true;
    force = true;
  };
home.file.".config/nvim-python-host.lua".text =
  let
    neovimPython = pkgs.python3.withPackages (ps: with ps; [
      pynvim
      jupyter-client
      nbformat
    ]);
  in ''
    vim.g.python3_host_prog = "${neovimPython}/bin/python3"
  '';
}

