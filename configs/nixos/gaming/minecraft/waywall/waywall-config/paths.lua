local P = {}

P.home = os.getenv("HOME") .. "/"
-- custom nix package for ninjabrain bot instead
-- P.nbb = P.home .. "mcsr/random/Ninjabrain-Bot-1.5.2.jar"
P.nbb = "ninjabrain-bot"
P.nbb_img = "/tmp/nb-overlay.png"
P.overlay = P.home .. ".config/waywall/measuring_overlay.png"
P.latest_world = P.home .. "speedrunigt/latest_world.json"

return P
