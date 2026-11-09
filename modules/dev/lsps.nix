{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lua-language-server
    nil
    pyright
    gopls
    vscode-langservers-extracted
    rust-analyzer
    stylua
    clang-tools
    clang-tools
    llvmPackages.openmp
    asm-lsp
    zls
    glsl_analyzer
  ];
}
