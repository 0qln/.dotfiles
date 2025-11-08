image: colors: font:
# https://github.com/adi1090x/rofi/blob/093c1a79f58daab358199c4246de50357e5bf462/files/launchers/type-4/style-2.rasi
# rasi
''
  /*****----- Global Properties -----*****/
  * {
      background:     ${colors.background};
      border:         ${colors.border};
      background-alt: ${colors.background-alt};
      foreground:     ${colors.foreground};
      foreground-selected:     ${colors.foreground-selected};
      selected:       ${colors.selected};
      active:         ${colors.active};
      urgent:         ${colors.urgent};
  }

  * {
      font:           "${font}";
  }

  /*****----- Configuration -----*****/
  configuration {
      modi:                       "drun,run,filebrowser,window";
      show-icons:                 true;
      display-drun:               "APPS";
      display-run:                "RUN";
      display-filebrowser:        "FILES";
      display-window:             "WINDOW";
      drun-display-format:        "{name}";
      window-format:              "{w} · {c} · {t}";
  }

  /*****----- Main Window -----*****/
  window {
      /* properties for window widget */
      transparency:                "real";
      location:                    center;
      anchor:                      center;
      fullscreen:                  false;
      width:                       1000px;
      x-offset:                    0px;
      y-offset:                    0px;

      /* properties for all widgets */
      enabled:                     true;
      border-radius:               15px;
      cursor:                      "default";
      background-color:            @background;
  }

  /*****----- Main Box -----*****/
  mainbox {
      enabled:                     true;
      spacing:                     0px;
      background-color:            transparent;
      orientation:                 horizontal;
      children:                    [ "imagebox", "listbox" ];
  }

  imagebox {
      padding:                     20px;
      background-color:            transparent;
      background-image:            url("${image}", height);
      orientation:                 vertical;
      children:                    [ "inputbar", "dummy", "mode-switcher" ];
  }

  listbox {
      spacing:                     20px;
      padding:                     20px;
      background-color:            transparent;
      orientation:                 vertical;
      children:                    [ "message", "listview" ];
  }

  dummy {
      background-color:            transparent;
  }

  /*****----- Inputbar -----*****/
  inputbar {
      enabled:                     true;
      spacing:                     10px;
      padding:                     15px;
      border-radius:               10px;
      background-color:            @background-alt;
      text-color:                  @foreground;
      children:                    [ "textbox-prompt-colon", "entry" ];
  }
  textbox-prompt-colon {
      enabled:                     true;
      expand:                      false;
      str:                         "";
      background-color:            inherit;
      text-color:                  inherit;
  }
  entry {
      enabled:                     true;
      background-color:            inherit;
      text-color:                  inherit;
      cursor:                      text;
      placeholder:                 "Search";
      placeholder-color:           inherit;
  }

  /*****----- Mode Switcher -----*****/
  mode-switcher{
      enabled:                     true;
      spacing:                     20px;
      background-color:            transparent;
      text-color:                  @foreground;
  }
  button {
      padding:                     15px;
      border-radius:               10px;
      background-color:            @background-alt;
      text-color:                  inherit;
      cursor:                      pointer;
  }
  button selected {
      background-color:            @selected;
      text-color:                  @foreground-selected;
  }

  /*****----- Listview -----*****/
  listview {
      enabled:                     true;
      columns:                     1;
      lines:                       8;
      cycle:                       true;
      dynamic:                     true;
      scrollbar:                   false;
      layout:                      vertical;
      reverse:                     false;
      fixed-height:                true;
      fixed-columns:               true;

      spacing:                     10px;
      background-color:            transparent;
      text-color:                  @foreground;
      cursor:                      "default";
  }

  /*****----- Elements -----*****/
  element {
      enabled:                     true;
      spacing:                     15px;
      padding:                     8px;
      border-radius:               10px;
      background-color:            transparent;
      text-color:                  @foreground;
      cursor:                      pointer;
  }
  element normal.normal {
      background-color:            inherit;
      text-color:                  inherit;
  }
  element normal.urgent {
      background-color:            @urgent;
      text-color:                  @foreground-selected;
  }
  element normal.active {
      background-color:            @active;
      text-color:                  @foreground-selected;
  }
  element selected.normal {
      background-color:            @selected;
      text-color:                  @foreground-selected;
  }
  element selected.urgent {
      background-color:            @urgent;
      text-color:                  @foreground-selected;
  }
  element selected.active {
      background-color:            @urgent;
      text-color:                  @foreground-selected;
  }
  element-icon {
      background-color:            transparent;
      text-color:                  inherit;
      size:                        32px;
      cursor:                      inherit;
  }
  element-text {
      background-color:            transparent;
      text-color:                  inherit;
      cursor:                      inherit;
      vertical-align:              0.5;
      horizontal-align:            0.0;
  }

  /*****----- Message -----*****/
  message {
      background-color:            transparent;
  }
  textbox {
      padding:                     15px;
      border-radius:               10px;
      background-color:            @background-alt;
      text-color:                  @foreground;
      vertical-align:              0.5;
      horizontal-align:            0.0;
  }
  error-message {
      padding:                     15px;
      border-radius:               20px;
      background-color:            @background;
      text-color:                  @foreground;
  }
''
