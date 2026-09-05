import os
import subprocess
from collections.abc import Callable

import libqtile.resources
from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Output, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
import colors

mod = "mod4"
terminal = "xfce4-terminal"

# --- ZARZĄDZANIE STANEM MOTYWU ---
THEME_FILE = os.path.expanduser("~/.config/qtile/current_theme.txt")

def get_saved_theme_name():
    if os.path.exists(THEME_FILE):
        try:
            with open(THEME_FILE, "r") as f:
                theme_name = f.read().strip()
                if theme_name in ["dark", "light"]:
                    return theme_name
        except Exception:
            pass
    return "dark"

def set_saved_theme_name(theme_name):
    try:
        os.makedirs(os.path.dirname(THEME_FILE), exist_ok=True)
        with open(THEME_FILE, "w") as f:
            f.write(theme_name)
    except Exception:
        pass

# Wczytanie zapisanego motywu przy starcie
current_theme_name = get_saved_theme_name()
current_theme = colors.light if current_theme_name == "light" else colors.dark

# --- FUNKCJE POMOCNICZE ---
@lazy.function
def toggle_show_desktop(qtile):
    has_visible = any(not win.minimized for win in qtile.current_group.windows)
    for win in qtile.current_group.windows:
        if win.minimized != has_visible:
            win.toggle_minimize()

# Funkcja przełączająca motywy dwukierunkowo
def toggle_theme(qtile):
    global current_theme_name
    
    # 1. Określenie docelowych kolorów
    if current_theme_name == "dark":
        current_theme_name = "light"
        t = colors.light
        scheme = "prefer-light"
        gtk_theme = "Adwaita"
        jgmenu_bg = colors.light["bg"]
        jgmenu_fg = colors.light["fg"]
        jgmenu_sel_fg = "#ffffff"
    else:
        current_theme_name = "dark"
        t = colors.dark
        scheme = "prefer-dark"
        gtk_theme = "Adwaita-dark"
        jgmenu_bg = colors.dark["bg"]
        jgmenu_fg = colors.dark["fg"]
        jgmenu_sel_fg = colors.dark["bg"]

    set_saved_theme_name(current_theme_name)

    # 2. Przełączenie motywu systemowego (GTK / GNOME / Firefox)
    try:
        subprocess.Popen(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", scheme])
        subprocess.Popen(["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", gtk_theme])
        
        # Wymuszenie stałego, żywego zestawu ikon (zapobiega ich blaknięciu przy jasnym motywie)
        subprocess.Popen(["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", "Adwaita"])
    except Exception:
        pass
    except Exception:
        pass

    # 3. Aktualizacja pliku konfiguracyjnego jgmenu (dock.rc)
    jgmenu_conf_path = os.path.expanduser('~/.config/jgmenu/dock.rc')
    if os.path.exists(jgmenu_conf_path):
        try:
            with open(jgmenu_conf_path, "r") as f:
                lines = f.readlines()
            
            new_lines = []
            for line in lines:
                if line.startswith("color_menu_bg"):
                    new_lines.append(f"color_menu_bg = {jgmenu_bg} 100\n")
                elif line.startswith("color_norm_fg"):
                    new_lines.append(f"color_norm_fg = {jgmenu_fg} 100\n")
                elif line.startswith("color_sel_bg"):
                    new_lines.append(f"color_sel_bg = {t['active']} 100\n")
                elif line.startswith("color_sel_fg"):
                    new_lines.append(f"color_sel_fg = {jgmenu_sel_fg} 100\n")
                else:
                    new_lines.append(line)
                    
            with open(jgmenu_conf_path, "w") as f:
                f.writelines(new_lines)
        except Exception:
            pass

    # 4. Aktualizacja obiektów widżetów na żywo dla KAŻDEGO ekranu
    for screen in qtile.screens:
        if hasattr(screen, "top") and screen.top:
            bar_obj = screen.top
            bar_obj.background = t["bg"]
            
            for w in bar_obj.widgets:
                # Dedykowane tło dla Systraya w trybie jasnym, zapewniające widoczność ikon
                if isinstance(w, widget.Systray):
                    w.background = "#2e3440" if current_theme_name == "light" else t["bg"]
                else:
                    w.background = t["bg"]
                
                # Przypisanie i odświeżenie właściwości konkretnych typów widżetów
                if isinstance(w, widget.GroupBox):
                    w.active = t["active"]
                    w.inactive = t["inactive"]
                    w.highlight_color = [t["bg"], t["bg"]]
                    w.this_current_screen_border = t["active"]
                    w.this_screen_border = t["active"]
                elif isinstance(w, widget.TextBox):
                    if w.text == "󰍜 Menu":
                        w.foreground = t["active"]
                    elif w.text in ["󰂄", "󰐥"]:
                        w.foreground = t["fg_icon"]
                elif isinstance(w, widget.Clock):
                    w.foreground = t["fg"]
                    # Wymuszenie pełnej rekonfiguracji układu tekstowego
                    if hasattr(w, "layout") and w.layout:
                        w.layout.colour = t["fg"]
                elif isinstance(w, widget.Prompt):
                    w.foreground = t["fg"]
                elif isinstance(w, (widget.KeyboardLayout, widget.QuickExit)):
                    w.foreground = t["fg_icon"]
                elif isinstance(w, widget.Sep):
                    w.foreground = t["inactive"]
                
                # Przerysowanie pojedynczego widżetu
                w.draw()

            # Odświeżenie płótna paska
            bar_obj.draw()

    # 5. Aktualizacja ramki w aktywnym układzie okien
    for layout_item in qtile.current_group.layouts:
        if hasattr(layout_item, "border_focus"):
            layout_item.border_focus = t["active"]
        if hasattr(layout_item, "border_normal"):
            layout_item.border_normal = t["inactive"]
    qtile.current_group.layout_all()


keys = [
    # Switch between windows (Focus)
    Key([mod], "Left", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "Right", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "Down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "Up", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    
    # Przełączanie fokusu / kursora między monitorami
    Key([mod], "w", lazy.next_screen(), desc="Przejdź na kolejny monitor"),
    Key([mod], "e", lazy.prev_screen(), desc="Przejdź na poprzedni monitor"),

    # Move windows between left/right columns or move up/down in current stack
    Key([mod, "shift"], "Left", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "Right", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up(), desc="Move window up"),

    # Przenoszenie okien bezpośrednio na inny monitor
    Key([mod, "control", "shift"], "Left", lazy.window.toscreen(0), desc="Przenieś okno na 1. monitor (LVDS-1)"),
    Key([mod, "control", "shift"], "Right", lazy.window.toscreen(1), desc="Przenieś okno na 2. monitor (VGA-1)"),

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

    # Skróty klawiszowe dla aplikacji
    Key([mod, "shift"], "c", lazy.spawn("code"), desc="Uruchom VS Code"),
    Key([mod, "shift"], "o", lazy.spawn("libreoffice"), desc="Uruchom LibreOffice"),
    Key([mod, "shift"], "v", lazy.spawn("vlc"), desc="Uruchom VLC"),
    Key([mod, "shift"], "t", lazy.function(toggle_theme), desc="Przełącz motyw"),
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

# PULPITY (1-4)
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
    layout.Columns(
        border_focus=current_theme["active"],
        border_normal=current_theme["inactive"],
        border_width=3
    ),
    layout.Max(),
]

widget_defaults = dict(
    font="sans",
    fontsize=14,
    padding=4,
)
extension_defaults = widget_defaults.copy()

logo = os.path.join(os.path.dirname(__file__), "wallpapers", "miedzyzdroje.jpg")

# --- GENEROWANIE PASKA DLA POSZCZEGÓLNYCH MONITORÓW ---
def create_bar(is_primary=True):
    # Początkowe tło dla systraya przy uruchamianiu
    systray_bg = "#2e3440" if current_theme_name == "light" else current_theme["bg"]

    widgets = [
        # --- PRZYCISK MENU (JGMENU) ---
        widget.TextBox(
            text="󰍜 Menu", 
            font="JetBrainsMono Nerd Font",
            fontsize=16,
            foreground=current_theme["active"],
            mouse_callbacks={'Button1': lazy.spawn('jgmenu --config-file=' + os.path.expanduser('~/.config/jgmenu/dock.rc'))},
            padding=8,
            background=current_theme["bg"]
        ),
        widget.Sep(linewidth=1, padding=8, foreground=current_theme["inactive"], background=current_theme["bg"]),
        widget.Spacer(length=6, background=current_theme["bg"]),

        # --- IKONY SZYBKIEGO URUCHAMIANIA (PODSTAWOWE) ---
        widget.TextBox(text="󰈹", font="JetBrainsMono Nerd Font", fontsize=18, foreground=current_theme["blue"], background=current_theme["bg"], mouse_callbacks={'Button1': lazy.spawn('librewolf')}, padding=4),
        widget.TextBox(text="󰇮", font="JetBrainsMono Nerd Font", fontsize=18, foreground="#35BFDE", background=current_theme["bg"], mouse_callbacks={'Button1': lazy.spawn('thunderbird')}, padding=4),
        widget.TextBox(text="󰉋", font="JetBrainsMono Nerd Font", fontsize=18, foreground="#F1FA8C", background=current_theme["bg"], mouse_callbacks={'Button1': lazy.spawn('thunar')}, padding=4),
        widget.TextBox(text="󰨞", font="JetBrainsMono Nerd Font", fontsize=18, foreground="#007ACC", background=current_theme["bg"], mouse_callbacks={'Button1': lazy.spawn('code')}, padding=4),
        widget.TextBox(text="󰏆", font="JetBrainsMono Nerd Font", fontsize=18, foreground=current_theme["green"], background=current_theme["bg"], mouse_callbacks={'Button1': lazy.spawn('libreoffice')}, padding=4),
        widget.TextBox(text="󰕼", font="JetBrainsMono Nerd Font", fontsize=18, foreground="#FF8800", background=current_theme["bg"], mouse_callbacks={'Button1': lazy.spawn('vlc')}, padding=4),
        widget.TextBox(text="󰂿", font="JetBrainsMono Nerd Font", fontsize=18, foreground=current_theme["green"], background=current_theme["bg"], mouse_callbacks={'Button1': lazy.spawn('calibre')}, padding=4),
        widget.TextBox(text="󰄄", font="JetBrainsMono Nerd Font", fontsize=18, foreground="#FAB387", background=current_theme["bg"], mouse_callbacks={'Button1': lazy.spawn('shotwell')}, padding=4),
        widget.TextBox(text="󰎈", font="JetBrainsMono Nerd Font", fontsize=18, foreground="#F38BA8", background=current_theme["bg"], mouse_callbacks={'Button1': lazy.spawn('rhythmbox')}, padding=4),

        widget.Sep(linewidth=1, padding=6, foreground=current_theme["inactive"], background=current_theme["bg"]),

        # --- NOWE IKONY FLATPAK ---
        widget.TextBox(text="󰊻", font="JetBrainsMono Nerd Font", fontsize=18, foreground=current_theme["teams"], background=current_theme["bg"], mouse_callbacks={'Button1': lazy.spawn('flatpak run com.github.IsmaelMartinez.teams_for_linux')}, padding=4),
        widget.TextBox(text="󰖣", font="JetBrainsMono Nerd Font", fontsize=18, foreground=current_theme["green"], background=current_theme["bg"], mouse_callbacks={'Button1': lazy.spawn('flatpak run com.ktechpit.whatsie')}, padding=4),
        widget.TextBox(text="󰠃", font="JetBrainsMono Nerd Font", fontsize=18, foreground="#F38BA8", background=current_theme["bg"], mouse_callbacks={'Button1': lazy.spawn('flatpak run app.ytmdesktop.ytmdesktop')}, padding=4),
        widget.TextBox(text="󰕍", font="JetBrainsMono Nerd Font", fontsize=18, foreground="#FAB387", background=current_theme["bg"], mouse_callbacks={'Button1': lazy.spawn('flatpak run com.github.unrud.VideoDownloader')}, padding=4),
        widget.TextBox(text="󰖐", font="JetBrainsMono Nerd Font", fontsize=18, foreground=current_theme["blue"], background=current_theme["bg"], mouse_callbacks={'Button1': lazy.spawn('flatpak run io.github.amit9838.mousam')}, padding=4),

        widget.Sep(linewidth=1, padding=8, foreground=current_theme["inactive"], background=current_theme["bg"]),

        # --- PULPITY (1-4) ---
        widget.GroupBox(
            highlight_method='line',
            active=current_theme["active"],
            inactive=current_theme["inactive"],
            background=current_theme["bg"],
            highlight_color=[current_theme["bg"], current_theme["bg"]],
            this_current_screen_border=current_theme["active"],
            margin_x=0,
            padding_x=5,
        ),

        widget.Sep(linewidth=1, padding=8, foreground=current_theme["inactive"], background=current_theme["bg"]),
        widget.Prompt(background=current_theme["bg"], foreground=current_theme["fg"]),

        # --- ODSTĘP DO ŚRODKA ---
        widget.Spacer(background=current_theme["bg"]),

        # --- ŚRODEK PASKA (ZEGAR) ---
        widget.Clock(format="%Y-%m-%d %a %H:%M", foreground=current_theme["fg"], background=current_theme["bg"]),

        # --- ODSTĘP OD ŚRODKA DO PRAWEJ STRONY ---
        widget.Spacer(background=current_theme["bg"]),

        # --- PRAWA STRONA PASKA ---
        widget.KeyboardLayout(configured_keyboards=['pl'], foreground=current_theme["fg_icon"], background=current_theme["bg"]),
        widget.Sep(linewidth=1, padding=8, foreground=current_theme["inactive"], background=current_theme["bg"]),
    ]

    # Systray trafia tylko na główny ekran
    if is_primary:
        widgets.extend([
            widget.Systray(padding=4, icon_size=18, background=systray_bg),
            widget.Sep(linewidth=1, padding=8, foreground=current_theme["inactive"], background=current_theme["bg"]),
        ])

    widgets.extend([
        # Ikona menedżera zasilania
        widget.TextBox(
            text="󰂄",
            font="JetBrainsMono Nerd Font",
            fontsize=18,
            foreground=current_theme["fg_icon"],
            background=current_theme["bg"],
            mouse_callbacks={'Button1': lazy.spawn('xfce4-power-manager-settings')},
            padding=4,
        ),
        widget.Sep(linewidth=1, padding=8, foreground=current_theme["inactive"], background=current_theme["bg"]),
        
        # Przycisk wyłączenia
        widget.QuickExit(
            default_text='󰐥',
            command='systemctl poweroff',
            foreground=current_theme["fg_icon"],
            background=current_theme["bg"],
        ),
    ])

    return bar.Bar(widgets, 30, background=current_theme["bg"])

# Definicja ekranów
screens = [
    Screen(
        top=create_bar(is_primary=True),
        background="#000000",
    ),
    Screen(
        top=create_bar(is_primary=False),
        background="#000000",
    ),
]

fake_screens: list[Screen] | None = None
generate_screens: Callable[[list[Output]], list[Screen]] | None = None

# Obsługa myszy
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
