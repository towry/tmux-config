local set = vim.keymap.set

set({ 'n' }, '<localleader>m', function()
  vim.cmd('Make!')
end, {
  desc = 'Run make',
})
