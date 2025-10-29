{
  config,
  lib,
  ...
}:
with lib; {
  programs.nixvim = {
    plugins = {
      lualine = {
        enable = true;
        settings = {
          sections = {
            lualine_z = mkMerge [
              (mkIf (!config.modules.tmux.statusline.enable) [
                {
                  __unkeyed-1 = {
                    __raw = ''
                        function()
                        -- check if current pane is zoomed
                        local result = io.popen("tmux list-panes -F '#F' | grep Z")

                        if result ~= nil and result:read("*a") ~= "" then
                          result:close()
                          return "■■" --current pane is zoomed
                        else
                          return "■" -- not zoomed
                        end
                      end
                    '';
                  };
                  # We don't need space before this
                  padding = {
                    left = 1;
                    right = 1;
                  };
                  color = {
                    fg = "#00ff00";
                  };
                  cond = {
                    __raw = ''
                      function()
                        return os.getenv("TMUX") ~= nil
                      end
                    '';
                  };
                  on_click = {
                    __raw = ''
                      function()
                        os.execute("tmux resize-pane -Z")
                      end
                    '';
                  };
                }
              ])
            ];
          };
        };
      };
    };
  };
}
