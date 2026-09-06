{ ... }:

{
  # see https://wiki.archlinux.org/title/X_keyboard_extension for xkb keymap settings
  keymap = ''
    xkb_keymap {
        xkb_keycodes { include "evdev+aliases(qwerty)"                };
        xkb_types    { include "complete+numpad(mac)"                 };
        xkb_compat   { include "complete"                             };
        xkb_symbols  { include "pc+us+inet(evdev)+fkeys(basic_13-24)" };
    };
  '';

  inputs = [
    {
      match.is-pointer = true;
      accel-profile = "flat";
      accel-speed = -0.9375;
      natural-scrolling = false;
    }
    {
      match.name = "ydotoold virtual device";
      # accel-speed = 0.0;
      accel-speed = -0.5;
    }
    {
      match.is-keyboard = true;
    }
  ];
}
