-- auto-session
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

require("auto-session").setup({
	log_level = "info",
	auto_session_suppress_dirs = { "~/", "~/projects" },
})
