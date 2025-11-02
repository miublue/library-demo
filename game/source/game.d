module game;
import std;
import raylib;
/* import raygui; */
import config;
import client;
import connection;
import player;
import world;
import menu;

enum GameScreenState {
    LOGIN_SCREEN,
    BOOK_SCREEN,
    GAME_SCREEN,
}

struct GameScreen {
    void delegate() update;
    void delegate() render;
}

class Game {
    Book[] book_data;
    User user;

    GameScreenState screen = GameScreenState.LOGIN_SCREEN;
    GameScreen[GameScreenState] screens;

    Camera2D camera;
    World world;
    Player player;
    Menu login_menu, game_menu;

    this() {
        world = loadWorldMap("./data/biblioteca");
        player = Player(world.player_pos);

        game_menu = new Menu(Rectangle(0, 0, 200, 40));
        game_menu.addComponent(new Label(Vector2(5, 5), LabelAlignment.LEFT, GUI_TEXT["username"]));

        login_menu = new Menu(Rectangle(WINDOW_WIDTH/2 - 300, WINDOW_HEIGHT/2 - 100, 600, 200));
        login_menu.addComponent(new Label(Vector2(300, 10), LabelAlignment.CENTER, GUI_TEXT["login"]));
        login_menu.addComponent(new Label(Vector2(10, 65), LabelAlignment.LEFT, GUI_TEXT["username"]));
        immutable size = MeasureTextEx(login_menu.font, GUI_TEXT["username"].toStringz, FONT_SIZE, FONT_SPACING);

        auto login = delegate(UIComponent _) {
            auto ent = cast(Entry*)(&login_menu.components[2]);
            if (!ent.text.length) return;
            user = getUserByName(ent.text);
            if (user.id != 0) {
                user = getUserByName(ent.text);
                game_menu.components[0].text ~= ": " ~ user.name;
                screen = GameScreenState.GAME_SCREEN;
            } else {
                login_menu.components[0].text = GUI_TEXT["login_failed"];
                ent.is_selected = true;
                ent.text_pos = 0;
                ent.text = "";
            }
        };

        login_menu.addComponent(new Entry(Rectangle(20+size.x, 60, 600-size.x-30, 40), "", login));
        login_menu.addComponent(new Button(Rectangle(10, 130, 580, 40), GUI_TEXT["enter"], login));
        login_menu.components[2].is_selected = true;

        camera.zoom = CAMERA_ZOOM;
        camera.rotation = 0;

        screens = [
            GameScreenState.LOGIN_SCREEN: GameScreen(&updateLoginScreen, &renderLoginScreen),
            GameScreenState.BOOK_SCREEN:  GameScreen(&updateBookScreen,  &renderBookScreen),
            GameScreenState.GAME_SCREEN:  GameScreen(&updateGameScreen,  &renderGameScreen),
        ];
    }

    void updateLoginScreen() {
        login_menu.rect.x = GetScreenWidth()/2 - login_menu.rect.width/2;
        login_menu.rect.y = GetScreenHeight()/2 - login_menu.rect.height/2;
    }

    void renderLoginScreen() {
        ClearBackground(Colors.BLACK);
        login_menu.render();
    }

    void updateBookScreen() {}
    void renderBookScreen() {
        ClearBackground(Colors.BLACK);
    }

    void updateGameScreen() {
        player.update(world);
        camera.target = Vector2(player.rect.x + (TILE_SIZE/2), player.rect.y + (TILE_SIZE/2));
        camera.offset = Vector2(GetScreenWidth()/2, GetScreenHeight()/2);
    }

    void renderGameScreen() {
        ClearBackground(Colors.BLACK);
        BeginMode2D(camera);
        world.render();
        player.render();
        EndMode2D();
        game_menu.render();
    }
}

