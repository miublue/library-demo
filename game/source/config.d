module config;
import raylib;

const auto WINDOW_TITLE = "Bookstore";
const auto WINDOW_WIDTH = 1600;
const auto WINDOW_HEIGHT = 900;

const auto FPS = 60;
const auto SCROLL_SPEED = 30;
const auto DEFAULT_SPEED = 6;
const auto CAMERA_ZOOM = 4;
const auto TILE_SIZE = 64;

const auto FONT_SIZE = 30;
const auto FONT_PATH = "data/Lato-Regular.ttf";
const auto FONT_SPACING = 2;
const auto FONT_CODEPOINTS = 1000;

const auto COLOR_TEXT   = Color( 12,  12,  12, 255);
const auto COLOR_BORDER = Color( 79,  77,  70, 255);
const auto COLOR_WINDOW = Color(237, 232, 208, 255);
const auto COLOR_BUTTON = Color(201, 197, 177, 255);
const auto COLOR_ENTRY  = Color(201, 197, 177, 255);

const string[string] GUI_TEXT;

static this() {
    GUI_TEXT = [
        "login": "Login",
        "enter": "Entrar",
        "user_name": "Usuário",
        "user_books": "Meus livros",
        "login_failed": "Falha ao entrar",
        "getbooks_failed": "Falha ao carregar livros",
        "book_title": "Título",
        "book_author": "Autor",
        "book_categories": "Categoria",
        "book_amount": "Quantidade",
        "book_available": "Disponível",
        "book_borrow": "Emprestar",
        "book_return": "Devolver",
        "book_borrow_date": "Emprestado",
        "book_return_date": "Devolver até",
    ];
}
