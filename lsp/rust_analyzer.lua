return {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml" },
	settings = {
		['rust-analyzer'] = {
			diagnostics = {
				enable = false,
			},
			cargo = {
				allFeatures = true,
			},
			inlayHints = {
				bindingModeHints = {
					enable = true
				},
				chainingHints = {
					enable = true
				},
				closingBraceHints = {
					enable = true
				}
			},
			lens = {
				references = {
					adt = {
						enable = true
					}
				}
			}
		}
	},
}
