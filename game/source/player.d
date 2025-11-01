import raylib;
import config;
import entity;

class Player : Entity {
    bool is_facing_left = false, is_facing_up = false, is_walking = false;
    int frame = 0, frame_counter = 0, animation_speed = 12, num_frames = 3;

    this(Vector2 pos) {
        super(pos, "./data/player.png", DEFAULT_SPEED);
    }

    void animate() {
        if (!is_walking) {
            img_rect.x = 0;
            frame = 0;
            return;
        }
        if (++frame_counter == animation_speed) {
            frame_counter = 0;
            ++frame;
        }
        if (frame == num_frames) frame = 1;
        img_rect.x = frame * TILE_SIZE;
    }

    override void update() {
        auto vel = Vector2(0, 0);
        if (IsKeyDown(KEY_LEFT)) {
            is_facing_left = true;
           vel.x = -1;
        }
        if (IsKeyDown(KEY_RIGHT)) {
            is_facing_left = false;
            vel.x = 1;
        }
        if (IsKeyDown(KEY_UP)) {
            is_facing_up = true;
            vel.y = -1;
        }
        if (IsKeyDown(KEY_DOWN)) {
            is_facing_up = false;
            vel.y = 1;
        }

        is_walking = (vel.x != 0 || vel.y != 0);
        img_rect.y = (is_facing_up)? TILE_SIZE : 0;
        img_rect.width = (is_facing_left)? -TILE_SIZE : TILE_SIZE;
        animate();
        move(vel);
    }
}
