{pkgs, ...}: {
  # https://wiki.nixos.org/wiki/Default_applications

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/MIME_types/Common_types

      #TODO: text and code files to kitty+nvim
    };
  };
}
