module game;
import std;
import raylib;
import raygui;
import config;
import client;
import player;
import world;

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
    User client_user;

    GameScreenState screen = GameScreenState.GAME_SCREEN;
    GameScreen[GameScreenState] screens;

    Camera2D camera;
    World world;
    Player player;
    /* Font font; */
    /* string text; */

    this() {
        world = loadWorldMap("./data/biblioteca");
        player = Player(world.player_pos);
        /* font = LoadFontEx(FONT_PATH.toStringz, FONT_SIZE, null, 0); */
        camera.zoom = CAMERA_ZOOM;
        camera.rotation = 0;

        screens = [
            GameScreenState.LOGIN_SCREEN: GameScreen(&updateLoginScreen, &renderLoginScreen),
            GameScreenState.BOOK_SCREEN:  GameScreen(&updateBookScreen,  &renderBookScreen),
            GameScreenState.GAME_SCREEN:  GameScreen(&updateGameScreen,  &renderGameScreen),
        ];
    }

    ~this() {
        /* UnloadFont(font); */
    }

    void updateLoginScreen() {}
    void renderLoginScreen() {
        ClearBackground(Colors.WHITE);
    }

    void updateBookScreen() {}
    void renderBookScreen() {
        ClearBackground(Colors.WHITE);
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

        /* if (GuiButton(Rectangle(12, 100, 400, 96), "Click me")) { */
        /*     text = "Clicked!"; */
        /* } */

        /* if (text) DrawTextEx(font, text.toStringz, Vector2(12, 30), FONT_SIZE, 2, Colors.BLACK); */
    }
}

