# yt-bot

Telegram-бот и CLI-утилита для скачивания аудио с YouTube в формате MP3.

## Зависимости

* C++20 компилятор (GCC 13+ / Clang 16+)
* CMake 3.16+
* `libcurl4-openssl-dev` и `libssl-dev`
* `yt-dlp` и `ffmpeg` (должны быть в `PATH`)

### Установка зависимостей (Ubuntu / Debian)

```bash
sudo apt update
sudo apt install -y cmake build-essential libcurl4-openssl-dev libssl-dev ffmpeg
pip install yt-dlp  # или через системный пакетный менеджер
```

## Сборка

```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
```

Исполняемый файл появится в `build/yt_bot`.

## Использование

### 1. Скачивание аудио через CLI

```bash
./build/yt_bot "https://www.youtube.com/watch?v=..."
```

Аудиофайл сохранится в текущую директорию в формате `<title>.mp3`.

### 2. Запуск Telegram-бота

При первом запуске утилита создаст шаблон конфигурации `yt_bot_token.json`:

```bash
./build/yt_bot serve
```

Заполните токены в созданном файле:

```json
{
    "bot": {
        "token": "123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
    },
    "channel": {
        "token": "@your_channel_name"
    }
}
```

* `channel.token`: username канала или ID для пересылки (можно оставить пустым `""`, если отправка в канал не требуется).

Запустите бота повторно:

```bash
./build/yt_bot serve
```
