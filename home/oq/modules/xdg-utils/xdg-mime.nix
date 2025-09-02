{ pkgs, ... }:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {

      # https://developer.mozilla.org/en-US/docs/Web/HTTP/Guides/MIME_types/Common_types

      "image/png" = "qimgv.desktop";
      "video/webm" = "qimgv.desktop";
      "image/jpeg" = "qimgv.desktop";
      "image/gif" = "qimgv.desktop";
      "image/bmp" = "qimgv.desktop";
      "image/webp" = "qimgv.desktop";

      "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";

    };
  };
}
