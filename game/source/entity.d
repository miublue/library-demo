module entity;
import std;
import raylib;
import config;

class Entity {
    Texture2D img;
    Rectangle rect, img_rect;
    int speed = DEFAULT_SPEED;

    this(Vector2 pos, string path, int speed) {
        img = LoadTexture(path.toStringz);
        rect = Rectangle(pos.x, pos.y, TILE_SIZE, TILE_SIZE);
        img_rect = Rectangle(0, 0, TILE_SIZE, TILE_SIZE);
    }

    ~this() {
        UnloadTexture(img);
    }

    void move(Vector2 dir) {
        rect.x += speed * dir.x;
        rect.y += speed * dir.y;
    }

    void move_to(Vector2 pos) {
        move(Vector2(pos.x < rect.x? -1 : 1, pos.y < rect.y? -1 : 1));
    }

    void render() {
        // XXX: negative width flips image
        DrawTextureRec(img, img_rect, Vector2(rect.x, rect.y), Colors.WHITE);
    }

    void update() {}
}

