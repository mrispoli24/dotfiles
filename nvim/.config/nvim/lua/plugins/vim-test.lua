return {
  "vim-test/vim-test",
  keys = {
    { "<leader>t", ":TestNearest<CR>", desc = "Test Nearest" },
    { "<leader>T", ":TestFile<CR>", desc = "Test File" },
    { "<leader>a", ":TestSuite<CR>", desc = "Test Suite" },
    { "<leader>l", ":TestLast<CR>", desc = "Test Last" },
    { "<leader>g", ":TestVisit<CR>", desc = "Test Visit" },
  },
}
