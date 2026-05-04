_:
# rasi
''
  @import "~/.config/rofi/config.rasi"

  configuration {
      modes: [run];
      run-command: "todoist quick '{cmd}'";
  }

  entry {
      placeholder: "Add a task";
  }

  textbox-prompt-colon {
      str: "✏";
  }

  listbox {
      enabled: false;
  }

  window {
      width: 600px;
  }

  mainbox {
      background-color: @background;
      children: [inputbar];
  }

  inputbar {
      expand: true;
  }
''
