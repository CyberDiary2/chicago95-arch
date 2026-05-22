#!/usr/bin/env bash
# fix-session.sh -- recover from "unable to load failsafe session" xfce error
# run from a TTY (ctrl+alt+f2) while NOT in an xfce session

set -eo pipefail

log()  { printf '\033[1;32m[+]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }

[[ -n "$DISPLAY" ]] && { warn "xfce session is running -- log out first, then run from TTY"; exit 1; }

XFCE_CONF="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"

# ── reset panel (most common cause of failsafe error) ─────────────────────────
if [[ -f "$XFCE_CONF/xfce4-panel.xml" ]]; then
    cp "$XFCE_CONF/xfce4-panel.xml" "$XFCE_CONF/xfce4-panel.xml.bak"
    rm "$XFCE_CONF/xfce4-panel.xml"
    log "removed broken panel config (backup at xfce4-panel.xml.bak)"
fi

# ── reset xfwm4 theme to built-in default (in case chicago95 isn't installed) ─
if [[ -f "$XFCE_CONF/xfwm4.xml" ]]; then
    cp "$XFCE_CONF/xfwm4.xml" "$XFCE_CONF/xfwm4.xml.bak"
    # replace theme name with Default without removing other settings
    sed -i 's|name="theme" type="string" value="[^"]*"|name="theme" type="string" value="Default"|' \
        "$XFCE_CONF/xfwm4.xml" 2>/dev/null || true
    log "reset xfwm4 theme to Default (backup at xfwm4.xml.bak)"
fi

# ── reset xsettings gtk theme to Adwaita (safe fallback) ──────────────────────
if [[ -f "$XFCE_CONF/xsettings.xml" ]]; then
    cp "$XFCE_CONF/xsettings.xml" "$XFCE_CONF/xsettings.xml.bak"
    sed -i 's|property name="ThemeName".*|property name="ThemeName" type="string" value="Adwaita"/>|' \
        "$XFCE_CONF/xsettings.xml" 2>/dev/null || true
    log "reset gtk theme to Adwaita (backup at xsettings.xml.bak)"
fi

log "done -- log in to XFCE. once inside, run: bash apply-theme.sh"
