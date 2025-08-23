{ ... }:
{
  programs.chromium = {
    enable = true;
    extensions = [
      {
        # Passbolt
        id = "didegimhafipceonhjepacocaffmoppf";
      }
    ];
  };
}
