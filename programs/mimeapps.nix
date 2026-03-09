{
  config,
  pkgs,
  libs,
  ...
}:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "thunar.desktop";

      "x-scheme-handler/http" = "google-chrome.desktop";
      "x-scheme-handler/https" = "google-chrome.desktop";
      "x-scheme-handler/about" = "google-chrome.desktop";
      "x-scheme-handler/unknown" = "google-chrome.desktop";
      "text/html" = "google-chrome.desktop";

      "x-scheme-handler/mailto" = "thunderbird.desktop";
      "x-scheme-handler/mid" = "thunderbird.desktop";
      "x-scheme-handler/webcal" = "thunderbird.desktop";
      "x-scheme-handler/webcals" = "thunderbird.desktop";
      "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
      "x-scheme-handler/magnet" = "org.qbittorrent.qBittorrent.desktop";
      "text/calendar" = "thunderbird.desktop";
      "application/x-extension-ics" = "thunderbird.desktop";
      "message/rfc822" = "thunderbird.desktop";

      "text/plain" = "nvim.desktop";
      "text/csv" = "nvim.desktop";
      "text/javascript" = "nvim.desktop";
      "text/xml" = "nvim.desktop";
      "text/x-shellscript" = "nvim.desktop";
      "text/x-python" = "nvim.desktop";
      "text/x-csrc" = "nvim.desktop";
      "text/x-chdr" = "nvim.desktop";
      "text/x-c++src" = "nvim.desktop";
      "text/x-java" = "nvim.desktop";
      "text/x-makefile" = "nvim.desktop";
      "text/markdown" = "nvim.desktop";
      "text/x-lua" = "nvim.desktop";
      "application/json" = "nvim.desktop";
      "application/x-yaml" = "nvim.desktop";
      "application/toml" = "nvim.desktop";
      "application/xml" = "nvim.desktop";

      "application/zip" = "org.gnome.FileRoller.desktop";
      "application/x-tar" = "org.gnome.FileRoller.desktop";
      "application/x-compressed-tar" = "org.gnome.FileRoller.desktop";
      "application/x-bzip2-compressed-tar" = "org.gnome.FileRoller.desktop";
      "application/x-xz-compressed-tar" = "org.gnome.FileRoller.desktop";
      "application/x-zstd-compressed-tar" = "org.gnome.FileRoller.desktop";
      "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
      "application/gzip" = "org.gnome.FileRoller.desktop";
      "application/x-rar" = "org.gnome.FileRoller.desktop";
      "application/x-xz" = "org.gnome.FileRoller.desktop";
      "application/zstd" = "org.gnome.FileRoller.desktop";

      "application/pdf" = "org.kde.okular.desktop";
      "application/epub+zip" = "calibre-ebook-viewer.desktop";
      "application/x-mobipocket-ebook" = "calibre-ebook-viewer.desktop";
      "application/x-fictionbook+xml" = "calibre-ebook-viewer.desktop";
      "application/x-bittorrent" = "org.qbittorrent.qBittorrent.desktop";

      "application/vnd.oasis.opendocument.text" = "libreoffice-writer.desktop";
      "application/vnd.oasis.opendocument.spreadsheet" = "libreoffice-calc.desktop";
      "application/vnd.oasis.opendocument.presentation" = "libreoffice-impress.desktop";
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
        "libreoffice-writer.desktop";
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "libreoffice-calc.desktop";
      "application/vnd.openxmlformats-officedocument.presentationml.presentation" =
        "libreoffice-impress.desktop";
      "application/msword" = "libreoffice-writer.desktop";
      "application/vnd.ms-excel" = "libreoffice-calc.desktop";
      "application/vnd.ms-powerpoint" = "libreoffice-impress.desktop";
      "text/rtf" = "libreoffice-writer.desktop";

      "image/jpeg" = "pinta.desktop";
      "image/png" = "pinta.desktop";
      "image/gif" = "pinta.desktop";
      "image/bmp" = "pinta.desktop";
      "image/tiff" = "pinta.desktop";
      "image/webp" = "pinta.desktop";
      "image/svg+xml" = "org.kde.krita.desktop";
      "image/x-xcf" = "gimp.desktop";

      "audio/wav" = "mpv.desktop";
      "audio/mpeg" = "mpv.desktop";
      "audio/mp4" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "audio/ogg" = "mpv.desktop";
      "audio/x-vorbis+ogg" = "mpv.desktop";
      "audio/aac" = "mpv.desktop";
      "audio/webm" = "mpv.desktop";

      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      "video/x-flv" = "mpv.desktop";
      "video/mp2t" = "mpv.desktop";
    };
  };
}
