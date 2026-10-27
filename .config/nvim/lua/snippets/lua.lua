local ls = require("luasnip") -- Import LuaSnip

-- Define snippets for Lua
ls.add_snippets("lua", {
    -- Snippet for creating a Lua function
    ls.snippet("fn", {
        ls.text_node("function "),
        ls.insert_node(1, "name"), -- Placeholder for function name
        ls.text_node("("),
        ls.insert_node(2, "args"), -- Placeholder for function arguments
        ls.text_node(")"),
        ls.text_node({ "", "    " }),
        ls.insert_node(3, "-- body"), -- Placeholder for function body
        ls.text_node({ "", "end" }),
    }),
})

