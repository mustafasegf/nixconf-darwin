-- flash.nvim
require("flash").setup({
	labels = "asdfghjklqwertyuiopzxcvbnm",
	search = {
		multi_window = true,
		forward = true,
		wrap = true,
		mode = "exact",
	},
	jump = {
		jumplist = true,
		pos = "start",
		history = false,
		register = false,
		nohlsearch = false,
		autojump = false,
	},
	label = {
		uppercase = true,
		rainbow = {
			enabled = false,
			shade = 5,
		},
	},
	modes = {
		search = {
			enabled = true,
		},
		char = {
			enabled = true,
			keys = { "f", "F", "t", "T", ";", "," },
			search = { wrap = false },
			highlight = { backdrop = true },
			jump = { register = false },
		},
	},
})

-- Keymaps
vim.keymap.set({ "n", "x", "o" }, "s", function()
	require("flash").jump()
end, { desc = "Flash" })

vim.keymap.set({ "n", "x", "o" }, "S", function()
	require("flash").treesitter()
end, { desc = "Flash Treesitter" })

vim.keymap.set("o", "r", function()
	require("flash").remote()
end, { desc = "Remote Flash" })

vim.keymap.set({ "o", "x" }, "R", function()
	require("flash").treesitter_search()
end, { desc = "Treesitter Search" })
