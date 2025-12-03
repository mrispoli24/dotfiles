return {
	"folke/snacks.nvim",
	opts = {
		scroll = {
			enabled = false, -- Disable scrolling animations
		},
		picker = {
			sources = {
				files = {
					hidden = true,
					ignored = true,
				},
				grep = {
					hidden = true,
					ignored = true,
				},
			},
		},
	},
}
