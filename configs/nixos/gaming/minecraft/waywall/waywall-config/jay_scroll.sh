#! /bin/sh

WAYLAND_DISPLAY=wayland-1 jay input device $(WAYLAND_DISPLAY=wayland-1 jay --json input | jq '.seats[].devices[] | select((.name | test("Razer DeathAdder V2 Pro$")) and (.capabilities == ["pointer"])) | .input_device_id') set-px-per-wheel-scroll $1