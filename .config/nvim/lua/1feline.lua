
require('feline')
local vi_mode = require('feline.providers.vi_mode')

-- 1. Define constants
local LEFT = 1
local RIGHT = 2

local MODE_COLORS = {
  ['NORMAL'] = 'green',
  ['COMMAND'] = 'skyblue',
  ['INSERT'] = 'orange',
  ['REPLACE'] = 'red',
  ['LINES'] = 'violet',
  ['VISUAL'] = 'violet',
  ['OP'] = 'yellow',
  ['BLOCK'] = 'yellow',
  ['V-REPLACE'] = 'yellow',
  ['ENTER'] = 'yellow',
  ['MORE'] = 'yellow',
  ['SELECT'] = 'yellow',
  ['SHELL'] = 'yellow',
  ['TERM'] = 'yellow',
  ['NONE'] = 'yellow',
}

local GRUVBOX = {
  fg = '#ebdbb2',
  bg = '#3c3836',
  black = '#3c3836',
  skyblue = '#83a598',
  cyan = '#8e07c',
  green = '#b8bb26',
  oceanblue = '#076678',
  blue = '#458588',
  magenta = '#d3869b',
  orange = '#d65d0e',
  red = '#fb4934',
  violet = '#b16286',
  white = '#ebdbb2',
  yellow = '#fabd2f',
}

-- 2. Setup helpers
function get_filename()
  local filename = vim.api.nvim_buf_get_name(0)
  if filename == '' then
    filename = '[no name]'
  end
  return vim.fn.fnamemodify(filename, ':~:.')
end

function get_filetype()
  local filetype = vim.bo.filetype
  if filetype == '' then
    filetype = '[no type]'
  end
  return filetype:lower()
end

function get_line_cursor()
  local cursor_line, _ = unpack(vim.api.nvim_win_get_cursor(0))
  return cursor_line
end

function get_line_total()
  return vim.api.nvim_buf_line_count(0)
end

function wrap(string)
  return ' ' .. string .. ' '
end

function wrap_left(string)
  return ' ' .. string .. ' '
end

function wrap_right(string)
  return ' ' .. string .. ' '
end

function wrapped_provider(provider, wrapper)
  return function(component, opts)
    return wrapper(provider(component, opts))
  end
end

-- 3. Setup custom providers
function provide_mode(component, opts)
  return vi_mode.get_vim_mode()
end

function provide_filename(component, opts)
  return get_filename()
end

function provide_linenumber(component, opts)
  return get_line_cursor() .. '/' .. get_line_total()
end

function provide_filetype(component, opts)
  return get_filetype()
end

-- 4. Build the components
local components = {
  active = {
    {}, -- left section
    {}, -- right section
  },
  inactive = {
    {}, -- left section
    {}, -- right section
  },
}

-- Insert the mode component
table.insert(components.active[LEFT], {
  name = 'mode',
  provider = wrapped_provider(provide_mode, wrap),
  right_sep = 'slant_right',
  hl = function()
    return {
      fg = 'black',
      bg = vi_mode.get_mode_color(),
    }
  end,
})

-- Insert the filename component
table.insert(components.active[LEFT], {
  name = 'filename',
  provider = wrapped_provider(provide_filename, wrap_left),
  right_sep = 'slant_right',
  hl = {
    bg = 'white',
    fg = 'black',
  },
})

-- Insert the filetype component
table.insert(components.active[RIGHT], {
  name = 'filetype',
  provider = wrapped_provider(provide_filetype, wrap_right),
  left_sep = 'slant_left',
  hl = {
    bg = 'white',
    fg = 'black',
  },
})

-- Insert the linenumber component
table.insert(components.active[RIGHT], {
  name = 'linenumber',
  provider = wrapped_provider(provide_linenumber, wrap),
  left_sep = 'slant_left',
  hl = {
    bg = 'skyblue',
    fg = 'black',
  },
})

-- Insert the inactive filename component
table.insert(components.inactive[LEFT], {
  name = 'filename_inactive',
  provider = wrapped_provider(provide_filename, wrap),
  right_sep = 'slant_right',
  hl = {
    fg = 'white',
    bg = 'bg',
  },
})

-- 5. Run the feline setup
feline.setup({
  theme = GRUVBOX,
  components = components,
  vi_mode_colors = MODE_COLORS,
})
