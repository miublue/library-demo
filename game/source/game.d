module game;
import std;
import raylib;
/* import raygui; */
import config;
import client;
import connection;
import player;
import world;
import menu;

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
    GameScreenState screen = GameScreenState.LOGIN_SCREEN;
    GameScreen[GameScreenState] screens;

    Camera2D camera;
    World world;
    Player player;

    Menu login_menu,
         game_menu,
         book_menu,
         dialog_menu;

    Book[] books_data;
    User user;

    string[] book_categories;
    Book[][string] books_by_category;
    string current_category, search_book;
    Book expand_info;
    bool show_user_books;

    this() {
        world = loadWorldMap("./data/biblioteca");
        player = Player(world.player_pos);

        setupGameMenu();
        setupLoginMenu();
        setupBookMenu();
        setupDialogMenu();

        camera.zoom = CAMERA_ZOOM;
        camera.rotation = 0;

        screens = [
            GameScreenState.LOGIN_SCREEN: GameScreen(&updateLoginScreen, &renderLoginScreen),
            GameScreenState.BOOK_SCREEN:  GameScreen(&updateBookScreen,  &renderBookScreen),
            GameScreenState.GAME_SCREEN:  GameScreen(&updateGameScreen,  &renderGameScreen),
        ];
    }

    void setupGameMenu() {
        game_menu = new Menu(Rectangle(0, 0, 200, 40));
        game_menu.addComponent(new Label(Vector2(5, 5), LabelAlignment.LEFT, GUI_TEXT["user_name"]));
    }

    void setupLoginMenu() {
        login_menu = new Menu(Rectangle(WINDOW_WIDTH/2 - 300, WINDOW_HEIGHT/2 - 100, 600, 200));
        login_menu.addComponent(new Label(Vector2(300, 10), LabelAlignment.CENTER, GUI_TEXT["login"]));
        login_menu.addComponent(new Label(Vector2(10, 65), LabelAlignment.LEFT, GUI_TEXT["user_name"]));
        immutable size = MeasureTextEx(login_menu.font, GUI_TEXT["user_name"].toStringz, FONT_SIZE, FONT_SPACING);
        auto login = delegate(UIComponent _) {
            auto ent = cast(Entry*)(&login_menu.components[2]);
            if (!ent.text.length) return;
            user = getUserByName(ent.text);
            if (user.id != 0) {
                user = getUserByName(ent.text);
                game_menu.components[0].text ~= ": " ~ user.name;
                screen = GameScreenState.BOOK_SCREEN;
            } else {
                login_menu.components[0].text = GUI_TEXT["login_failed"];
                ent.is_selected = true;
                ent.text_pos = 0;
                ent.text = "";
            }
        };
        login_menu.addComponent(new Entry(Rectangle(20+size.x, 60, 600-size.x-30, 40), "", login));
        login_menu.addComponent(new Button(Rectangle(10, 130, 580, 40), GUI_TEXT["enter"], login));
        login_menu.components[2].is_selected = true;
    }

    void setupBookMenu() {
        book_menu = new Menu(Rectangle(0, 0, WINDOW_WIDTH-20, WINDOW_HEIGHT-20));
        try {
            books_data = getBooks();
            foreach (book; books_data) {
                foreach (category; book.categories) {
                    if (!book_categories.canFind(category)) {
                        book_categories ~= category;
                        books_by_category[category] = [];
                    }
                    books_by_category[category] ~= book;
                }
            }
            book_menu.addComponent(new Entry(Rectangle(10, FONT_SIZE+20, book_menu.rect.width-20, FONT_SIZE), "", delegate(UIComponent ent) {
                show_user_books = false;
                search_book = ent.text;
                expand_info.id = 0;
                book_menu.scroll_y = 0;
                ent.text = "";
            }));

            current_category = book_categories[0];
            float x_off = 10;
            foreach (category; book_categories) {
                immutable size = MeasureTextEx(book_menu.font, category.toStringz, FONT_SIZE, FONT_SPACING);
                book_menu.addComponent(new Button(Rectangle(x_off, 10, size.x+10, FONT_SIZE), category, delegate(UIComponent btn) {
                    expand_info.id = 0;
                    current_category = (cast(Button)btn).text;
                    search_book = "";
                    show_user_books = false;
                }));
                x_off += size.x+10;
            }
            immutable size = MeasureTextEx(book_menu.font, GUI_TEXT["user_books"].toStringz, FONT_SIZE, FONT_SPACING);
            book_menu.addComponent(new Button(Rectangle(x_off, 10, size.x+10, FONT_SIZE), GUI_TEXT["user_books"], delegate(UIComponent btn) {
                expand_info.id = 0;
                search_book = "";
                show_user_books = true;
            }));
        } catch (Exception _) {
            book_menu.addComponent(new Label(Vector2(10, 10), LabelAlignment.LEFT, GUI_TEXT["getbooks_failed"]));
        }
    }

    void setupDialogMenu() {
        dialog_menu = new Menu(Rectangle(10, WINDOW_HEIGHT-350, WINDOW_WIDTH-20, 340));
        dialog_menu.addComponent(new Label(Vector2(10, 10), LabelAlignment.LEFT, ""));
    }

    void updateLoginScreen() {
        login_menu.rect.x = GetScreenWidth()/2 - login_menu.rect.width/2;
        login_menu.rect.y = GetScreenHeight()/2 - login_menu.rect.height/2;
    }

    void renderLoginScreen() {
        ClearBackground(Colors.BLACK);
        login_menu.render();
    }

    void updateBookScreen() {
        book_menu.rect = Rectangle(10, 10, GetScreenWidth()-20, GetScreenHeight()-20);
        float x_off = 10, y_off = 10;
        foreach (component; book_menu.components) {
            if (x_off+component.rect.width >= book_menu.rect.width) {
                x_off = 10;
                y_off += FONT_SIZE+10;
            }
            component.off_rect.x = x_off;
            component.off_rect.y = y_off;
            x_off += component.rect.width+10;
        }
    }

    void addBooksToMenu(float offset, Book[] books) {
        foreach (i, book; books) {
            immutable y_pos = offset+(FONT_SIZE+10)*i;
            book_menu.addComponent(new Label(Vector2(10, y_pos), LabelAlignment.LEFT, book.title));
            book_menu.components[$-1].onClick = delegate(UIComponent lbl) {
                book_menu.scroll_y = 0;
                expand_info = getBookByNameOrAuthor(lbl.text);
            };
        }
    }

    void renderBookScreen() {
        ClearBackground(Colors.BLACK);
        book_menu.components.length = book_categories.length+2;
        book_menu.components[0].rect.width = book_menu.rect.width-20;
        float y_off = book_menu.components[$-1].rect.y + book_menu.components[$-1].rect.height;

        if (expand_info.id != 0) {
            immutable title = GUI_TEXT["book_title"] ~ ": " ~ expand_info.title;
            immutable author = GUI_TEXT["book_author"] ~ ": " ~ expand_info.author;
            immutable categories = GUI_TEXT["book_categories"] ~ ": " ~ expand_info.categories.join(", ");
            immutable amount = GUI_TEXT["book_amount"] ~ ": " ~ expand_info.total_amount.to!string;
            immutable available = GUI_TEXT["book_available"] ~ ": " ~ (expand_info.total_amount-expand_info.borrower_ids.length).to!string;
            immutable has_book = user.borrowed_books.map!(b => b.id).array().canFind(expand_info.id);
            immutable button_text = (has_book)? GUI_TEXT["book_return"] : GUI_TEXT["book_borrow"];
            book_menu.addComponent(new Label(Vector2(10, y_off+(FONT_SIZE+10)*0), LabelAlignment.LEFT, title));
            book_menu.addComponent(new Label(Vector2(10, y_off+(FONT_SIZE+10)*1), LabelAlignment.LEFT, author));
            book_menu.addComponent(new Label(Vector2(10, y_off+(FONT_SIZE+10)*2), LabelAlignment.LEFT, categories));
            book_menu.addComponent(new Label(Vector2(10, y_off+(FONT_SIZE+10)*3), LabelAlignment.LEFT, amount));
            book_menu.addComponent(new Label(Vector2(10, y_off+(FONT_SIZE+10)*4), LabelAlignment.LEFT, available));
            book_menu.addComponent(new Button(Rectangle(10, y_off+(FONT_SIZE+10)*5, 300, FONT_SIZE), button_text, delegate(UIComponent _) {
                if (has_book) returnBook(user.id, expand_info.id);
                else borrowBook(user.id, expand_info.id);
                user = getUser(user.id);
                expand_info = getBook(expand_info.id);
            }));
            if (has_book) {
                immutable book = getBorrowedBookByID(user, expand_info.id);
                immutable borrow_date = GUI_TEXT["book_borrow_date"] ~ ": " ~ book.borrow_date.humanReadableDate();
                immutable return_date = GUI_TEXT["book_return_date"] ~ ": " ~ book.expected_return_date.humanReadableDate();
                book_menu.addComponent(new Label(Vector2(10, y_off+(FONT_SIZE+10)*6), LabelAlignment.LEFT, borrow_date));
                book_menu.addComponent(new Label(Vector2(10, y_off+(FONT_SIZE+10)*7), LabelAlignment.LEFT, return_date));
            }
        } else if (show_user_books) {
            auto books = getBorrowedBooks(user);
            addBooksToMenu(y_off, books);
        } else if (search_book != "") {
            auto books = getBooksByNameOrAuthor(search_book);
            addBooksToMenu(y_off, books);
        } else {
            addBooksToMenu(y_off, books_by_category[current_category]);
        }
        book_menu.render();
    }

    void updateGameScreen() {
        dialog_menu.rect.width = GetScreenWidth()-20;
        dialog_menu.rect.y = GetScreenHeight()-350;
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
        game_menu.render();
    }
}

