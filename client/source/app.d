module client;
import std.stdio;
import std.string;
import std.format;
import std.array;
import std.algorithm;
import std.conv;
import std.json;
import std.net.curl;
import std.datetime;

alias UserID = long;
alias BookID = long;

const auto URL = "localhost:8000";

struct User {
    string name;
    BorrowedBookData[] borrowed_books = [];
    UserID id = 0;

    string toJSON() {
        return format(`{"id":%d,"name":"%s","borrowed_books":%s}`,
                id, name, borrowed_books.map!(v => v.toJSON()).array);
    }
}

struct BorrowedBookData {
    BookID id;
    DateTime borrow_date;
    DateTime expected_return_date;

    string toJSON() {
        return format(`{"id":%d,"borrow_date":"%s","expected_return_date":"%s"}`,
                id, borrow_date.dateToString, expected_return_date.dateToString);
    }
}

struct Book {
    string title;
    string author;
    string[] categories;
    int total_amount;
    UserID[] borrower_ids = [];
    BookID id = 0;

    string toJSON() {
        return format(`{"id":%d,"total_amount":%d,"title":"%s","author":"%s","categories":%s,"borrower_ids":%s}`,
                id, total_amount, title, author, categories, borrower_ids);
    }
}

// date format: (yy-mm-dd-HH-MM-SS)
DateTime dateFromString(string str) {
    auto nums = str.split('-').map!(s => s.to!int).array();
    return DateTime(nums[0], nums[1], nums[2], nums[3], nums[4], nums[5]);
}

string dateToString(DateTime time) {
    return format("%d-%d-%d-%d-%d-%d", time.year, time.month, time.day, time.hour, time.minute, time.second);
}

BorrowedBookData parseBorrowedBookData(JSONValue json) {
    BorrowedBookData data;
    data.id = json["book_id"].integer;
    data.borrow_date = dateFromString(json["borrow_date"].str);
    data.expected_return_date = dateFromString(json["expected_return_date"].str);
    return data;
}

User parseUser(JSONValue json) {
    User user;
    user.id = json["id"].integer;
    user.name = json["name"].str;
    user.borrowed_books = json["borrowed_books"].array.map!(v => v.parseBorrowedBookData).array();
    return user;
}

Book parseBook(JSONValue json) {
    Book book;
    book.id = json["id"].integer;
    book.total_amount = json["total_amount"].integer.to!int;
    book.title = json["title"].str;
    book.author = json["author"].str;
    book.categories = json["categories"].array.map!(v => v.str).array();
    book.borrower_ids = json["borrower_ids"].array.map!(v => v.integer).array();
    return book;
}

UserID createUser(string name) {
    auto data = `{"name":"` ~ name ~ `"}`;
    auto json = parseJSON(post(format("%s/users", URL), data));
    return json["id"].integer;
}

User[] getUsers() {
    auto json = parseJSON(get(format("%s/users", URL)));
    return json.array.map!(v => v.parseUser()).array();
}

User getUser(UserID id) {
    auto json = parseJSON(get(format("%s/users/%d", URL, id)));
    return parseUser(json);
}

void deleteUser(UserID id) {
    del(format("%s/users/%d", URL, id));
}

bool borrowBook(UserID user, BookID book) {
    auto json = parseJSON(put(format("%s/users/%d/borrow", URL, user), format(`{"book_id":%d}`, book)));
    return json.str == "Success";
}

bool returnBook(UserID user, BookID book) {
    auto json = parseJSON(put(format("%s/users/%d/return", URL, user), format(`{"book_id":%d}`, book)));
    return json.str == "Success";
}

Book createBook(Book book) {
    auto data = book.toJSON();
    auto json = parseJSON(post(format("%s/books", URL), data));
    return parseBook(json);
}

Book[] getBooks() {
    auto json = parseJSON(get(format("%s/books", URL)));
    return json.array.map!(v => v.parseBook()).array();
}

Book getBook(BookID id) {
    auto json = parseJSON(get(format("%s/books/%d", URL, id)));
    return parseBook(json);
}

/* void main() { */
    /* createUser("Test"); */

    /* borrowBook(1, 1); */
    /* returnBook(1, 1); */

    /* writeln(getUsers()); */
    /* writeln(getBooks()); */
/* } */
