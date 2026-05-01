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
vim.keymap.set("n", "<leader>n", "<cmd>StickyNote<CR>", { desc = "Open StickyNote" })
