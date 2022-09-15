local config = require("smoothcursor.default")

local uv = vim.loop
local cursor_timer = uv.new_timer()

local function replace_sign(position)
    local file = vim.fn.expand("%:p")
    vim.cmd(string.format("silent! sign unplace %d file=%s",
        config.default_args.cursorID,
        file))
    vim.cmd(string.format("silent! sign place %d line=%d name=smoothcursor priority=%d file=%s",
        config.default_args.cursorID,
        position,
        config.default_args.priority,
        file))
end

local function smoothcursor()
    -- 前のカーソルの位置が存在しないなら、現在の位置にする
    if vim.b.cursor_row_prev == nil then
        vim.b.cursor_row_prev = vim.fn.getcurpos(vim.fn.win_getid())[2]
    end
    vim.b.cursor_row_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
    vim.b.diff = vim.b.cursor_row_prev - vim.b.cursor_row_now
    if math.abs(vim.b.diff) > 3 then -- たくさんジャンプしたら
        -- 動いているタイマーがあればストップする
        cursor_timer:stop()
        local counter = 1
        -- タイマーをスタートする
        uv.timer_start(cursor_timer, 0, config.default_args.intervals, vim.schedule_wrap(
            function()
                vim.b.cursor_row_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
                vim.b.diff = vim.b.cursor_row_prev - vim.b.cursor_row_now
                vim.b.cursor_row_prev = vim.b.cursor_row_prev
                    - (
                    (vim.b.diff > 0)
                        and math.ceil(vim.b.diff / 100 * config.default_args.speed)
                        or math.floor(vim.b.diff / 100 * config.default_args.speed)
                    )
                replace_sign(vim.b.cursor_row_prev)
                counter = counter + 1
                if counter > (config.default_args.timeout / config.default_args.intervals) or vim.b.diff == 0 then
                    cursor_timer:stop()
                end
            end)
        )
    else
        vim.b.cursor_row_prev = vim.b.cursor_row_now
        replace_sign(vim.b.cursor_row_prev)
    end
end

local function sc_exp()
    -- 前のカーソルの位置が存在しないなら、現在の位置にする
    if vim.b.cursor_row_prev == nil then
        vim.b.cursor_row_prev = vim.fn.getcurpos(vim.fn.win_getid())[2]
    end
    vim.b.cursor_row_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
    vim.b.diff = vim.b.cursor_row_prev - vim.b.cursor_row_now
    if math.abs(vim.b.diff) > 1 then -- たくさんジャンプしたら
        -- 動いているタイマーがあればストップする
        cursor_timer:stop()
        local counter = 1
        -- タイマーをスタートする
        uv.timer_start(cursor_timer, 0, config.default_args.intervals, vim.schedule_wrap(
            function()
                vim.b.cursor_row_now = vim.fn.getcurpos(vim.fn.win_getid())[2]
                vim.b.diff = vim.b.cursor_row_prev - vim.b.cursor_row_now
                vim.b.cursor_row_prev = vim.b.cursor_row_prev
                    - vim.b.diff / 100 * config.default_args.speed
                if math.abs(vim.b.diff) < 0.5 then
                    vim.b.cursor_row_prev = vim.b.cursor_row_now
                end
                replace_sign(
                    (vim.b.diff > 0)
                    and math.ceil(vim.b.cursor_row_prev)
                    or math.floor(vim.b.cursor_row_prev)
                )
                counter = counter + 1
                if counter > (config.default_args.timeout / config.default_args.intervals) or vim.b.diff == 0 then
                    cursor_timer:stop()
                end
            end)
        )
    else
        vim.b.cursor_row_prev = vim.b.cursor_row_now
        replace_sign(vim.b.cursor_row_prev)
    end
end

return {
    sc_callback_classic = smoothcursor,
    sc_callback_exp = sc_exp,
}
