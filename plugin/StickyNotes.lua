if vim.g.loaded_stickynotes then return end
vim.g.loaded_stickynotes = 1

local sticky = require("StickyNotes")

-- Open StickyNote
vim.api.nvim_create_user_command('StickyNote', function(opts)
    sticky.open_notes(opts)
end, {
    nargs = '?', -- One paramater allowed
    complete = function(_, _, _)
        return { "global", "manage" }
    end
})

-- Default keymap
vim.keymap.set("n", "<leader>n", function() sticky.open_notes() end, { desc = "Open StickyNote" })
