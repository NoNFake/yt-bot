#include <iostream>
#include <fstream>
#include <array>
#include <string>
#include <memory>
#include <tgbotxx/tgbotxx.hpp>
#include <nlohmann/json.hpp>

using json = nlohmann::json;



struct AudioInfo {
    std::string title;
    std::string filepath;
};

AudioInfo donwload_audio(
    const std::string& url,
    const std::string& out_file
) {
    std::string cmd = "yt-dlp -x --audio-format mp3 -o \"" + out_file + "\" --print title --print after_move:filepath \"" + url + "\" 2>/dev/null";
    std::array<char, 256> buffer;
    std::string output;
    std::unique_ptr<FILE, decltype(&pclose)> pipe(
        popen(cmd.c_str(), "r"), pclose
    );

    if (!pipe) return {};

    while (fgets(
        buffer.data(), 
        buffer.size(),
        pipe.get()
    )) {
        output += buffer.data();
    }

    AudioInfo info;
    auto pos = output.find('\n');
    if (pos != std::string::npos) {
        info.title = output.substr(0, pos);
        info.filepath = output.substr(pos + 1);
        if (!info.filepath.empty() && info.filepath.back() == '\n') {
            info.filepath.pop_back();
        }
    } else {
        info.title = output;
    }
    return info;
}

class TgBot : public tgbotxx::Bot {
public:
    std::string channel_id;

    explicit TgBot(
        const std::string& token,
        std::string chan_id
    ) : tgbotxx::Bot(token), channel_id(std::move(chan_id)) {}

    void onCommand(const tgbotxx::Ptr<tgbotxx::Message>& message) override {
        if (message->text == "/start") {
            api()->sendMessage(
                message->chat->id, "send me a youtube link"
            );
        }
    }


    void onAnyMessage(const tgbotxx::Ptr<tgbotxx::Message>& message) override {
        if (message->text.starts_with("/")) return;

        const std::string& url = message->text;
        if (!url.starts_with("https://www.youtube.com") && !url.starts_with("https://youtu.be")) {
            api()->sendMessage(message->chat->id, "send a valid youtube link");
            return;
        }

        api()->sendMessage(message->chat->id, "download audio");
        std::string temp_file = "/tmp/audio_" + std::to_string(message->messageId) + ".mp3";
        auto info = donwload_audio(url, temp_file);

        if (info.title.empty()) {
            api()->sendMessage(message->chat->id, "fail to download audio :<");
            return;
        }

        std::string actual_file = info.filepath.empty() ? temp_file : info.filepath;

        try {
            cpr::File audio_file(actual_file);
            api()->sendAudio(message->chat->id, audio_file, 0, "", "", {}, 0, "YouTube", info.title);
            api()->sendAudio(channel_id, audio_file, 0, "From @" + message->from->username, "", {}, 0, "YouTube", info.title);  
        } catch (const std::exception& e) {
            std::cerr << "tg error: " << e.what() << "\n";
        }

        std::remove(actual_file.c_str());
    }
};



void print_help(const char* prog) {
    std::cout << "usage:\n"
              << " " << prog << " <youtube_url>  download audio\n" 
              << " " << prog << " serve          run bot serve\n"; 
}




void serve() {
    std::ifstream file("yt_bot_token.json");
    if (!file.is_open()) {
        json default_cfg = {
            {"bot", {{"token", ""}}},
            {"channel", {{"token", ""}}}
        };
        std::ofstream out("yt_bot_token.json");
        out << default_cfg.dump(4) << std::endl;
        std::cout << "config not found, created yt_bot_token.json. Please fill in tokens.\n";
        return;
    }

    json cfg;
    file >> cfg;

    if (cfg["bot"]["token"].empty()) {
        std::cerr << "bot token is empty in yt_bot_token.json\n";
        return;
    }

    TgBot bot(cfg["bot"]["token"], cfg["channel"]["token"]);
    std::cout << "bot started...\n";
    bot.start();
}

void download(
    const std::string& url,
    const std::string& out_file
) {
    auto info = donwload_audio(url, out_file);
    if (!info.title.empty()) {
        std::cout << "downloaded: " << info.title << "\n";
        if (!info.filepath.empty()) {
            std::cout << "saved to: " << info.filepath << "\n";
        }
        return;
    }

    std::cerr << "download error\n";
}


int main(int argc, char* argv[]) {
    if (argc < 2) {
        print_help(argv[0]);
        return 0;
    }

    std::string arg = argv[1];

    if (arg == "serve") {
        serve();
        return 0;
    }
    if (arg.starts_with("https://www.youtube.com") || arg.starts_with("https://youtu.be")) {
        download(arg, "%(title)s.%(ext)s");
        return 0;
    }

    print_help(argv[0]);
    return 0;
}







