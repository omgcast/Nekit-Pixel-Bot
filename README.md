# Nekit Pixel Bot (based on Hekili)

<div align="center">

[![DonationAlerts](https://img.shields.io/badge/DonationAlerts-Support%20Me-ff8c00?style=for-the-badge&logo=donation-alerts&logoColor=white)](https://www.donationalerts.com/r/n3kit91)
[![Status](https://img.shields.io/badge/Status-BETA-orange?style=for-the-badge)](https://github.com/n3kit91/NekitPixelBot)
[![Platform](https://img.shields.io/badge/Platform-Windows-blue?style=for-the-badge)](https://microsoft.com)

![WoW Legion](https://img.shields.io/badge/Legion-7.3.5-blue?style=flat-square)
![WoW BFA](https://img.shields.io/badge/BFA-8.3.7-blue?style=flat-square)
![WoW SL](https://img.shields.io/badge/Shadowlands-9.2.7-blue?style=flat-square)
![WoW DF](https://img.shields.io/badge/Dragonflight-10.2.7-blue?style=flat-square)

</div>

---

**Nekit Pixel Bot** is an external automation tool designed for **World of Warcraft**. It works in conjunction with a modified version of the **Hekili** addon to execute rotation perfectly.

> ⚠️ **BETA VERSION**
> This software is currently in Beta testing. Please report any issues you encounter.

### 📋 Tested Servers / Протестировано
| Expansion | Version | Servers |
| :--- | :--- | :--- |
| **Dragonflight** | 10.2.7 | `firestorm-servers.com`, ... |
| **Shadowlands** | 9.2.7 | `wowcircle.net`, ... |
| **Battle for Azeroth** | 8.3.7 | `wowcircle.net`, ... |
| **Legion** | 7.3.5 | `uwow.biz`, `wowcircle.net`, ... |

---

### 🌐 Select Language / Выберите язык
[🇺🇸 **English Instructions**](#-english-instructions) | [🇷🇺 **Инструкция на русском**](#-инструкция-на-русском)

---

## 🇺🇸 English Instructions

### ⚡ IMPORTANT
To prevent Lua error pop-ups from interrupting the bot or blocking the screen, **you must run this command** in the game chat once:
```text
/console scriptErrors 0
```

### ✨ Features
* **Multi-Expansion Support:** Compatible with Legion (7.3.5), BFA (8.3.7), SL (9.2.7), and DF (10.2.7).
* **Safety:** Randomized delays and inputs to simulate human behavior.
* **Smart Casting:** Prevents interruption of channeling spells.
* **Performance:** High-speed pixel capture using `mss`.

### 🐛 Known Issues (Bugs)
* **Function Keys:** The bot may currently fail to press **F10**, **F11**, and **F12**.
    * *Fix coming soon.*

### 📥 Installation

#### 1. The Addon (Lua)
1.  Download the standard **Hekili** addon compatible with your client version.
2.  Navigate to your WoW folder: `Interface\AddOns\Hekili\`.
3.  **Replace** the original `Hekili.lua` file with the one provided in the `Hekili_Mod` folder of this repository.
4.  **REQUIRED:** Set WoW Video settings to **Windowed** or **Windowed (Fullscreen)**. *Exclusive Fullscreen is not supported.*

#### 2. The Bot (Executable)
1.  Download `NekitPixelBot.exe` from the [Releases](../../releases) page.
2.  Run as **Administrator** (required to simulate key presses).

### ⚙️ Setup & Usage
1.  **Coordinates:** The addon draws a pixel at the top-left (0,0). Set Bot **X** to `1` and **Y** to `1`.
2.  **Keybindings:** Ensure your action bars use standard keys:
    * `1` - `9`, `0`, `-`, `=`
    * `Q`, `E`, `R`, `F`, `Z`, `X`, `C`, `V`
3.  **Control:** Press **F6** to Start/Stop the bot.

> ⛔ **CRITICAL NOTE:**
> **Do not bind any in-game spells to the bot's toggle key (Default: F6).**
> If you have a spell on F6, the bot will toggle itself on/off when trying to use it.

---

## 🇷🇺 Инструкция на русском

### ⚡ ВАЖНО 
Чтобы ошибки интерфейса (Lua errors) не всплывали по центру экрана и не мешали работе бота, **обязательно пропишите** в чате игры следующую команду:
```text
/console scriptErrors 0
```

### ✨ Возможности
* **Поддержка версий:** Работает на Legion (7.3.5), BFA (8.3.7), SL (9.2.7), DF (10.2.7).
* **Безопасность:** Рандомизация задержек для имитации действий человека.
* **Умный каст:** Не прерывает потоковые заклинания (channeling).
* **Быстродействие:** Быстрый захват экрана через `mss`.

### 🐛 Известные баги
* **Клавиши F:** На данный момент бот может не прожимать клавиши **F10**, **F11**, **F12**.
    * *Скоро исправим.*

### 📥 Установка

#### 1. Аддон (Lua)
1.  Скачайте обычный аддон **Hekili** для вашей версии игры.
2.  Откройте папку с аддонами: `Interface\AddOns\Hekili\`.
3.  **Замените** оригинальный файл `Hekili.lua` на файл из папки `Hekili_Mod` этого репозитория.
4.  **ВАЖНО:** В настройках графики WoW выберите режим **"Оконный"** или **"Оконный (весь экран)"**. В полноэкранном режиме бот не увидит пиксель!

#### 2. Бот (Программа)
1.  Скачайте `NekitPixelBot.exe` из раздела [Releases](../../releases) (справа на странице GitHub).
2.  Запустите программу от имени **Администратора**.

### ⚙️ Настройка и использование
1.  **Координаты:** Аддон рисует цветовой код в углу экрана. В программе выставьте **X: 1** и **Y: 1** (если не работает, попробуйте 0 или 2).
2.  **Клавиши:** Бот нажимает стандартные клавиши. Расставьте способности в игре на эти кнопки:
    * `1` - `9`, `0`, `-`, `=`
    * `Q`, `E`, `R`, `F`, `Z`, `X`, `C`, `V`
3.  **Управление:** Нажмите **F6** (по умолчанию), чтобы включить или выключить бота.

> ⛔ **КРИТИЧЕСКИ ВАЖНО:**
> **Не ставьте заклинания в игре на кнопку запуска бота (по умолчанию F6).**
> Если на F6 будет стоять скилл, бот будет постоянно включаться и выключаться при попытке его нажать.

---

### Disclaimer
*This software is for educational purposes only. Use on private servers or official realms is at your own risk. Automation tools may violate Blizzard's Terms of Service.*

### Предупреждение
*Данное программное обеспечение предназначено исключительно для образовательных целей. Использование на частных серверах или официальных игровых мирах осуществляется на ваш собственный риск. Инструменты автоматизации могут нарушать Условия предоставления услуг Blizzard.*
