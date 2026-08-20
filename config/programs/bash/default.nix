{
  home-manager.sharedModules = [
    {
      programs.bash = {
        enable = true;

        # only separate commands after prompt
        # doesnt newline on new terminals or after a clear
        initExtra = ''
          _first_prompt_=1
          PROMPT_COMMAND='if [[ -n "$_first_prompt_" ]]; then unset _first_prompt_; else echo; fi'
          PS1="\[\033[1;38;5;53m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\] "

          export EDITOR=nvim
          export VISUAL=nvim
        '';
      };
    }
  ];
}
