
-- █░░ █░█ ▄▀█ █▀ █▄░█ █ █▀█ 
-- █▄▄ █▄█ █▀█ ▄█ █░▀█ █ █▀▀ 

local present, ls = pcall(require, "luasnip")
if not present then return end

-- some shorthands...
local snip = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local func = ls.function_node
local choice = ls.choice_node
local dynamicn = ls.dynamic_node

local date = function() return {os.date('%Y-%m-%d')} end

vim.api.nvim_set_keymap("i", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("s", "<C-n>", "<Plug>luasnip-next-choice", {})
vim.api.nvim_set_keymap("i", "<C-p>", "<Plug>luasnip-prev-choice", {})
vim.api.nvim_set_keymap("s", "<C-p>", "<Plug>luasnip-prev-choice", {})

ls.add_snippets(nil, {
  all = {

    snip({
      trig = "date",
      namr = "Date",
      dscr = "Date in the form of YYYY-MM-DD",
    }, {
      func(date, {}),
    }),

    -- Snippet for defining snippets
    snip({
      trig = "snip",
      name = "Snippet",
      dscr = "i template luasnip snippet",
    }, {
      t({"snip({", ""}),
      t({"  trig = \""}), i(1), t({"\",", ""}),
      t({"  namr = \""}), i(2), t({"\",", ""}),
      t({"  dscr = \""}), i(3), t({"\",", ""}),
      t({"}, {", ""}),
      t({"  ", ""}), i(4),
      t({"}),"}),
    }),


    -- █░█ ▄▀█ █░█ █░░ ▀█▀ 
    -- ▀▄▀ █▀█ █▄█ █▄▄ ░█░ 

    -- Katex display display display display
    snip({
      trig = 'htexdisplay',
      namr = 'Hugo: Katex display',
      dscr = '',
    }, {
        t({"{{< katex display >}}"}),
        i(1),
        t({"{{< /katex >}}"}),
    }),

    snip({
      trig = 'htexinline',
      namr = 'Hugo: Katex inline',
      dscr = '',
    }, {
      t({"{{< katex >}}"}),
      i(1),
      t({"{{< /katex >}}"}),
    }),

    snip({
      trig = 'hhintgreen',
      namr = '',
      dscr = '',
    }, {
      t({"{{< hint info >}}", "**" }),
      i(1),
      t({"**", ""}),
      i(2),
      t({"", "{{< /hint >}}"}),
    }),

    snip({
      trig = 'hhintyellow',
      namr = '',
      dscr = '',
    }, {
      t({"{{< hint warning >}}", "**" }),
      i(1),
      t({"**", ""}),
      i(2),
      t({"", "{{< /hint >}}"}),
    }),

    snip({
      trig = 'hhintred',
      namr = '',
      dscr = '',
    }, {
      t({"{{< hint danger >}}", "**" }),
      i(1),
      t({"**", ""}),
      i(2),
      t({"", "{{< /hint >}}"}),
    }),

    snip({
      trig = 'htab',
      namr = 'Hugo: Tabs',
      dscr = '',
    }, {
      t({"{{< tabs \"", }),
      i(1),
      t({"\" >}}", ""}),
      i(2),
      t({"", "{{< /tabs >}}"}),
    }),

    snip({
      trig = 'htabe',
      namr = '',
      dscr = '',
    }, {
      t({"{{< tab \"", }),
      i(1),
      t({"\" >}}", ""}),
      i(2),
      t({"", "{{< /tab >}}"}),
    }),

    snip({
      trig = "hexp",
      namr = "Hugo: Expand",
      dscr = "",
    }, {
      t({"{{< expand >}}", ""}),
      i(1),
      t({"", "{{< /expand >}}"}),
    }),

    snip({
      trig = "hexpc",
      namr = "Hugo: Expand (custom label)",
      dscr = "",
    }, {
      t({"{{< expand \""}), i(1), t({"\"  \"...\" >}} ", ""}),
      i(2),
      t({"", "{{< /expand >}}"}),
    }),

    snip({
      trig = "hbtnrel",
      namr = "Hugo: Button (relative)",
      dscr = "",
    }, {
      t({"{{< button relref=\"/"}), i(1), t({"\" >}}"}),
      i(2),
      t({"{{< /button >}}"}),
    }),

    snip({
      trig = "hbtnhref",
      namr = "Hugo: Button (ext)",
      dscr = "",
    }, {
      t({"{{< button href=\"/"}), i(1), t({"\" >}}"}),
      i(2),
      t({"{{< /button >}}"}),
    }),

    snip({
      trig = "hcol",
      namr = "Hugo: Columns",
      dscr = "",
    }, {
      t({"{{< columns >}}", ""}),
      i(1),
      t({"", "<--->", ""}),
      i(2),
      t({"", "<--->", ""}),
      i(3),
      t({"", "{{< /columns >}}"}),
    }),

    snip({
      trig = "hmermaid",
      namr = "Hugo: Mermaid",
      dscr = "",
    }, {
      t({"{{< mermaid >}}", ""}),
      i(1),
      t({"", "{{< /mermaid >}}"}),
    }),

    snip({
      trig = "hcode",
      namr = "Hugo: Code block",
      dscr = "",
    }, {
      t({"```", ""}),
      i(1),
      t({"", "```"}),
    }),

  },
})
