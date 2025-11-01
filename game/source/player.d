import std;
import raylib;
import config;
import world;

struct Player {
public:
    Rectangle rect;
    Texture2D img;
    int speed = DEFAULT_SPEED;

private:
    Rectangle _img_rect, _collision_rect;

    bool _is_facing_left = false,
         _is_facing_up = false,
         _is_walking = false;

    int _frame = 0,
        _frame_counter = 0,
        _animation_speed = 12,
        _num_frames = 3;

public:
    this(Vector2 pos) {
        img = LoadTexture("./data/player.png".toStringz);
        rect = Rectangle(pos.x, pos.y, TILE_SIZE, TILE_SIZE);
        _img_rect = Rectangle(0, 0, TILE_SIZE, TILE_SIZE);
        _collision_rect = Rectangle(rect.x+18, rect.y+32, 25, 32);
    }

    ~this() {
        UnloadTexture(img);
    }

    void moveAndCollide(World world, Vector2 dir) {
        rect.x += speed * dir.x;
        _collision_rect.x += speed * dir.x;
        foreach (tile; world.tiles) {
            if (CheckCollisionRecs(_collision_rect, tile.rect)) {
                rect.x -= speed * dir.x;
                _collision_rect.x -= speed * dir.x;
            }
        }
        rect.y += speed * dir.y;
        _collision_rect.y += speed * dir.y;
        foreach (tile; world.tiles) {
            if (CheckCollisionRecs(_collision_rect, tile.rect)) {
                rect.y -= speed * dir.y;
                _collision_rect.y -= speed * dir.y;
            }
        }
    }

    void update(World world) {
        auto vel = Vector2(0, 0);
        if (IsKeyDown(KEY_LEFT)) {
            _is_facing_left = true;
            vel.x = -1;
        }
        if (IsKeyDown(KEY_RIGHT)) {
            _is_facing_left = false;
            vel.x = 1;
        }
        if (IsKeyDown(KEY_UP)) {
            _is_facing_up = true;
            vel.y = -1;
        }
        if (IsKeyDown(KEY_DOWN)) {
            _is_facing_up = false;
            vel.y = 1;
        }

        _is_walking = (vel.x != 0 || vel.y != 0);
        _img_rect.y = (_is_facing_up)? TILE_SIZE : 0;
        _img_rect.width = (_is_facing_left)? -TILE_SIZE : TILE_SIZE;
        animate();
        moveAndCollide(world, vel);
    }

    private void animate() {
        if (!_is_walking) {
            _img_rect.x = 0;
            _frame = 0;
            return;
        }
        if (++_frame_counter == _animation_speed) {
            _frame_counter = 0;
            ++_frame;
        }
        if (_frame == _num_frames) _frame = 1;
        _img_rect.x = _frame * TILE_SIZE;
    }

    void render() {
        DrawTextureRec(img, _img_rect, Vector2(rect.x, rect.y), Colors.WHITE);
    }
}
