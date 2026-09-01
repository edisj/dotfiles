local dev = true
local add = dev and pack.add_local or pack.add
local src = dev and "~/dev/quicksys.nvim" or "https://github.com/edisj/quicksys.nvim"
pack.add_local({
  {
    src = src,
    data = {
      enable = true,
    }}
})
