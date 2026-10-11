{ pkgs, ... }:
{
  programs.bash = {
    enable = true;
    initExtra = ''
      export ZVM_INSTALL="$HOME/.zvm/self"
      if [ -d "$ZVM_INSTALL" ]; then
        export PATH="$PATH:$HOME/.zvm/bin"
        export PATH="$PATH:$ZVM_INSTALL"
      fi
      PS1="\[\033[01;93m\]\u@\h\[\033[00m\]:\[\033[01;31m\]\w\[\033[00m\]\$ "

      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }
    '';
    shellAliases = {
      ll = "ls -la";
      t = "tmux";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
