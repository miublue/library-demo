import std;
import raylib;
import config;
import game;

void main() {
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_TITLE.toStringz);
    scope (exit) CloseWindow();
    SetTargetFPS(FPS);
    SetExitKey(KEY_NULL);

    auto game = new Game();

    while (!WindowShouldClose()) {
        game.screens[game.screen].update();
        BeginDrawing();
        game.screens[game.screen].render();
        /* DrawFPS(10, 10); */
        EndDrawing();
    }
}
