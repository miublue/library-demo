module world;
import std;
import raylib;
import config;
import player;

enum TileType : uint {
    WALL,
    BOOKSHELF,
    NPC_RECEPTIONIST,
    NPC_PUMPKIN_GUY,
    NPC_GREEN_GUY,
    NPC_POETIC_KNIGHT,
    NPC_LAMP_HEAD,
    NPC_SLEEPY_ALIEN,
    NPC_SITTING_GUY,
    NPC_GHOST_GENTLEMAN,
    NUM_TILES,
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

    void render() {
        DrawTexture(img, 0, 0, Colors.WHITE);
    }
}

World loadWorldMap(string path) {
    Vector2 player_pos;
    Tile[] tiles, npcs, books;
    // adding npcs, books and tiles separately so i can make npcs priority on player interaction
    auto file = (path ~ ".txt").readText().split('\n');
    foreach (y, line; file) {
        foreach (x, tile; line) {
            if (tile == '.') continue;
            if (tile == 'P') {
                player_pos = Vector2(x*TILE_SIZE, y*TILE_SIZE);
                continue;
            }
            auto rect = Rectangle(x*TILE_SIZE, y*TILE_SIZE, TILE_SIZE, TILE_SIZE);
            TileType type = TileType.WALL;
            if (tile.isDigit)
                npcs ~= Tile(rect, ((tile-'0').to!int + TileType.NPC_RECEPTIONIST.to!int).to!TileType);
            else if (tile == 'B')
                books ~= Tile(rect, TileType.BOOKSHELF);
            else
                tiles ~= Tile(rect, type);
        }
    }
    return new World(player_pos, npcs ~ books ~ tiles, path ~ ".png");
}

