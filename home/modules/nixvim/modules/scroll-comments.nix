{pkgs, ...}: {
  programs.nixvim = {
    extraConfigLuaPre = ''
      -- Create a global to hold our functions
      ScrollBox = {}

      --- Build a "scroll" ASCII box around the given lines
      --- @param lines string[]  The text lines to place inside (empty = just the box)
      --- @param padding integer  Extra spaces to add on each side of the longest line
      --- @return string[] The full box, including top/bottom borders
      function ScrollBox.make_scroll_box(lines, padding)
        padding = padding or 1
        -- Calculate the interior width (text area width)
        local max_len = 0
        for _, line in ipairs(lines) do
          local stripped = line:gsub("%s+$", "")
          if #stripped > max_len then
            max_len = #stripped
          end
        end

        local interior = math.max(max_len + 2 * padding, 2)

        -- Build the horizontal rule line (all dashes inside the |*| ... |*|)
        local rule = "|*| " .. string.rep("-", interior) .. " |*|"

        -- Build the content lines with proper spacing
        local body = {}
        for _, line in ipairs(lines) do
          local stripped = line:gsub("%s+$", "")
          local padded = stripped .. string.rep(" ", interior - #stripped)
          table.insert(body, "|*| " .. padded .. " |*|")
        end

        if #lines == 0 then
          body = { rule }
        end

        -- Top and bottom borders (scroll ends)
        local top_left = "/*\\"
        local top_right = "/*\\"
        local bottom_left = "\\*/"
        local bottom_right = "/*\\*/"

        -- Borders have same interior width (spaces only, no asterisks)
        local top_border = top_left .. string.rep(" ", interior + 2) .. top_right   -- +2 for the two spaces
        local bottom_border = bottom_left .. string.rep(" ", interior + 2) .. bottom_right

        local result = {}
        table.insert(result, top_border)
        for _, l in ipairs(body) do
          table.insert(result, l)
        end
        table.insert(result, bottom_border)

        return result
      end

      --- Visually wrap selected lines, or insert an empty box
      function ScrollBox.wrap()
        local mode = vim.fn.mode()
        local start_line, end_line

        if mode == "v" or mode == "V" or mode == "\x16" then
          start_line = vim.fn.line("'<")
          end_line = vim.fn.line("'>")
        else
          start_line = vim.fn.line(".")
          end_line = start_line
        end

        local lines = {}
        if mode:find("[vV\x16]") then
          lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
        else
          lines = { "" }
        end

        local box = ScrollBox.make_scroll_box(lines, 1)
        vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, box)

        if #lines == 1 and lines[1] == "" then
          -- Place cursor on the empty interior line, after the "|*| "
          vim.api.nvim_win_set_cursor(0, { start_line + 1, 5 })  -- column 5 = after "|*| "
        end
      end
    '';

    extraConfigLuaPost = ''
      -- Keymaps to trigger the wrap
      vim.keymap.set("n", "<leader>cs", ScrollBox.wrap, { desc = "Insert empty scroll box" })
      vim.keymap.set("v", "<leader>cs", ScrollBox.wrap, { desc = "Wrap selection in scroll box" })

      -- Auto-expand when pressing Enter inside a scroll box line
      vim.keymap.set("i", "<CR>", function()
        local line = vim.api.nvim_get_current_line()
        -- Match any line of the form |*| ... |*| (with at least one space after |*|)
        if line:match("^|%*| .* |%*|$") then
          -- The interior width = total line length - 8 (for the left "|*| " and right " |*|")
          local interior = #line - 8
          return "<CR>" .. string.rep(" ", interior) .. " |*|"  -- space before |*| for the right side
        end
        return "<CR>"
      end, { expr = true })
    '';
  };
}
