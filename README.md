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
    use_cwd = true,                         -- Whether the current working directory or the immediate parent directory determines a project
    show_title = true,                      -- Whether or not the title of the note is shown at the top of the buffer
    notes_dir = vim.fn.stdpath("cache") .. "/StickyNotes",  -- The directory of the notes cache
    size = 0.5,                             -- Size of the floating window relative to the current window
    window_style = "minimal",               -- Window style
    window_border = "solid",                -- Window border
}
```

## Dependencies
* None!


# Notes
This plugin was created on and for Linux systems. While Windows and Mac _may_ work, they have not been tested.
