import std;
import raylib;

const auto WINDOW_TITLE = "Bookstore";
const auto WINDOW_WIDTH = 1600;
const auto WINDOW_HEIGHT = 900;
const auto FPS = 60;

struct Player {
    Rectangle rect;
    int speed;
    Color color;
}

void main() {
    auto player = Player(Rectangle(120, 120, 64, 64), 12, Colors.RED);

    InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_TITLE.toStringz);
    scope (exit) CloseWindow();
    SetTargetFPS(FPS);
    while (!WindowShouldClose()) {
        BeginDrawing();
        ClearBackground(Colors.BLACK);
        if (IsKeyDown(KEY_LEFT))  player.rect.x -= player.speed;
        if (IsKeyDown(KEY_RIGHT)) player.rect.x += player.speed;
        if (IsKeyDown(KEY_UP))    player.rect.y -= player.speed;
        if (IsKeyDown(KEY_DOWN))  player.rect.y += player.speed;
        DrawRectangleRec(player.rect, player.color);
        EndDrawing();
    }
}
