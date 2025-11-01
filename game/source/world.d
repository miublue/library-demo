module world;
import std;
import raylib;
import config;
import player;

enum TileType {
    WALL,
    NPC,
}

struct Tile {
    Rectangle rect;
    TileType type;
}

class World {
    Vector2 player_pos;
    Tile[] tiles;
    Texture2D img;

    this(Vector2 pos_t, Tile[] tiles_t, string path_t) {
        player_pos = pos_t;
        tiles = tiles_t;
        img = LoadTexture(path_t.toStringz);
    }

    ~this() {
        UnloadTexture(img);
    }

    void render() {
        DrawTexture(img, 0, 0, Colors.WHITE);
    }
}

World loadWorldMap(string path) {
    Vector2 player_pos;
    Tile[] tiles;
    auto file = (path ~ ".txt").readText().split('\n');
    foreach (y, line; file) {
        foreach (x, tile; line) {
            if (tile == '.') continue;
            if (tile == 'P') {
                player_pos = Vector2(x*TILE_SIZE, y*TILE_SIZE);
                continue;
            }
            auto type = tile == 'X'? TileType.WALL : TileType.NPC;
            tiles ~= Tile(Rectangle(x*TILE_SIZE, y*TILE_SIZE, TILE_SIZE, TILE_SIZE), type);
        }
    }
    return new World(player_pos, tiles, path ~ ".png");
}

