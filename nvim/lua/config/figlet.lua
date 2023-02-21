
-- █▀▀ █ █▀▀ █░░ █▀▀ ▀█▀ 
-- █▀░ █ █▄█ █▄▄ ██▄ ░█░ 

local present, figlet = pcall(require, "figlet")
if not present then return end

figlet.Config {
  font = "carty"
}
