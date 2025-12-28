import flet as ft
import mss
import numpy as np
import time
import random
import threading
import keyboard
import ctypes
from ctypes import wintypes
import json
import os

try:
    ctypes.windll.shcore.SetProcessDpiAwareness(1)
except Exception:
    ctypes.windll.user32.SetProcessDPIAware()

ghub = None
try:
    dll_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'ghub_device.dll')
    if os.path.exists(dll_path):
        ghub = ctypes.CDLL(dll_path)
        ghub.device_open()
        ghub.key_down.argtypes = [ctypes.c_char_p]
        ghub.key_up.argtypes = [ctypes.c_char_p]
except Exception:
    pass

KEYS_LIST = [
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
    "q", "w", "e", "r", "t", "y", "u", "i", "o", "p",
    "a", "s", "d", "f", "g", "h", "j", "k", "l",
    "z", "x", "c", "v", "b", "n", "m",
    "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9",
    "-", "=", "`",
    "[", "]", ";", "'", ",", ".", "/", "\\", "f10", "f11", "f12"
]
KEYS_MAP = {i: v for i, v in enumerate(KEYS_LIST, 1)}

MODS_MAP = {1: "shift", 2: "ctrl", 3: "alt", 4: ["shift", "ctrl"], 5: ["shift", "alt"], 6: ["ctrl", "alt"]}

user32 = ctypes.WinDLL('user32', use_last_error=True)

class POINT(ctypes.Structure):
    _fields_ = [("x", ctypes.c_long), ("y", ctypes.c_long)]

def PressKey(key_name):
    if ghub:
        try:
            ghub.key_down(key_name.encode('utf-8'))
        except:
            pass

def ReleaseKey(key_name):
    if ghub:
        try:
            ghub.key_up(key_name.encode('utf-8'))
        except:
            pass

PROFILES_DIR = "profiles"

LOCALES = {
    "RU": {
        "capture": "1. ЗАХВАТ ЭКРАНА", "control": "2. УПРАВЛЕНИЕ", "timings": "3. ТАЙМИНГИ (СЕК)",
        "reaction": "Реакция", "press": "Нажатие", "gcd": "ГКД", "safety": "Защита",
        "save_as": "СОХРАНИТЬ КАК...", "status_off": "БОТ ОСТАНОВЛЕН", "status_on": "БОТ АКТИВЕН",
        "assign": "КЛАВИША: ", "wait": "ЖДУ НАЖАТИЯ...", "profile": "Профиль",
        "dlg_title": "Новый профиль", "dlg_name": "Имя профиля", "dlg_save": "Создать", "dlg_cancel": "Отмена",
        "h_cap": "Координаты пикселя (X, Y) относительно окна WoW.",
        "h_ctrl": "Клавиша запуска/остановки бота.",
        "h_react": "Задержка перед нажатием (имитация человека).",
        "h_pr": "Время удержания клавиши.",
        "h_g": "Пауза между действиями (Глобальный Кулдаун).",
        "h_sf": "Компенсация сетевого пинга (мс)."
    },
    "EN": {
        "capture": "1. SCREEN CAPTURE", "control": "2. CONTROL", "timings": "3. TIMINGS (SEC)",
        "reaction": "Reaction", "press": "Press", "gcd": "GCD", "safety": "Safety",
        "save_as": "SAVE AS...", "status_off": "BOT STOPPED", "status_on": "BOT RUNNING",
        "assign": "HOTKEY: ", "wait": "PRESS KEY...", "profile": "Profile",
        "dlg_title": "New Profile", "dlg_name": "Profile name", "dlg_save": "Create", "dlg_cancel": "Cancel",
        "h_cap": "X, Y coordinates relative to WoW window.",
        "h_ctrl": "Start/Stop hotkey.",
        "h_react": "Human reaction delay simulation.",
        "h_pr": "Key hold duration.",
        "h_g": "Pause between actions (Global Cooldown).",
        "h_sf": "Network ping correction (ms)."
    }
}

def main(page: ft.Page):
    page.title = "Nekit Pixel Bot (Logitech String Edition)"
    page.window.width, page.window.height = 440, 850
    page.theme_mode = ft.ThemeMode.DARK
    page.bgcolor = "#121417"
    page.padding = 15

    state = { "running": False, "hotkey": "f6", "unlock_time": 0.0, "last_key": None, "lang": "EN" }
    ui_inputs = []

    def create_input(label, value, width=80):
        field = ft.TextField(label=label, value=str(value), width=width, text_size=13, border_color="#444b55", focused_border_color=ft.Colors.BLUE_400, content_padding=10)
        ui_inputs.append(field)
        return field

    x_input, y_input = create_input("X", 1, 100), create_input("Y", 1, 100)
    r_min, r_max = create_input("Min", 0.03), create_input("Max", 0.07)
    p_min, p_max = create_input("Min", 0.03), create_input("Max", 0.06)
    g_min, g_max = create_input("Min", 0.1), create_input("Max", 0.2)
    safety_input = create_input("Safety", 50, 170)

    txt_capture = ft.Text(weight=ft.FontWeight.BOLD, color=ft.Colors.BLUE_200)
    txt_control = ft.Text(weight=ft.FontWeight.BOLD, color=ft.Colors.BLUE_200)
    txt_timings = ft.Text(weight=ft.FontWeight.BOLD, color=ft.Colors.BLUE_200)
    
    lbl_reaction, lbl_press, lbl_gcd, lbl_safety = ft.Text(width=80), ft.Text(width=80), ft.Text(width=80), ft.Text(width=80)
    status_text = ft.Text(weight=ft.FontWeight.BOLD, size=20)
    
    logitech_status = ft.Text(
        value="LOGITECH: ACTIVE" if ghub else "LOGITECH: NOT FOUND",
        color=ft.Colors.GREEN_400 if ghub else ft.Colors.RED_400,
        weight=ft.FontWeight.BOLD,
        size=12
    )

    hotkey_btn = ft.OutlinedButton(text="F6", on_click=lambda e: start_hotkey_assign())
    lang_btn = ft.TextButton(text="RU", on_click=lambda e: change_lang(e))
    prof_dropdown = ft.Dropdown(width=250, border_color="#444b55", on_change=lambda e: load_profile(e.data))

    def create_help(): return ft.IconButton(icon=ft.Icons.HELP_OUTLINE, icon_size=16, icon_color="#444b55")
    h_cap, h_ctrl, h_react, h_pr, h_g, h_sf = [create_help() for _ in range(6)]
    ui_helps = [h_cap, h_ctrl, h_react, h_pr, h_g, h_sf]

    new_profile_name = ft.TextField(label="filename")
    def confirm_save_as(e):
        if new_profile_name.value:
            save_logic(new_profile_name.value); new_profile_name.value = ""
            save_as_dialog.open = False; refresh_profiles(); page.update()

    save_as_dialog = ft.AlertDialog(
        title=ft.Text("Save Profile As"), content=new_profile_name,
        actions=[
            ft.TextButton("Save", on_click=confirm_save_as),
            ft.TextButton("Cancel", on_click=lambda _: setattr(save_as_dialog, "open", False) or page.update())
        ]
    )
    page.overlay.append(save_as_dialog)
    btn_save_as = ft.ElevatedButton(text="SAVE AS", icon=ft.Icons.SAVE_AS, width=400, bgcolor=ft.Colors.BLUE_800, color=ft.Colors.WHITE, on_click=lambda _: setattr(save_as_dialog, "open", True) or page.update())

    main_container = ft.Container(padding=20, bgcolor="#1a1d23", border_radius=15, border=ft.border.all(1, "#2d343e"))

    def set_theme(mode_name):
        if mode_name == "dark":
            page.theme_mode = ft.ThemeMode.DARK; page.bgcolor = "#121417"; main_container.bgcolor = "#1a1d23"; main_container.border.color = "#2d343e"; text_col = ft.Colors.BLUE_200; accent = ft.Colors.BLUE_400; btn_bg = ft.Colors.BLUE_800
        elif mode_name == "light":
            page.theme_mode = ft.ThemeMode.LIGHT; page.bgcolor = "#eef2f5"; main_container.bgcolor = "#ffffff"; main_container.border.color = "#d0d7de"; text_col = ft.Colors.BLUE_800; accent = ft.Colors.BLUE_600; btn_bg = ft.Colors.BLUE_600
        elif mode_name == "astolfo":
            page.theme_mode = ft.ThemeMode.DARK; page.bgcolor = "#25181c"; main_container.bgcolor = "#38232a"; main_container.border.color = "#8c4e66"; text_col = "#fb92b3"; accent = "#ffc2d1"; btn_bg = "#d95c88"
        txt_capture.color = txt_control.color = txt_timings.color = text_col
        btn_save_as.bgcolor = btn_bg
        prof_dropdown.border_color = main_container.border.color
        for inp in ui_inputs: inp.border_color = main_container.border.color; inp.focused_border_color = accent
        for h in ui_helps: h.icon_color = main_container.border.color
        page.update()

    def theme_btn(color, mode): return ft.Container(width=20, height=20, bgcolor=color, border_radius=10, border=ft.border.all(1, "#888888"), on_click=lambda _: set_theme(mode), animate=ft.Animation(300, "easeOut"))
    theme_row = ft.Row([theme_btn("#1a1d23", "dark"), theme_btn("#ffffff", "light"), theme_btn("#fb92b3", "astolfo")], spacing=10)

    def update_ui_text():
        l = LOCALES[state["lang"]]
        txt_capture.value, txt_control.value, txt_timings.value = l["capture"], l["control"], l["timings"]
        lbl_reaction.value, lbl_press.value, lbl_gcd.value, lbl_safety.value = l["reaction"], l["press"], l["gcd"], l["safety"]
        btn_save_as.text, prof_dropdown.label, lang_btn.text = l["save_as"], l["profile"], ("RU" if state["lang"] == "EN" else "EN")
        save_as_dialog.title.value, new_profile_name.label = l["dlg_title"], l["dlg_name"]
        save_as_dialog.actions[0].text, save_as_dialog.actions[1].text = l["dlg_save"], l["dlg_cancel"]
        h_cap.tooltip, h_ctrl.tooltip = l["h_cap"], l["h_ctrl"]
        h_react.tooltip, h_pr.tooltip, h_g.tooltip, h_sf.tooltip = l["h_react"], l["h_pr"], l["h_g"], l["h_sf"]
        status_text.value, status_text.color = (l["status_on"], ft.Colors.GREEN_400) if state["running"] else (l["status_off"], ft.Colors.RED_400)
        hotkey_btn.text = f"{l['assign']}[{state['hotkey'].upper()}]"
        page.update()

    def change_lang(e): state["lang"] = "RU" if state["lang"] == "EN" else "EN"; update_ui_text()

    def get_wow_coords():
        try:
            hwnd = user32.GetForegroundWindow()
            length = user32.GetWindowTextLengthW(hwnd)
            buf = ctypes.create_unicode_buffer(length + 1)
            user32.GetWindowTextW(hwnd, buf, length + 1)
            if "Warcraft" not in buf.value: return None
            pt = POINT(0, 0)
            user32.ClientToScreen(hwnd, ctypes.byref(pt))
            return pt.x, pt.y
        except: return None

    def bot_loop():
        with mss.mss() as sct:
            while True:
                if not state["running"]: time.sleep(0.1); continue
                
                origin = get_wow_coords()
                if not origin: time.sleep(0.5); continue
                
                now = time.perf_counter()
                if now < state["unlock_time"]: continue

                try:
                    abs_x = origin[0] + int(x_input.value)
                    abs_y = origin[1] + int(y_input.value)
                    mon = {"top": abs_y, "left": abs_x, "width": 1, "height": 1}
                    img = np.array(sct.grab(mon))
                    b, g, r = img[0, 0][:3]
                except: continue

                if r > 60 or r == 0: 
                    state["last_key"] = None
                    continue

                key_name = KEYS_MAP.get(int(r))

                if key_name and (key_name != state["last_key"] or now >= state["unlock_time"]):
                    time.sleep(random.uniform(float(r_min.value), float(r_max.value)))
                    
                    mods = MODS_MAP.get(int(g), [])
                    m_list = mods if isinstance(mods, list) else [mods] if mods else []
                    
                    for m in m_list: PressKey(m)
                    
                    PressKey(key_name)
                    time.sleep(random.uniform(float(p_min.value), float(p_max.value)))
                    ReleaseKey(key_name)
                    
                    for m in reversed(m_list): ReleaseKey(m)
                    
                    state["last_key"] = key_name
                    state["unlock_time"] = time.perf_counter() + random.uniform(float(g_min.value), float(g_max.value))

    def toggle_bot(): state["running"] = not state["running"]; update_ui_text()
    def start_hotkey_assign(): hotkey_btn.text = LOCALES[state["lang"]]["wait"]; page.update(); threading.Thread(target=wait_for_key, daemon=True).start()
    def wait_for_key():
        event = keyboard.read_event(suppress=True)
        if event.event_type == "down":
            state["hotkey"] = event.name
            keyboard.unhook_all(); keyboard.add_hotkey(state["hotkey"], toggle_bot); update_ui_text()

    def save_logic(name):
        if not os.path.exists(PROFILES_DIR): os.makedirs(PROFILES_DIR)
        data = {"hotkey": state["hotkey"], "lang": state["lang"], "cfg": {"x": x_input.value, "y": y_input.value, "r_min": r_min.value, "r_max": r_max.value, "p_min": p_min.value, "p_max": p_max.value, "g_min": g_min.value, "g_max": g_max.value, "safety": safety_input.value}}
        with open(os.path.join(PROFILES_DIR, f"{name}.json"), "w") as f: json.dump(data, f)
        prof_dropdown.value = name

    def load_profile(name):
        path = os.path.join(PROFILES_DIR, f"{name}.json")
        if os.path.exists(path):
            with open(path, "r") as f:
                d = json.load(f); state["hotkey"], state["lang"] = d.get("hotkey", "f6"), d.get("lang", "EN")
                cfg = d.get("cfg", {}); x_input.value, y_input.value = str(cfg.get("x", 1)), str(cfg.get("y", 1))
                r_min.value, r_max.value = str(cfg.get("r_min", 0.03)), str(cfg.get("r_max", 0.07))
                p_min.value, p_max.value = str(cfg.get("p_min", 0.03)), str(cfg.get("p_max", 0.06))
                g_min.value, g_max.value = str(cfg.get("g_min", 0.1)), str(cfg.get("g_max", 0.2))
                safety_input.value = str(cfg.get("safety", 50))
            keyboard.unhook_all(); keyboard.add_hotkey(state["hotkey"], toggle_bot); update_ui_text()

    def refresh_profiles():
        if not os.path.exists(PROFILES_DIR): os.makedirs(PROFILES_DIR)
        profs = [f.replace(".json", "") for f in os.listdir(PROFILES_DIR) if f.endswith(".json")]
        if not profs: save_logic("default"); profs = ["default"]
        prof_dropdown.options = [ft.dropdown.Option(p) for p in profs]
        if not prof_dropdown.value: prof_dropdown.value = "default"
        page.update()

    refresh_profiles(); load_profile(prof_dropdown.value); update_ui_text()
    
    main_container.content = ft.Column([
        ft.Row([theme_row, logitech_status, lang_btn], alignment="spaceBetween"), 
        ft.Row([prof_dropdown, ft.IconButton(ft.Icons.REFRESH, on_click=lambda _: refresh_profiles())], alignment="spaceBetween"),
        ft.Divider(color="#2d343e"),
        ft.Column([ft.Row([txt_capture, h_cap]), ft.Row([x_input, y_input])], spacing=5),
        ft.Column([ft.Row([txt_control, h_ctrl]), hotkey_btn], spacing=5),
        ft.Column([
            txt_timings,
            ft.Row([lbl_reaction, r_min, r_max, h_react], vertical_alignment="center"),
            ft.Row([lbl_press, p_min, p_max, h_pr], vertical_alignment="center"),
            ft.Row([lbl_gcd, g_min, g_max, h_g], vertical_alignment="center"),
            ft.Row([lbl_safety, safety_input, h_sf], vertical_alignment="center"),
        ], spacing=10),
        btn_save_as,
    ], spacing=15)

    credits_link = ft.TextButton(text="Dev: omgcast", style=ft.ButtonStyle(color=ft.Colors.GREY_500), on_click=lambda e: page.launch_url("https://github.com/omgcast"))

    page.add(main_container, ft.Container(status_text, alignment=ft.alignment.center, padding=ft.padding.only(top=10, bottom=5)), ft.Container(credits_link, alignment=ft.alignment.center, padding=ft.padding.only(bottom=15)))
    threading.Thread(target=bot_loop, daemon=True).start()

ft.app(target=main)