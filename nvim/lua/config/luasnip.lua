
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
      trig = "disp",
      namr = "Hugo: Katex (display)",
      dscr = "Write Katex in display block (centered on page)",
    }, {
        t({"{{< katex display >}}", ""}),
        i(1),
        t({"", "{{< /katex >}}"}),
    }),

    snip({
      trig = "inline",
      namr = "Hugo: Katex (inline)",
      dscr = "Write inline Katex",
    }, {
      t({"{{< katex >}}"}),
      i(1),
      t({"{{< /katex >}}"}),
    }),

    snip({
      trig = "hhintgreen",
      namr = "Hugo: Hint (green)",
      dscr = "Create a green hint",
    }, {
      t({"{{< hint info >}}", "**" }),
      i(1),
      t({"**", ""}),
      i(2),
      t({"", "{{< /hint >}}"}),
      i(3),
    }),

    snip({
      trig = "hhintyellow",
      namr = "Hugo: Hint (yellow)",
      dscr = "Create a yellow hint",
    }, {
      t({"{{< hint warning >}}", "**" }),
      i(1),
      t({"**", ""}),
      i(2),
      t({"", "{{< /hint >}}"}),
    }),

    snip({
      trig = "hhintred",
      namr = "Hugo: Hint (red)",
      dscr = "Create a red hint",
    }, {
      t({"{{< hint danger >}}", "**" }),
      i(1),
      t({"**", ""}),
      i(2),
      t({"", "{{< /hint >}}"}),
    }),

    snip({
      trig = "htab",
      namr = "Hugo: Tab container",
      dscr = "Create a new tab container",
    }, {
      t({"{{< tabs \"", }),
      i(1),
      t({"\" >}}", ""}),
      i(2),
      t({"", "{{< /tabs >}}"}),
    }),

    snip({
      trig = "htabe",
      namr = "Hugo: Tab entry",
      dscr = "Create a tab entry",
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
      dscr = "Create an expand",
    }, {
      t({"{{< expand >}}", ""}),
      i(1),
      t({"", "{{< /expand >}}"}),
    }),

    snip({
      trig = "hexpc",
      namr = "Hugo: Expand (custom label)",
      dscr = "Create an expand with a custom label",
    }, {
      t({"{{< expand \""}), i(1), t({"\"  \"...\" >}} ", ""}),
      i(2),
      t({"", "{{< /expand >}}"}),
    }),

    snip({
      trig = "hbtnrel",
      namr = "Hugo: Button (relative)",
      dscr = "Create button with internal link",
    }, {
      t({"{{< button relref=\"/"}), i(1), t({"\" >}}"}),
      i(2),
      t({"{{< /button >}}"}),
    }),

    snip({
      trig = "hbtnhref",
      namr = "Hugo: Button (ext)",
      dscr = "Create button with external link",
    }, {
      t({"{{< button href=\"/"}), i(1), t({"\" >}}"}),
      i(2),
      t({"{{< /button >}}"}),
    }),

    snip({
      trig = "hcol",
      namr = "Hugo: Columns",
      dscr = "Create columns",
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
      dscr = "Insert Mermaid content",
    }, {
      t({"{{< mermaid >}}", ""}),
      i(1),
      t({"", "{{< /mermaid >}}"}),
    }),

    snip({
      trig = "hcode",
      namr = "Hugo: Code block",
      dscr = "Insert code block",
    }, {
      t({"```", ""}),
      i(1),
      t({"", "```"}),
    }),

    snip({
      trig = "meta",
      namr = "Hugo: Metadata",
      dscr = "Add front matter metadata",
    }, {
      t({"---", ""}),
      t({"sum: "}), i(1),
      t({"", "categories: ", "- "}), i(2),
      t({"", "---"}),
      t({"", "", "# "}), i(3)
    }),

    snip({
      trig = "hlink",
      namr = "Hugo: Markdown link",
      dscr = "Insert Markdown link",
    }, {
      t("["), i(1), t("]("), i(2), t(")")
    }),

    snip({
      trig = "frac",
      namr = "Hugo: KaTex fraction",
      dscr = "Fraction",
    }, {
      t("\\frac{"), i(1), t("}{"), i(2), t("}")
    }),

    snip({
      trig = "center",
      namr = "Hugo: Center",
      dscr = "Center something in markdown/html",
    }, {
        t({"<div class=\"flex justify-center\">", ""}),
        i(1),
        t({"", "</div>"})
    }),

    snip({
      trig = "include",
      namr = "Hugo: Include",
      dscr = "",
    }, {
        t("{{% include '"), i(1), t("' %}}"),
    }),

    -- ▄▀█ █░█░█ █▀▀ █▀ █▀█ █▀▄▀█ █▀▀ 
    -- █▀█ ▀▄▀▄▀ ██▄ ▄█ █▄█ █░▀░█ ██▄ 

    snip({
      trig = "wi",
      namr = "wibox widget",
      dscr = "",
    }, {
      t({"wibox.widget({", "  "}), i(1), t({"", "})"}),
    }),

    snip({
      trig = "awreq",
      namr = "",
      dscr = "",
    }, {
      t({"local beautiful  = require(\"beautiful\")", ""}),
      t({"local xresources = require(\"beautiful.xresources\")", ""}),
      t({"local dpi   = xresources.apply_dpi", ""}),
      t({"local awful = require(\"awful\")", ""}),
      t({"local wibox = require(\"wibox\")", ""}),
      t({"local ui    = require(\"helpers.ui\")", ""}),
      i(1),
    }),

    snip({
      trig = "awspawn",
      namr = "",
      dscr = "",
    }, {
      t({"awful.spawn.easy_async_with_shell(cmd, function()", "  "}),
      i(1),
      t({"", "end)"}),
    }),

    snip({
      trig = "lhoriz",
      namr = "",
      dscr = "",
    }, {
      t({"layout = wibox.layout.fixed.horizontal,"})
    }),

    snip({
      trig = "lvert",
      namr = "",
      dscr = "",
    }, {
      t({"layout = wibox.layout.fixed.vertical,"})
    }),

    snip({
      trig = "witext",
      namr = "",
      dscr = "",
    }, {
      t"font   = beautiful.font_reg_s", i(1), t({",", ""}),
      t"markup = ui.colorize_text(", i(2), t({"),", ""}),
      t({"align  = \"center\",", ""}),
      t({"widget = wibox.widget.textbox,"}),
    }),

    snip({
      trig = "reqhere",
      namr = "",
      dscr = "",
    }, {
      t("require(... .. \"."), i(1), t({ "\")", ""}),
    }),

    snip({
      trig = "print",
      namr = "",
      dscr = "",
    }, {
      t("print("), i(1), t")"
    }),

    snip({
      trig = "align",
      namr = "Alignment",
      dscr = "Katex equation alignment",
    }, {
      t({"\\begin{aligned}", "",}), i(1),
      t({"", "\\end{aligned}"}), i(2),
    }),

    snip({
      trig = "defhint",
      namr = "Katex hints",
      dscr = "For hints that use inline katex",
    }, {
      t({"<blockquote class='book-hint warning'>", "<h4>"}), i(1),
      t({"</h4>", "", "</blockquote>"}), i(2),
    }),

    snip({
      trig = "thetahat",
      namr = "Katex: Theta hat",
      dscr = "theta with a lil hat",
    }, {
      t({"\\hat{\\theta}"})
    }),

    snip({
      trig = "nsum",
      namr = "Katex: n sum",
      dscr = "summation to n from i = 1",
    }, {
      t("\\sum_{i=1}^n")
    }),

    snip({
      trig = "theta",
      namr = "Katex: just theta",
      dscr = "just theta",
    }, {
      t("{{< katex >}}\\theta{{< /katex >}}")
    }),

    snip({
      trig = "img",
      namr = "Hugo image",
      dscr = "image",
    }, {
      t("![<img: "), i(1), t(">]("), i(2), t(")")
    }),

    snip({
      trig = "idx",
      namr = "Index frontmatter",
      dscr = "Frontmatter for Hugo index pages",
    }, {
      t({
        "---",
        "bookSearchExclude: true",
        "bookHidden: true",
        "categories:",
        "cascade:",
        "  categories:",
        "    - ",
        }), i(1),
      t({"", "---"})
    }),
  },
})
