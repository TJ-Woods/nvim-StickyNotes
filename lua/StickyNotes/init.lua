local M = {}

-- Default configuration
M.config = {
    relative = "editor",
    use_cwd = true,
    show_title = true,
    notes_dir = vim.fn.stdpath("cache") .. "/StickyNotes",
    size = 0.5,
    window_style = "",
    window_border = "single",
    show_foldcolumn = false,
    show_line_numbers = true,
    exit_key = "<Esc>",
    files = {
        global = "StickyNotes_Global.md",
        cwd = function()
            return vim.fn.getcwd()
        end,
        parent = function()
            return vim.fn.expand("%:p:h")
        end,
        file_name = function(cwd)
            local base_name = vim.fs.basename(cwd)
            local parent_base_name = vim.fs.basename(vim.fs.dirname(cwd))
            return parent_base_name .. "_" .. base_name .. ".md"
        end
    }
}

-- Checks if StickyNotes cache directory exists, attempts to create it if not
local function check_cache_dir(dir)
    local notes_cache_dir = vim.fs.normalize(dir)

    if vim.fn.isdirectory(notes_cache_dir) == 0 then
        local success = vim.uv.fs_mkdir(notes_cache_dir, 493)   -- 493 = 0o755 for chmod
        if not success then
            vim.notify("[StickyNote] Could not create folder " .. notes_cache_dir, vim.log.levels.ERROR)
        end
    end

    return notes_cache_dir
end

-- Checks if note file exists for current file
local function check_note_file(file)
    local note_file_path = vim.fs.normalize(M.notes_cache_dir .. '/' .. file)
    if vim.tbl_isempty(vim.fs.find(file, { type = "file", path = M.notes_cache_dir })) then
        vim.uv.fs_open(note_file_path, "w", 420, function(err, fd)  -- 420 = 0o644 for chmod
            if err ~= nil or fd == nil then
                vim.print("[StickyNotes] Could not create note file " .. note_file_path)
                return
            end
            vim.uv.fs_close(fd)
        end)
    end
    return note_file_path
end

-- Opens the floating buffer
local function open_float(file_path, file_name)
    local curr_win = vim.api.nvim_get_current_win()
    local win_width = vim.api.nvim_win_get_width(curr_win)
    local win_height = vim.api.nvim_win_get_height(curr_win)
    local width = math.floor((win_width * M.config.size) + (1 - M.config.size))
    local height = math.floor((win_height * M.config.size) + (1 - M.config.size))

    local note_buf = vim.api.nvim_create_buf(false, true)

    local win_opts = {
        relative = M.config.relative,
        width = width,
        height = height,
        col = (win_width - width) / 2,
        row = (win_height - height) / 2,
        focusable = true,
        style = M.config.window_style,
        border = M.config.window_border
    }

    if M.config.show_title then
        if file_name ~= nil then
            win_opts.title = file_name
        else
            win_opts.title = ""
        end
    end

    -- Open window
    local note_win = vim.api.nvim_open_win(note_buf, true, win_opts)
    -- Mark the window
    vim.api.nvim_win_set_var(note_win, "IsStickyNote", true)
    -- Create Group
    local sticky_group = vim.api.nvim_create_augroup("StickyNoteLogic", { clear = true })

    -- Open correct file in buffer
    vim.cmd("edit " .. file_path)
    vim.api.nvim_buf_set_option(note_buf, "bufhidden", "wipe")
    if not M.config.show_foldcolumn then
        vim.api.nvim_set_option_value("foldcolumn", "0", { win = note_win })
    end
    if not M.config.show_line_numbers then
        vim.api.nvim_set_option_value("number", "0", { win = note_win })
        vim.api.nvim_set_option_value("relativenumber", "0", { win = note_win })
    end
    if M.config.exit_key ~= "" then
        vim.api.nvim_create_autocmd( "BufEnter", {
            group = sticky_group,
            callback = function()
                local ok, is_sticky = pcall(vim.api.nvim_win_get_var, 0, "IsStickyNote")
                if ok and is_sticky then
                    vim.keymap.set("n", M.config.exit_key, "<cmd>wq<CR>", { desc = "Write and quit StickyNote upon " .. M.config.exit_key, buffer = note_buf, nowait = true, noremap = true, silent = false })
                end
            end,
        })
    end
    vim.api.nvim_create_autocmd( "WinClosed", {
        group = sticky_group,
        pattern = tostring(note_win),
        callback = function()
            vim.api.nvim_del_augroup_by_id(sticky_group)
        end
    })
end

-- Open the note for the current file
function M.open_notes(opts)
    opts = opts or {}
    local args = vim.split(opts.args or "", " ", { trimempty = true })
    if args[1] == "global" then
        local note_file_path = check_note_file(M.config.files.global)
        open_float(note_file_path, M.config.files.global)
    elseif args[1] == "manage" then
        open_float(M.notes_cache_dir)
    else
        local cwd = ""
        if M.config.use_cwd then
            cwd = vim.fs.normalize(M.config.files.cwd())
        else
            cwd = vim.fs.normalize(M.config.files.parent())
        end
        local file_name = M.config.files.file_name(cwd)
        local note_file_path = check_note_file(file_name)
        open_float(note_file_path, file_name)
    end
end

-- Setup
function M.setup(opts)
    M.notes_cache_dir = check_cache_dir(M.config.notes_dir)
    if type(opts) ~= "table" then return end

    local function validate(key, expected_type)
        if opts[key] ~= nil and type(opts[key]) ~= expected_type then
            vim.notify("[StickyNotes] Invalid type for " .. key, vim.log.levels.WARN)
            opts[key] = nil
        end
    end

    validate("show_title", "boolean")
    validate("size", "number")
    validate("notes_dir", "string")
    validate("files", "table")
    validate("relative", "string")

    if opts.size and (opts.size <= 0 or opts.size >= 1) then
        opts.size = 0.5
        vim.notify("[StickyNotes] Invalid range for size", vim.log.levels.WARN)
    end

    M.config = vim.tbl_deep_extend("force", M.config, opts)
end

return M
