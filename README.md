# Nekit Pixel Bot [WoW 7.3.5] (BETA)

![Status](https://img.shields.io/badge/Status-BETA-orange) ![WoW](https://img.shields.io/badge/Game-WoW%207.3.5%20(Legion)-red) ![Platform](https://img.shields.io/badge/Platform-Windows-blue)

**Nekit Pixel Bot** is an external automation tool designed for **World of Warcraft 7.3.5 (Legion)**. It works in conjunction with a modified version of the **Hekili** addon.

> ⚠️ **BETA VERSION:** This software is currently in Beta. Bugs may occur. Please report any issues.
>
> ⚠️ **БЕТА-ВЕРСИЯ:** Программа находится в стадии тестирования. Возможны ошибки.

[🇷🇺 Читать на русском (Russian Version)](#-russian-version-инструкция-на-русском)

---

## 🇺🇸 English Version

### Features
* **7.3.5 Support:** Specifically tested on Legion clients.
* **Safety:** Randomized delays and inputs to simulate human behavior.
* **Smart Casting:** Prevents interruption of channeling spells.
* **Pixel Detection:** High-speed capture using `mss`.

### Installation

#### 1. The Addon (Lua)
1.  Download the **Hekili** addon version compatible with **7.3.5** (Legion).
2.  Navigate to your WoW folder: `Interface\AddOns\Hekili\`.
3.  **Replace** the original `Hekili.lua` file with the one provided in the `Hekili_Mod` folder of this repository.
4.  **REQUIRED:** Set your WoW Video settings to **Windowed** or **Windowed (Fullscreen)** mode. The bot cannot see the pixel in exclusive Fullscreen mode.

#### 2. The Bot
1.  Download `NekitPixelBot.exe` from the [Releases](../../releases) page.
2.  Run as **Administrator** (required to simulate key presses).

### Setup & Usage
1.  **Coordinates:** The modified addon draws a pixel at the top-left corner (0,0) of the WoW window.
    * Set Bot **X** to `1` and **Y** to `1`.
2.  **Keybindings:**
    * Ensure your in-game action bars match standard keys (`1`-`9`, `Q`, `E`, `R`, `F`, etc.).
3.  **Control:**
    * Press **F6** (default hotkey) to Start/Stop the bot.

---

## 🇷🇺 Russian Version (Инструкция на русском)

**Nekit Pixel Bot** — это внешний бот для автоматической ротации в **World of Warcraft 7.3.5 (Legion)**. Он считывает цветной код с экрана и нажимает кнопки за вас.

> **ВНИМАНИЕ:** Это **БЕТА-ВЕРСИЯ**. Используйте с осторожностью. Если бот перестает нажимать кнопки — перезапустите его или нажмите F6 дважды.

### Установка

#### 1. Аддон (Hekili)
1.  Вам нужен аддон Hekili версии, совместимой с **Legion 7.3.5**.
2.  Откройте папку с аддоном: `Interface\AddOns\Hekili\`.
3.  Скачайте файл `Hekili.lua` из папки `Hekili_Mod` в этом репозитории.
4.  **Замените** оригинальный файл `Hekili.lua` скачанным.
5.  **ВАЖНО:** В настройках графики WoW выберите режим **"Оконный"** или **"Оконный (весь экран)"**. В полноэкранном режиме бот не увидит пиксель!

#### 2. Бот (Программа)
1.  Скачайте готовый `NekitPixelBot.exe` во вкладке [Releases](../../releases) (справа на странице GitHub).
2.  Запустите программу от имени **Администратора**.

### Настройка
1.  **Координаты:** В программе выставьте **X: 1** и **Y: 1**.
    * *Если бот не видит цвет, попробуйте изменить значения на 0 или 2.*
2.  **Клавиши:** Бот нажимает стандартные клавиши (`1`-`0`, `Q`, `E`, `R` и т.д.). Убедитесь, что ваши способности расставлены на панели соответственно.
3.  **Запуск:**
    * Нажмите **F6** (по умолчанию), чтобы активировать бота. Статус изменится на `BOT RUNNING`.
    * Нажмите F6 еще раз для паузы.

---

### Disclaimer / Отказ от ответственности
*This software is for educational purposes only. Use on private servers or official realms is at your own risk. Automation tools may violate Blizzard's Terms of Service.*

*Программа создана в ознакомительных целях. Использование на официальных или приватных серверах — на ваш страх и риск.*

**Dev:** omgcast
