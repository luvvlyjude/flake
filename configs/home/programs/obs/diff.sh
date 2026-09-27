#!/usr/bin/env bash
# Show what OBS changed vs this folder's Nix, minus the noise.
#   bash configs/home/programs/obs/diff.sh
#
# "-" is the repo (what the next switch writes), "+" is what OBS saved.
# OBS only saves on File > Exit, and every switch reverts these files,
# so run this after quitting OBS and before switching.
#
# Everything printed is a real change. Jude says which ones to keep; test
# drags and toggles usually aren't. Scene edits go in scenes.nix, INI and
# encoder edits in default.nix.
#
# Hidden from the scene JSON:
#   - ids OBS regenerates: uuid, source_uuid, canvas_uuid, item id, id_counter
#   - bookkeeping: prev_ver, versioned_id (folded into id), hotkeys,
#     private_settings, group_item_backup, show/hide_transition, custom_size
#   - pos_rel/scale_rel/bounds_rel/scale_ref (OBS recomputes them from pos/scale)
#   - DP-2 RestoreToken (the portal rotates it every session)
#   - values equal to OBS defaults (lists in `item` and `src` below);
#     mixers 0/63/255 count as default (no audio, or all tracks)
#   - top-level UI state: groups, modules, resolution, quick_transitions,
#     saved_projectors, and preview zoom while zoom is off
#   - floats are rounded to 4 places (OBS saves float32)
#
# Profile and collection are both OBS's default "Untitled", so their
# Basic.* and General.Name keys are noise. A 2nd profile or collection
# needs those keys back in user.ini, and `profile` / the json path below
# pointed at the right one.
#
# Hidden from the INI files:the lines in `ini_noise` below. These are keys
# the repo leaves out because they equal OBS defaults, matched only at that
# default value, so changing one still shows up. Hidden at any value: the
# window/dock blobs (Jude says when she changed the layout), SimpleOutput
# (unused in Advanced mode), rescale resolutions (unused while rescale is
# off), FPSCommon/Num/Den (unused with integer fps), and the accessibility
# colors (unused unless OverrideColors, which still shows), and
# Panels.CookieId (random, only matters for browser dock logins).
set -euo pipefail

host=luvvly-pc
user=jude
root=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)
live=$HOME/.config/obs-studio
gen=$(nix build --no-link --print-out-paths "$root#nixosConfigurations.$host.config.home-manager.users.$user.home-files" 2>/dev/null)/.config/obs-studio
profile=basic/profiles/Untitled

# Defaults come from InitUserConfigDefaults (frontend/OBSApp.cpp) and
# InitBasicConfigDefaults (frontend/widgets/OBSBasic.cpp); keys with no
# default there read as false/0/"" when missing.
ini_noise='
BasicWindow\.(geometry|DockState)=.*
LogViewer\.geometry=.*
Panels\.CookieId=.*
General\.Pre(19|21|23|24\.1)Defaults=false
General\.(ConfirmOnExit=true|HotkeyFocusType=NeverDisableHotkeys)
BasicWindow\.(PreviewEnabled|SceneDuplicationMode|SwapScenesMode|SnappingEnabled|ScreenSnapping|SourceSnapping|SpacingHelpersEnabled|ShowTransitions|ShowListboxToolbars|ShowStatusBar|ShowSourceIcons|ShowContextToolbars|StudioModeLabels|SideDocks|VerticalVolumeControl|MultiviewMouseSwitch|MultiviewDrawNames|MultiviewDrawAreas|MediaControlsCountdownTimer)=true
BasicWindow\.(PreviewProgramMode|CenterSnapping|RecordWhenStreaming|KeepRecordingWhenStreamStops|SysTrayWhenStarted|SaveProjectors|MixerShowInactive|MixerKeepInactiveLast|MixerShowHidden|MixerKeepHiddenLast|AlwaysOnTop|EditPropertiesMode|WarnBeforeStartingStream|WarnBeforeStoppingStream|WarnBeforeStoppingRecord|VerticalVolControl)=false
BasicWindow\.SnapDistance=10(\.0*)?
Appearance\.FontScale=10
Basic\.(ConfigOnNewProfile=true|(Profile|ProfileDir|SceneCollection)=Untitled|SceneCollectionFile=Untitled(\.json)?)
General\.Name=Untitled
Accessibility\.(Select|Mixer)[A-Za-z]*=.*
Output\.(FilenameFormatting=%CCYY-%MM-%DD %hh-%mm-%ss|DelayEnable=false|DelaySec=20|DelayPreserve=true|Reconnect=true|RetryDelay=2|MaxRetries=25|BindIP=default|IPFamily=IPv4\+IPv6|NewSocketLoopEnable=false|LowLatencyEnable=false)
Stream1\.(EnableMultitrackVideo=false|MultitrackVideoMaximumAggregateBitrateAuto=true|MultitrackVideoMaximumVideoTracksAuto=true)
SimpleOutput\..*
AdvOut\.(ApplyServiceSettings=true|UseRescale=false|RecUseRescale=false|TrackIndex=1|VodTrackIndex=2|RecType=Standard|RecFormat2=hybrid_mp4|FLVTrack=1|StreamMultiTrackAudioMixes=1)
AdvOut\.(AudioEncoder|RecAudioEncoder)=libfdk_aac
AdvOut\.(RescaleRes|RecRescaleRes)=.*
AdvOut\.FF(OutputToFile=true|FilePath=.*|Extension=mp4|VBitrate=6000|VGOPSize=250|UseRescale=false|RescaleRes=.*|IgnoreCompat=false|ABitrate=160|AudioMixes=1)
AdvOut\.FF(Format|FormatMimeType|VEncoder|AEncoder)=
AdvOut\.FF(VEncoderId|AEncoderId)=0
AdvOut\.RecRB(=false|Time=20|Size=512)
AdvOut\.RecSplitFile(Type=Time|Time=15|Size=2048)
Video\.FPS(Common|Num|Den)=.*
Video\.(ScaleType=bicubic|ColorFormat=NV12|ColorSpace=709|ColorRange=Partial|SdrWhiteLevel=300|HdrNominalPeakLevel=1000)
Audio\.(MonitoringDeviceId=default|MonitoringDeviceName=Default|SampleRate=48000|ChannelSetup=Stereo|MeterDecayRate=23\.53|PeakMeterType=0)
'

norm='
def r: walk(if type == "number" then (. * 10000 | round) / 10000 else . end);
def drop($d): with_entries(select(.key as $k | ($d | has($k)) and $d[$k] == .value | not));
def noise: ["uuid", "source_uuid", "prev_ver", "versioned_id", "hotkeys", "private_settings",
  "canvas_uuid", "id_counter", "custom_size", "pos_rel", "scale_rel", "bounds_rel", "scale_ref",
  "group_item_backup", "show_transition", "hide_transition"];
def clean: (if .versioned_id then .id = .versioned_id else . end) | delpaths(noise | map([.]))
  | if (.mixers // 0) as $m | [0, 63, 255] | index($m) then del(.mixers) else . end;
def item: clean | del(.id) | drop({locked: false, rot: 0, align: 5, bounds_type: 0, bounds_align: 0,
  bounds_crop: false, crop_left: 0, crop_top: 0, crop_right: 0, crop_bottom: 0,
  pos: {x: 0, y: 0}, bounds: {x: 0, y: 0}, scale_filter: "disable",
  blend_method: "default", blend_type: "normal"});
def src: clean | del(.settings.id_counter, .settings.custom_size, .settings.RestoreToken)
  | drop({sync: 0, flags: 0, volume: 1, balance: 0.5, enabled: true, muted: false,
    "push-to-mute": false, "push-to-mute-delay": 0, "push-to-talk": false, "push-to-talk-delay": 0,
    deinterlace_mode: 0, deinterlace_field_order: 0, monitoring_type: 0, settings: {}})
  | if .filters then .filters |= (map({key: .name, value: src}) | from_entries) else . end
  | if .settings.items then .settings.items |= (to_entries
      | map({key: .value.name, value: (.value | item) + {order: .key}}) | from_entries) else . end;
r
| (.sources // []) as $s
| del(.sources, .groups, .modules, .resolution, .version, .canvases, .transitions,
      .quick_transitions, .saved_projectors, .name)
| (if .scaling_enabled then . else del(.scaling_level, .scaling_off_x, .scaling_off_y) end)
| drop({preview_locked: false, scaling_enabled: false, transition_duration: 300})
| .sources = ($s | map({key: .name, value: src}) | from_entries)
| paths(type | . != "object" and . != "array") as $p | "\($p | map(tostring) | join(".")) = \(getpath($p) | tojson)"
'

# "[Section]\nKey=value" -> "Section.Key=value", minus ini_noise
flat() { awk '/^\[/ { s = substr($0, 2, length($0) - 2); next } NF { print s "." $0 }' "$1" | grep -vxE -f <(grep . <<<"$ini_noise") | sort; }

json() {
  [[ -e "$live/$1" ]] || { echo "obs $1: missing, switch first"; return; }
  diff --label "repo $1" --label "obs $1" -U0 <(jq -r "$norm" "$gen/$1" | sort) <(jq -r "$norm" "$live/$1" | sort) || true; }
ini() { diff --label "repo $1" --label "obs $1" -U0 <(flat "$gen/$1") <(flat "$live/$1") || true; }

json basic/scenes/Untitled.json
json $profile/recordEncoder.json
json $profile/streamEncoder.json
ini user.ini
ini $profile/basic.ini
