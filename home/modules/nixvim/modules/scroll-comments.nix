{pkgs, ...}: {
  programs.nixvim = {
    extraConfigLuaPre = ''
      _G.ScrollBox = {}

      -- Default interior width for empty boxes
      _G.ScrollBox.default_width = 40

      --- Build a scroll box from text lines.
      --- @param lines string[]  The raw lines to wrap (empty table = empty box)
      --- @param opts? {padding:integer, style:string}
      function ScrollBox.make_scroll_box(lines, opts)
        opts = opts or {}
        local padding = opts.padding or 1
        local style = opts.style or "standard"

        -- Interior width (text + padding, minimum 2)
        local max_len = 0
        for _, line in ipairs(lines) do
          local stripped = line:gsub("%s+$", "")
          if #stripped > max_len then max_len = #stripped end
        end

        local interior
        if #lines == 0 then
          interior = math.max(_G.ScrollBox.default_width, padding * 2)
        else
          interior = math.max(max_len + 2 * padding, 2)
        end

        local rule = "|*|" .. string.rep("-", interior) .. "|*|"

        -- Text lines: |*| text … |*|
        local body = {}
        for _, line in ipairs(lines) do
          local stripped = line:gsub("%s+$", "")
          local padded = stripped .. string.rep(" ", interior - #stripped)
          table.insert(body, "|*| " .. padded .. " |*|")
        end

        -- Empty box variants
        if #lines == 0 then
          if style == "rust" then
            body = { rule, "|*| " .. string.rep(" ", interior) .. " |*|", rule }
          else
            body = { rule }
          end
        elseif style == "rust" then
          table.insert(body, 1, rule)
          table.insert(body, rule)
        end

        -- Top & bottom curls
        local top_border = "/*\\" .. string.rep(" ", interior) .. "/*\\"
        local bottom_border
        if style == "rust" then
          bottom_border = "\\*/" .. string.rep(" ", interior) .. "\\*/"
        else
          bottom_border = "\\*/" .. string.rep(" ", interior) .. "/*\\*/"
        end

        local result = { top_border }
        for _, l in ipairs(body) do table.insert(result, l) end
        table.insert(result, bottom_border)
        return result
      end

      --- Determine style from filetype. Rust → "rust", else "standard"
      local function detect_style()
        if vim.bo.filetype == "rust" then return "rust" end
        return "standard"
      end

      --- Wrap selected text (visual mode) into a box.
      function ScrollBox.wrap()
        local start_line = vim.fn.line("'<")
        local end_line = vim.fn.line("'>")
        local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
        local style = detect_style()
        local box = ScrollBox.make_scroll_box(lines, { style = style })
        vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, box)
      end

      --- Insert an empty box at cursor (normal mode).
      function ScrollBox.insert_empty()
        local line = vim.fn.line(".")
        local style = detect_style()
        local box = ScrollBox.make_scroll_box({}, { style = style })
        vim.api.nvim_buf_set_lines(0, line - 1, line, false, box)

        -- Place cursor on the first content line
        if style == "rust" then
          vim.api.nvim_win_set_cursor(0, { line + 1, 5 })
        else
          vim.api.nvim_win_set_cursor(0, { line, 5 })
        end
      end

      --- Reflow the box at cursor: adjust width to fit text.
      function ScrollBox.reflow()
        local cur = vim.fn.line(".")
        -- Find top border
        local top = nil
        for i = cur, 1, -1 do
          local l = vim.fn.getline(i)
          if l:match("^/*\\%s+/*\\$") then
            top = i
            break
          end
        end
        if not top then return end

        -- Find bottom border & determine style
        local bottom = nil
        local style = nil
        for i = cur, vim.fn.line("$") do
          local l = vim.fn.getline(i)
          if l:match("^\\*/ \\*/\\*\\*/$") or l:match("^\\*/  \\*/\\*\\*/$") then -- allow variable spacing
            bottom = i
            style = "standard"
            break
          elseif l:match("^\\*/%s+\\*/$") then
            bottom = i
            style = "rust"
            break
          end
        end
        if not bottom or top >= bottom then return end

        -- Collect text lines, skip dashes
        local text_lines = {}
        for i = top + 1, bottom - 1 do
          local l = vim.fn.getline(i)
          if not l:match("^|%*|%-+|%*|$") then
            local text = l:match("^|%*| (.*) |%*|$")
            if text then table.insert(text_lines, text) end
          end
        end
        if #text_lines == 0 then return end

        local box = ScrollBox.make_scroll_box(text_lines, { style = style })
        vim.api.nvim_buf_set_lines(0, top - 1, bottom, false, box)

        -- Attempt to keep cursor near original position
        local offset = math.min(cur - top, #text_lines)
        vim.api.nvim_win_set_cursor(0, { top + offset, 5 })
      end

      -- ==================== HIGHLIGHTING ====================

      -- Disable italic for all comment highlight groups globally
      local function no_comment_italic()
        local comment_groups = {
          "Comment", "@comment", "@comment.line", "@comment.block", "@comment.documentation",
        }
        for _, name in ipairs(comment_groups) do
          local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
          if ok then
            hl.italic = false
            vim.api.nvim_set_hl(0, name, hl)
          end
        end
      end
      no_comment_italic()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = no_comment_italic })

      -- Border base (fg/bg will be set per-filetype)
      vim.api.nvim_set_hl(0, "ScrollBoxBorder", { italic = false })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "rust" },
        callback = function()
          local ok, comment_hl = pcall(vim.api.nvim_get_hl, 0, { name = "Comment" })
          if not ok then comment_hl = {} end
          local border_fg = comment_hl.fg or "NONE"
          local border_bg = comment_hl.bg or "NONE"
          vim.api.nvim_set_hl(0, "ScrollBoxBorder", {
            fg = border_fg, bg = border_bg, italic = false,
          })

          -- Safe matchadd helper
          local function safe_matchadd(group, pattern, priority)
            pcall(vim.fn.matchadd, group, pattern, priority, -1, { window = 0 })
          end

          -- Italic text (only lines with content between |*| ... |*|)
          safe_matchadd("ScrollBoxText", [[\v^\s*\|\*\|\s+\zs.+\ze\s+\|\*\|\s*$]], 10)

          -- Non‑italic borders (priority 11 over syntax)
          safe_matchadd("ScrollBoxBorder", [[\v^\s*\|\*\|\-+\|\*\|\s*$]], 11)   -- dashes
          safe_matchadd("ScrollBoxBorder", [[\v^\s*/\*\\\s+.*/\*\\\s*$]], 11)   -- top curl
          safe_matchadd("ScrollBoxBorder", [[\v^\s*\\\*/\s+.*/\*\\\*/\s*$]], 11) -- standard bottom
          safe_matchadd("ScrollBoxBorder", [[\v^\s*\\\*/\s+.*\\\*/\s*$]], 11)    -- rust bottom
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "rust" },
        callback = function()
          -- Grab Comment's fg/bg but force italic off
          local ok, comment_hl = pcall(vim.api.nvim_get_hl, 0, { name = "Comment" })
          if not ok then comment_hl = {} end
          local fg = comment_hl.fg or "NONE"
          local bg = comment_hl.bg or "NONE"

          vim.api.nvim_set_hl(0, "@scrollbox.border", {
            fg = fg,
            bg = bg,
            italic = false,
            bold = false,
            underline = false,
          })
        end,
      })

      -- Auto-reflow when leaving Insert mode (uncomment to enable)
      vim.api.nvim_create_autocmd("InsertLeave", {
        pattern = { "*.c", "*.cpp", "*.rs" },
        callback = function() pcall(ScrollBox.reflow) end,
      })
    '';

    extraConfigLuaPost = ''
      -- Unified <leader>cs: insert empty (normal) or wrap selected (visual)
      vim.keymap.set("n", "<leader>css", function() ScrollBox.insert_empty() end,
        { desc = "Insert scroll box (style by filetype)" })
      vim.keymap.set("v", "<leader>css", function() ScrollBox.wrap() end,
        { desc = "Wrap selection in scroll box" })

      -- Reflow: adjust width to text
      vim.keymap.set("n", "<leader>csf", function() ScrollBox.reflow() end,
        { desc = "Reflow scroll box width" })

      -- Smart Enter inside a text line
      vim.keymap.set("i", "<CR>", function()
        local line = vim.api.nvim_get_current_line()
        if line:match("^|%*| .* |%*|$") then
          local interior = #line - 6
          return "<CR>" .. string.rep(" ", interior) .. " |*|"
        end
        return "<CR>"
      end, { expr = true })
    '';

    extraTreesitterQueries = {
      "rust" = ''
        ; scroll-box-top
        (line_comment) @scrollbox.border
        (#lua-match? @scrollbox.border "^/%*\\%s+/%*\\%s*$")

        ; scroll-box-dash
        (line_comment) @scrollbox.border
        (#lua-match? @scrollbox.border "^|%*|%-+|%*|%s*$")

        ; scroll-box-bottom-rust
        (line_comment) @scrollbox.border
        (#lua-match? @scrollbox.border "^\\%*/%s+\\%*/%s*$")
      '';
      "c" = ''
        ; scroll-box-top
        (comment) @scrollbox.border
        (#lua-match? @scrollbox.border "^/%*\\%s+/%*\\%s*$")

        ; scroll-box-dash
        (comment) @scrollbox.border
        (#lua-match? @scrollbox.border "^|%*|%-+|%*|%s*$")

        ; scroll-box-bottom-standard
        (comment) @scrollbox.border
        (#lua-match? @scrollbox.border "^\\%*/%s+/%*\\%*/%s*$")
      '';
      "cpp" = ''
        ; same as C – reuse the C query
        ; inherit from C? Simpler to just duplicate
        (comment) @scrollbox.border
        (#lua-match? @scrollbox.border "^/%*\\%s+/%*\\%s*$")

        (comment) @scrollbox.border
        (#lua-match? @scrollbox.border "^|%*|%-+|%*|%s*$")

        (comment) @scrollbox.border
        (#lua-match? @scrollbox.border "^\\%*/%s+/%*\\%*/%s*$")
      '';
    };
  };
}
