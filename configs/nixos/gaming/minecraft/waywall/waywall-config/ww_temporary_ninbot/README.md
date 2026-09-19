# Temp Ninbot Plugin

Have Ninjabrain Bot show when you F3+C and hide after a set amount of time.
Uses logic from [Waywall-floating](https://github.com/Esensats/waywall-floating) by Esensats

## Setup
### Using [plug.waywall](https://github.com/its-saanvi/plug.waywall)
```lua
return {
    url = "https://github.com/arjuncgore/ww_temporary_ninbot",
    config = function(config),
        require("temporary_ninbot").setup(config, {
        timer_length = 10
    })
    end,
    name = "temporary_ninbot",
    update_on_load = true,
}
```

### Otherwise
#### Clone plugin to waywall config folder
```bash
git clone https://github.com/arjuncgore/ww_temporary_ninbot ~/.config/waywall/temporary_ninbot
```
#### Setup config in `init.lua`
```lua
-- rest of config
require("temporary_ninbot").setup(config, {
        timer_length = 10
    })
return config
```

Set `timer_length` to 0 to show Ninjabrain Bot without it hiding.
