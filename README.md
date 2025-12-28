 ### Disclaimer

*This software is for educational purposes only. Use on private servers or official realms is at your own risk. Automation tools may violate Blizzard's Terms of Service.*


### Предупреждение

*Данное программное обеспечение предназначено исключительно для образовательных целей. Использование на частных серверах или официальных игровых мирах осуществляется на ваш собственный риск. Инструменты автоматизации могут нарушать Условия предоставления услуг Blizzard.* 

# Nekit Pixel Bot (Hekili based)

[ **English** ](#-english) | [ **Русский** ](#-русский)

**External Pixel Bot for WoW pirate servers (beta) based on Hekili.**

---

## 🇺🇸 English

###  Requirements
1. [**Logitech G HUB**](https://www.logitechg.com/en-us/software/ghub)  OR  [use search](https://www.google.com/search?q=Logitech+G+HUB+Download) installed (needed for drivers). The app itself can be closed. `tested on version 2025.9.814157`
2. **Windowed** or **Windowed (Fullscreen)** mode in WoW.

###  Installation & Usage

#### 1. Game Setup
1. Replace `Hekili.lua` in `Interface\AddOns\Hekili\` with the modified version from this repo.
2. Run this command in WoW chat to hide errors:
   
   ```
   /console scriptErrors 0
   ```
   
4. Bind your spells to standard keys: `1`-`9`, `0`, `-`, `=`, `F1`...

#### 2. Running the Bot
1. Download the latest [**Release**](https://github.com/omgcast/Nekit-Pixel-Bot/releases) or `python main.py`.
2. Run as **Administrator**.
3. Set **X: 0, Y: 0** in the bot (matches the pixel in top-left corner).
4. Press **F6** (default) to toggle ON/OFF.

> ****Important:** Do not assign game abilities to the bot launch key (default **F6**)!**

---

## 🇷🇺 Русский

**Внешний Pixel Bot для пиратских серверов WoW (бета-версия) на основе Hekili.**

###  Требования
1. Установленный [**Logitech G HUB**](https://www.logitechg.com/en-us/software/ghub)  ИЛИ  [Используйте поиск](https://www.google.com/search?q=Logitech+G+HUB+Download) (нужен для драйверов). Само приложение можно закрыть.`Протестировано на версии 2025.9.814157`
2. Режим экрана в WoW: **Оконный** или **Оконный (весь экран)**.


###  Установка и Запуск

#### 1. Настройка игры
1. Замените `Hekili.lua` в папке `Interface\AddOns\Hekili\` на файл из этого репозитория.
2. Пропишите в чате команду (скрывает ошибки Lua):
   
   ```
   /console scriptErrors 0
   ```
   
4. Бинды способностей должны быть стандартными: `1`-`9`, `0`, `-`, `=`, `F1`...

#### 2. Запуск бота
1. Скачайте последний [**Релиз**](https://github.com/omgcast/Nekit-Pixel-Bot/releases) или запустите `python main.py`.
2. Запустите от имени **Администратора**.
3. В программе выставьте координаты **X: 0, Y: 0** (пиксель в левом верхнем углу).
4. Нажмите **F6** (по умолчанию) для включения/выключения.

> ****Важно:** Не назначайте игровые способности на клавишу запуска бота (по умолчанию **F6**)!**

---


| Expansion | Version | Tested |
| :--- | :--- | :--- |
| **The War Within** | 11.1.5 | ✅ |
| **Dragonflight** | 10.2.7 | ✅ |
| **Shadowlands** | 9.2.7 | ✅ |
| **BFA** | 8.3.7 | ✅ |
| **Legion** | 7.3.5 | ✅ |

