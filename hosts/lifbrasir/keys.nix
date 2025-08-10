{ config, pkgs, ... }:
let
in
{
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Remove the spam warnings when pressing f2/f3 in journalctl:
  # ```
  # Jul 13 02:13:42 nixos kernel: atkbd serio0: Unknown key pressed (translated set 2, code 0xab on isa0060/serio0).
  # Jul 13 02:13:42 nixos kernel: atkbd serio0: Use 'setkeycodes e02b <keycode>' to make it known.
  # ```
  #
  # ...the f2 and f3 keys work perfectly fine and showkeys can actually see 223/224
  # see them as such (in contrast to other tools such as evtest, which only shows the raw ab)
  #
  #
  # this is likely a firmware issue. see:
  #
  #
  # solution references:
  # https://man.archlinux.org/man/setkeycodes.8
  # https://wiki.archlinux.org/title/Map_scancodes_to_keycodes
  #
  services.udev.extraHwdb = ''
    evdev:input:b0011v0001p0001eAB83*
      KEYBOARD_EKY_e02b=reserved
  '';

  # https://nixos.wiki/wiki/Backlight
  programs.light = {
    enable = true;
  };

  services.actkbd = {
    enable = true;
    bindings = [
      {
        keys = [ 224 ];
        events = [ "key" ];
        command = "${pkgs.light}/bin/light -U 10";
      }
      {
        keys = [ 225 ];
        events = [ "key" ];
        command = "${pkgs.light}/bin/light -A 10";
      }
    ];
  };
}
