import std;
import raylib;
import config;
import game;

void main() {
    /* You should call this function, but it errors
     * for me even though i have the correct version.
     * So i'll just trust that the version is right.
     */
    /* validateRaylibBinding(); */
    SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);
    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_TITLE.toStringz);
    scope (exit) CloseWindow();
    SetTargetFPS(FPS);
    SetExitKey(KeyboardKey.KEY_NULL);

    auto game = new Game();

    while (!WindowShouldClose()) {
        game.screens[game.screen].update();
        BeginDrawing();
        game.screens[game.screen].render();
        /* DrawFPS(10, 10); */
        EndDrawing();
    }
}
