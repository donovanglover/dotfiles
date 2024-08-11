{
  programs.alacritty = {
    enable = true;

    settings = {
      window.padding = {
        x = 10;
        y = 10;
      };

      mouse.hide_when_typing = true;
      selection.save_to_clipboard = true;
    };
  };
}
