{pkgs, ...}: {
  # https://wiki.nixos.org/wiki/Default_applications

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/MIME_types/Common_types

      #TODO: text and code files to kitty+nvim

      "image/png" = "qimgv.desktop";
      "video/webm" = "qimgv.desktop";
      "image/jpeg" = "qimgv.desktop";
      "image/gif" = "qimgv.desktop";
      "image/bmp" = "qimgv.desktop";
      "image/webp" = "qimgv.desktop";

      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";

      "x-scheme-handler/http" = "zen-twilight.desktop";
      "x-scheme-handler/https" = "zen-twilight.desktop";
      "x-scheme-handler/chrome" = "zen-twilight.desktop";
      "text/html" = "zen-twilight.desktop";
      "application/x-extension-htm" = "zen-twilight.desktop";
      "application/x-extension-html" = "zen-twilight.desktop";
      "application/x-extension-shtml" = "zen-twilight.desktop";
      "application/xhtml+xml" = "zen-twilight.desktop";
      "application/x-extension-xhtml" = "zen-twilight.desktop";
      "application/x-extension-xht" = "zen-twilight.desktop";
    };
  };
}
