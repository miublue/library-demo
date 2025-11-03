module connection;
import std;
import config;
import client;

struct BookInfo {
    BookID id;
    string title, author;
    DateTime borrow_date;
    DateTime expected_return_date;
}

static User invalidUser() {
    User user;
    user.id = 0;
    return user;
}

static Book invalidBook() {
    Book book;
    book.id = 0;
    return book;
}

User getUserByID(UserID id) {
    try {
        auto users = getUsers();
        foreach (user; users) if (user.id == id) return user;
    } catch (Exception _) {}
    return invalidUser();
}

Book getBookByID(BookID id) {
    try {
        auto books = getBooks();
        foreach (book; books) if (book.id == id) return book;
    } catch (Exception _) {}
    return invalidBook();
}

User getUserByName(string username) {
    try {
        auto users = getUsers();
        foreach (user; users) {
            if (user.name == username)
                return user;
        }
    } catch (Exception _) {}
    return invalidUser();
}

Book getBookByNameOrAuthor(string word) {
    try {
        auto books = getBooks();
        foreach (book; books) {
            if (book.title.toLower.canFind(word.toLower) || book.author.toLower.canFind(word.toLower))
                return book;
        }
    } catch (Exception _) {}
    return invalidBook();
}

Book[] getBooksByNameOrAuthor(string word) {
    try {
        auto books = getBooks();
        Book[] ret_books;
        foreach (book; books) {
            if (book.title.toLower.canFind(word.toLower) || book.author.toLower.canFind(word.toLower))
                ret_books ~= book;
        }
        return ret_books;
    } catch (Exception _) {}
    return [];
}

Book[] getBooksByCategory(string category) {
    try {
        auto books = getBooks();
        Book[] ret_books;
        foreach (book; books) {
            if (book.categories.canFind(category))
                ret_books ~= book;
        }
        return ret_books;
    } catch (Exception _) {}
    return [];
}

BookInfo[] getBorrowedBooks(User user) {
    BookInfo[] ret_books;
    foreach (borrowed; user.borrowed_books) {
        auto book = getBookByID(borrowed.id);
        auto info = BookInfo(book.id, book.title, book.author, borrowed.borrow_date, borrowed.expected_return_date);
        ret_books ~= info;
    }
    return ret_books;
}

