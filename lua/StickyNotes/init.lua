local M = {}

-- Default configuration
M.config = {
    show_title = true,
    notes_dir = vim.fn.stdpath("cache") .. "/StickyNotes",
    files = {
        global = "StickyNotes_Global.md",
        cwd = function()
            return vim.fn.getcwd()
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
        local success = vim.uv.fs_mkdir(notes_cache_dir, tonumber("666", 8))
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
        vim.uv.fs_open(note_file_path, "w", tonumber("666", 8), function(err, fd)
            if err ~= nil or fd == nil then
                vim.notify("[StickyNotes] Could not create note file " .. note_file_path, vim.log.levels.ERROR)
                return
            end
            vim.uv.fs_close(fd)
        end)
    end
    return note_file_path
end

local function open_float(file_path, file_name)
    local curr_win = vim.api.nvim_get_current_win()
    local win_width = vim.api.nvim_win_get_width(curr_win)
    local win_height = vim.api.nvim_win_get_height(curr_win)
    local width = math.floor((win_width * M.config.size) + (1 - M.config.size))
    local height = math.floor((win_height * M.config.size) + (1 - M.config.size))
    local note_buf = vim.api.nvim_create_buf(false, true)

    local win_opts = {
        relative = "editor",
        width = width,
        height = height,
        col = (win_width - width) / 2,
        row = (win_height - height) / 2,
        focusable = false,
        style = M.config.window_style,
        border = M.config.window_border
    }

    if M.config.show_title then
        win_opts.title = file_name
    end

    -- Open window
    vim.api.nvim_open_win(note_buf, true, win_opts)

    -- Open correct file in buffer
    vim.cmd("edit " .. file_path)
    vim.api.nvim_buf_set_option(note_buf, "bufhidden", "wipe")
end

function M.open_notes(opts)
    if opts.fargs[1] == "global" then
        local note_file_path = check_note_file(M.config.files.global)
        open_float(note_file_path, M.config.files.global)
    elseif opts.fargs[1] == "manage" then
        open_float(M.notes_cache_dir)
    else
        local cwd = vim.fs.normalize(M.config.files.cwd())
        local file_name = M.config.files.file_name(cwd)
        local note_file_path = check_note_file(file_name)
        open_float(note_file_path, file_name)
    end
end

function M.setup(opts)
    if type(opts) ~= "table" then return end

    local function validate(key, expected_type)
        if opts[key] ~= nil and type(opts[key]) ~= expected_type then
            vim.notify("[StickyNotes] Invalid type for " .. key, vim.log.levels.WARN)
            opts[key] = nil
        end
    end

    validate("option", "boolean")

    M.config = vim.tbl_deep_extend("force", M.config, opts)
    M.notes_cache_dir = check_cache_dir(M.config.notes_dir)
end

return M
