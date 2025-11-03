module connection;
import std;
import config;
import client;

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

static BorrowedBookData invalidBorrowedBook() {
    BorrowedBookData book;
    book.id = 0;
    return book;
}

string humanReadableDate(DateTime date) {
    return format("%d/%d/%d", date.day, date.month, date.year);
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

Book[] getBorrowedBooks(User user) {
    Book[] ret_books;
    foreach (borrowed; user.borrowed_books)
        ret_books ~= getBookByID(borrowed.id);
    return ret_books;
}

BorrowedBookData getBorrowedBookByID(User user, BookID id) {
    foreach (book; user.borrowed_books) {
        if (book.id == id)
            return book;
    }
    return invalidBorrowedBook();
}

