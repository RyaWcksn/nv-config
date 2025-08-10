return {
	cmd = { "tailwindcss-language-server", "--stdio" },
	filetypes = { "templ", "astro", "typescript", "react", "html", "htmldjango", "typescriptreact", "javascript", "javascriptreact" },
	root_markers = {
		-- Generic
		'tailwind.config.js',
		'tailwind.config.cjs',
		'tailwind.config.mjs',
		'tailwind.config.ts',
		'postcss.config.js',
		'postcss.config.cjs',
		'postcss.config.mjs',
		'postcss.config.ts',
		-- Django
		'theme/static_src/tailwind.config.js',
		'theme/static_src/tailwind.config.cjs',
		'theme/static_src/tailwind.config.mjs',
		'theme/static_src/tailwind.config.ts',
		'theme/static_src/postcss.config.js',
	},
	settings = {
		tailwindCSS = {
			classAttributes = { "class", "className", "class:list", "classList", "ngClass" },
			includeLanguages = {
				eelixir = "html-eex",
				elixir = "phoenix-heex",
				eruby = "erb",
				heex = "phoenix-heex",
				htmlangular = "html",
				templ = "html"
			},
			lint = {
				cssConflict = "warning",
				invalidApply = "error",
				invalidConfigPath = "error",
				invalidScreen = "error",
				invalidTailwindDirective = "error",
				invalidVariant = "error",
				recommendedVariantOrder = "warning"
			},
			validate = true,
		},
	},
}
