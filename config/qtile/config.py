import os
import subprocess
from collections.abc import Callable

import libqtile.resources
from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Output, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

mod = "mod4"
terminal = "kitty"

# --- FUNKCJE POMOCNICZE ---
@lazy.function
def toggle_show_desktop(qtile):
    has_visible = any(not win.minimized for win in qtile.current_group.windows)
    for win in qtile.current_group.windows:
        if win.minimized != has_visible:
            win.toggle_minimize()

keys = [
    # Switch between windows (Focus)
    Key([mod], "Left", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "Right", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "Down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "Up", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    
    # Move windows between left/right columns or move up/down in current stack
    Key([mod, "shift"], "Left", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "Right", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up(), desc="Move window up"),
    
    # Grow windows
    Key([mod, "control"], "Left", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "Right", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "Down", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "Up", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    
    # Toggle split
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key(
        [mod],
        "f",
        lazy.window.toggle_fullscreen(),
        desc="Toggle fullscreen on the focused window",
    ),
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating on the focused window"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "m", lazy.spawn('jgmenu --config-file=' + os.path.expanduser('~/.config/jgmenu/dock.rc')), desc="Otwórz menu XFCE"),
    Key([mod, "control"], "d", toggle_show_desktop, desc="Pokaż/Ukryj pulpit"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),

    # Skróty klawiszowe dla nowych aplikacji
    Key([mod, "shift"], "c", lazy.spawn("code"), desc="Uruchom VS Code"),
    Key([mod, "shift"], "o", lazy.spawn("libreoffice"), desc="Uruchom LibreOffice"),
    Key([mod, "shift"], "v", lazy.spawn("vlc"), desc="Uruchom VLC"),
]

for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )

# PULPITY (ZACHOWANO 1-4)
groups = [Group(i) for i in "1234"]

for i in groups:
    keys.extend(
        [
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
        ]
    )

layouts = [
    layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=4),
    layout.Max(),
]

widget_defaults = dict(
    font="sans",
    fontsize=14,
    padding=4,
)
extension_defaults = widget_defaults.copy()

logo = os.path.join(os.path.dirname(__file__), "wallpapers", "miedzyzdroje.jpg")

screens = [
    Screen(
        top=bar.Bar(
            [
                # --- PRZYCISK MENU (JGMENU) ---
                widget.TextBox(
                    text="󰍜 Menu", 
                    font="JetBrainsMono Nerd Font",
                    fontsize=16,
                    foreground="#89b4fa",
                    mouse_callbacks={'Button1': lazy.spawn('jgmenu --config-file=' + os.path.expanduser('~/.config/jgmenu/dock.rc'))},
                    padding=8,
                ),
                widget.Sep(linewidth=1, padding=8, foreground="#45475a"),
                widget.Spacer(length=10),

                # --- IKONY SZYBKIEGO URUCHAMIANIA ---
                widget.TextBox(
                    text="󰈹", 
                    font="JetBrainsMono Nerd Font",
                    fontsize=20,
                    foreground="#5865F2",
                    mouse_callbacks={'Button1': lazy.spawn('librewolf')},
                    padding=6,
                ),
                widget.TextBox(
                    text="󰇮", 
                    font="JetBrainsMono Nerd Font",
                    fontsize=20,
                    foreground="#35BFDE",
                    mouse_callbacks={'Button1': lazy.spawn('thunderbird')},
                    padding=6,
                ),
                widget.TextBox(
                    text="󰉋", 
                    font="JetBrainsMono Nerd Font",
                    fontsize=20,
                    foreground="#F1FA8C",
                    mouse_callbacks={'Button1': lazy.spawn('thunar')},
                    padding=6,
                ),
                widget.TextBox(
                    text="󰨞", 
                    font="JetBrainsMono Nerd Font",
                    fontsize=20,
                    foreground="#007ACC",
                    mouse_callbacks={'Button1': lazy.spawn('code')},
                    padding=6,
                ),
                widget.TextBox(
                    text="󰏆", 
                    font="JetBrainsMono Nerd Font",
                    fontsize=20,
                    foreground="#18A303",
                    mouse_callbacks={'Button1': lazy.spawn('libreoffice')},
                    padding=6,
                ),
                widget.TextBox(
                    text="󰕼", 
                    font="JetBrainsMono Nerd Font",
                    fontsize=20,
                    foreground="#FF8800",
                    mouse_callbacks={'Button1': lazy.spawn('vlc')},
                    padding=6,
                ),

                widget.Sep(linewidth=1, padding=10, foreground="#45475a"),

                # --- PULPITY (1-4) ---
                widget.GroupBox(
                    highlight_method='line',
                    active='#cdd6f4',
                    inactive='#6c7086',
                    highlight_color=['#1e1e2e', '#313244'],
                    this_current_screen_border='#89b4fa',
                    margin_x=0,
                    padding_x=6,
                ),

                widget.Sep(linewidth=1, padding=10, foreground="#45475a"),
                widget.Prompt(),

                # --- TYTUŁ AKTYWNEGO OKNA ---
                widget.WindowName(foreground="#cdd6f4"),

                # --- PRAWA STRONA PASKA ---
                widget.KeyboardLayout(configured_keyboards=['pl'], foreground="#89b4fa"),
                widget.Sep(linewidth=1, padding=10, foreground="#45475a"),

                # Zasobnik dla apletów (sieć, dźwięk, bluetooth, zasilanie)
                widget.Systray(padding=6, icon_size=18),
                widget.Sep(linewidth=1, padding=10, foreground="#45475a"),
                
                widget.Clock(format="%Y-%m-%d %a %H:%M", foreground="#a6e3a1"),
                widget.Spacer(length=10),
                widget.QuickExit(
                    default_text='󰐥',
                    command='systemctl poweroff',
                    foreground="#f38ba8",
                ),
            ],
            30,
            background="#1e1e2e",
        ),
        background="#000000",
        wallpaper=logo,
        wallpaper_mode="center",
    ),
]

fake_screens: list[Screen] | None = None
generate_screens: Callable[[list[Output]], list[Screen]] | None = None

# Obsługa myszy (Mod + LewyKlik: przesuwanie, Mod + PrawyKlik: zmiana rozmiaru)
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
focus_previous_on_window_remove = False
reconfigure_screens = True
screen_change_debounce_timeout = 1
auto_minimize = True
wl_input_rules = None
wl_xcursor_theme = None
wl_xcursor_size = 24
idle_timers = []
idle_inhibitors = []

wmname = "LG3D"

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    if os.path.exists(home):
        subprocess.Popen([home])
