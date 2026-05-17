# nvim-StickyNotes
Floating Sticky Notes in Neovim

# Setup
Enable this plugin using
```Lua
require("StickyNotes").setup()
```

## Options
The following defaults are set and can be modified
```Lua
{
    relative = "editor",                    -- Where the note is placed relative to
    use_cwd = true,                         -- Whether the current working directory or the immediate parent directory determines a project
    show_title = true,                      -- Whether or not the title of the note is shown at the top of the buffer
    notes_dir = vim.fn.stdpath("cache") .. "/StickyNotes",  -- The directory of the notes cache
    size = 0.5,                             -- Size of the floating window relative to the current window
    window_style = "",                      -- Window style
    window_border = "single",               -- Window border
    show_foldcolumn = false,                -- Whether the column displaying fold locations is shown
    show_line_numbers = true,               -- Whether line numbers are shown
    exit_key = "<Esc>",                     -- The key mapped to write and quit StickyNote buffer
    files = {                               -- Default file locations
        global = "StickyNotes_Global.md",   -- Name of global file
        cwd = function()
            return vim.fn.getcwd()          -- function to get cwd
        end,
        parent = function()
            return vim.fn.expand("%:p:h")   -- function to get parent
        end,
        file_name = function(cwd)           -- naming conventions
            local base_name = vim.fs.basename(cwd)
            local parent_base_name = vim.fs.basename(vim.fs.dirname(cwd))
            return parent_base_name .. "_" .. base_name .. ".md"    -- file name format and extension
        end
    }
}
```

## Dependencies
* None!

### Recommended
Some kind of markdown renderer would be beneficial but is not necessary

Here are some markdown renderers I have tried out and liked:
Plain renderers
- "MeanderingProgrammer/render-markdown.nvim"
- "OXY2DEV/markview.nvim"

or something more feature-intense
- "YousefHadder/markdown-plus.nvim"



# Notes
* This plugin was created on and for Linux systems. While Windows and Mac _may_ work,
they have not been tested.
