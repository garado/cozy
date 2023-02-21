
-- █▄░█ █░█ █ █▀▄▀█    █▀▀ █▀█ █░░ █▀█ █▀█ █ ▀█ █▀▀ █▀█ 
-- █░▀█ ▀▄▀ █ █░▀░█    █▄▄ █▄█ █▄▄ █▄█ █▀▄ █ █▄ ██▄ █▀▄ 

local present, colorizer = pcall(require, "nvim-colorizer")
if not present then return end

colorizer.setup = {
  '*'
}
