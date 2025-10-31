package main

import (
    "time"
    "log"
    "os"
    "bytes"
    "fmt"
    "strconv"
    "encoding/json"
    "net/http"
    "github.com/gorilla/mux"
)

// I DONT HAVE TIME TO REFACTOR THIS CODE SO I SHALL LEAVE IT AS AN EXERCISE FOR THE READER

// XXX: i ain't gonna use SQL or anything fancy because i really don't care.
// leave that sort of stuff for the real programmers.

var books []Book
var users []User
var bookIdCounter BookID
var userIdCounter UserID

type BookID int
type UserID int

// no form of authentication (super secure!!)
type User struct {
    ID            UserID             `json:"id"`
    Name          string             `json:"name"`
    BorrowedBooks []BorrowedBookData `json:"borrowed_books"`
}

type BorrowedBookData struct {
    ID                 BookID `json:"book_id"`
    BorrowDate         string `json:"borrow_date"`
    ExpectedReturnDate string `json:"expected_return_date"`
}

type Book struct {
    ID          BookID   `json:"id"`
    TotalAmount int      `json:"total_amount"`
    Title       string   `json:"title"`
    Author      string   `json:"author"`
    Categories  []string `json:"categories"`
    BorrowerIDs []UserID `json:"borrower_ids"`
}

// I HATE THIS CODE DUPLICATION ITS DISGUSTING AAAAAA
// hopefully that's gonna be a problem for someone else

// PLAIN TEXT DATABASE (JSON) (super epic!!!11!1!!1!1!111!11)
func loadData() {
    text, err := os.ReadFile("users.json")
    if err != nil {
        log.Fatalf("Failed to read file: %v\n", err)
    }

    json.NewDecoder(bytes.NewBuffer(text)).Decode(&users)
    userIdCounter = UserID(len(users))

    text, err = os.ReadFile("books.json")
    if err != nil {
        log.Fatalf("Failed to read file: %v\n", err)
    }
    json.NewDecoder(bytes.NewBuffer(text)).Decode(&books)
    bookIdCounter = BookID(len(books))
}

func saveData() {
    data, err := json.Marshal(users)
    if err != nil {
        log.Fatalf("Failed to parse data: %v\n", err)
    }
    os.WriteFile("users.json", data, 0666)

    data, err = json.Marshal(books)
    if err != nil {
        log.Fatalf("Failed to parse data: %v\n", err)
    }
    os.WriteFile("books.json", data, 0666)
}

func dateToString(time time.Time) string {
    return fmt.Sprintf("%d-%d-%d-%d-%d-%d", time.Year(), time.Month(), time.Day(), time.Hour(), time.Minute(), time.Second())
}

func getUserFromID(id UserID) (int, *User) {
    for i, user := range users {
        if user.ID == id {
            return i, &user
        }
    }
    return 0, nil
}

// no idea how to use go. where are my goddamn macros???
func getBookFromID(id BookID) (int, *Book) {
    for i, book := range books {
        if book.ID == id {
            return i, &book
        }
    }
    return 0, nil
}

func createUser(w http.ResponseWriter, r *http.Request) {
    var user User
    json.NewDecoder(r.Body).Decode(&user)
    userIdCounter++
    user.ID = userIdCounter
    user.BorrowedBooks = []BorrowedBookData{}
    users = append(users, user)
    json.NewEncoder(w).Encode(user)
    saveData()
}

func getUsers(w http.ResponseWriter, r *http.Request) {
    json.NewEncoder(w).Encode(users)
}

func getUser(w http.ResponseWriter, r *http.Request) {
    params := mux.Vars(r)
    id, err := strconv.Atoi(params["id"])
    if err != nil {
        http.Error(w, "Invalid ID", http.StatusBadRequest)
        return
    }
    _, user := getUserFromID(UserID(id))
    if user != nil {
        json.NewEncoder(w).Encode(user)
        return
    }
    http.Error(w, "User not found", http.StatusNotFound)
}

func updateUser(w http.ResponseWriter, r *http.Request) {
    params := mux.Vars(r)
    id, err := strconv.Atoi(params["id"])
    if err != nil {
        http.Error(w, "Invalid ID", http.StatusBadRequest)
        return
    }
    i, user := getUserFromID(UserID(id))
    if user != nil {
        json.NewDecoder(r.Body).Decode(user)
        user.ID = UserID(id)
        users[i] = *user
        json.NewEncoder(w).Encode(user)
        saveData()
        return
    }
    http.Error(w, "User not found", http.StatusNotFound)
}

func borrowBookForUser(w http.ResponseWriter, user *User, idx int, bookID BookID) {
    bidx, book := getBookFromID(bookID)
    if book == nil {
        json.NewEncoder(w).Encode("Book does not exist")
        return
    }
    if len(book.BorrowerIDs) == book.TotalAmount {
        json.NewEncoder(w).Encode("Book not available")
        return
    }
    // NOTE: apparently you can only borrow books for 7 days here.
    // you should be able to expand the date once after the 7 days are over,
    // but that's not my problem.
    borrowDate := time.Now()
    expectedReturnDate := borrowDate.AddDate(0, 0, 7)
    borrowData := BorrowedBookData{bookID, dateToString(borrowDate), dateToString(expectedReturnDate)}
    user.BorrowedBooks = append(user.BorrowedBooks, borrowData)
    users[idx] = *user

    book.BorrowerIDs = append(book.BorrowerIDs, user.ID)
    books[bidx] = *book
    // json.NewEncoder(w).Encode(borrowData)
    json.NewEncoder(w).Encode("Success")
    saveData()
}

func returnBookForUser(w http.ResponseWriter, user *User, idx int, bookID BookID) {
    bidx, book := getBookFromID(bookID)
    var foundBookInUser, foundUserInBook bool
    if book == nil {
        http.Error(w, "Invalid ID", http.StatusBadRequest)
        return
    }
    // remove bookID from user borrowedBooks
    for i, id := range user.BorrowedBooks {
        if id.ID == bookID {
            foundBookInUser = true
            user.BorrowedBooks = append(user.BorrowedBooks[:i], user.BorrowedBooks[i+1:]...)
            break
        }
    }
    if !foundBookInUser {
        json.NewEncoder(w).Encode("User has no book with this ID")
        return
    }
    // remove userID from book borrowerIDs
    for i, id := range book.BorrowerIDs {
        if id == user.ID {
            foundUserInBook = true
            book.BorrowerIDs = append(book.BorrowerIDs[:i], book.BorrowerIDs[i+1:]...)
            break
        }
    }
    if !foundUserInBook {
        json.NewEncoder(w).Encode("User not found in book's data")
        return
    }
    users[idx] = *user
    books[bidx] = *book
    json.NewEncoder(w).Encode("Success")
    saveData()
}

func performUserAction(w http.ResponseWriter, r *http.Request) {
    params := mux.Vars(r)
    id, err := strconv.Atoi(params["id"])
    if err != nil {
        http.Error(w, "Invalid ID", http.StatusBadRequest)
        return
    }
    action := params["action"]
    i, user := getUserFromID(UserID(id))
    if user != nil {
        var bookID BorrowedBookData
        json.NewDecoder(r.Body).Decode(&bookID)
        switch action {
        case "borrow":
            borrowBookForUser(w, user, i, bookID.ID)
            break
        case "return":
            returnBookForUser(w, user, i, bookID.ID)
            break
        default:
            http.Error(w, "Invalid action", http.StatusBadRequest)
            return
        saveData()
        }
    }
    http.Error(w, "User not found", http.StatusNotFound)
}

func deleteUser(w http.ResponseWriter, r *http.Request) {
    params := mux.Vars(r)
    id, err := strconv.Atoi(params["id"])
    if err != nil {
        http.Error(w, "Invalid ID", http.StatusBadRequest)
        return
    }
    i, user := getUserFromID(UserID(id))
    if user != nil {
        users = append(users[:i], users[i+1:]...)
        json.NewEncoder(w).Encode("Success")
        saveData()
        return
    }
    http.Error(w, "User not found", http.StatusNotFound)
}

func createBook(w http.ResponseWriter, r *http.Request) {
    var book Book
    json.NewDecoder(r.Body).Decode(&book)
    bookIdCounter++
    book.ID = bookIdCounter
    book.BorrowerIDs = []UserID{}
    books = append(books, book)
    json.NewEncoder(w).Encode(book)
    saveData()
}

func getBooks(w http.ResponseWriter, r *http.Request) {
    json.NewEncoder(w).Encode(books)
}

func getBook(w http.ResponseWriter, r *http.Request) {
    params := mux.Vars(r)
    id, err := strconv.Atoi(params["id"])
    if err != nil {
        http.Error(w, "Invalid ID", http.StatusBadRequest)
        return
    }
    _, book := getBookFromID(BookID(id))
    if book != nil {
        json.NewEncoder(w).Encode(book)
        return
    }
    http.Error(w, "Book not found", http.StatusNotFound)
}

func updateBook(w http.ResponseWriter, r *http.Request) {
    params := mux.Vars(r)
    id, err := strconv.Atoi(params["id"])
    if err != nil {
        http.Error(w, "Invalid ID", http.StatusBadRequest)
        return
    }
    i, book := getBookFromID(BookID(id))
    if book != nil {
        json.NewDecoder(r.Body).Decode(book)
        book.ID = BookID(id)
        books[i] = *book
        json.NewEncoder(w).Encode(book)
        saveData()
        return
    }
    http.Error(w, "Book not found", http.StatusNotFound)
}

func deleteBook(w http.ResponseWriter, r *http.Request) {
    params := mux.Vars(r)
    id, err := strconv.Atoi(params["id"])
    if err != nil {
        http.Error(w, "Invalid ID", http.StatusBadRequest)
        return
    }
    i, book := getBookFromID(BookID(id))
    if book != nil {
        books = append(books[:i], books[i+1:]...)
        json.NewEncoder(w).Encode("Success")
        saveData()
        return
    }
    http.Error(w, "Book not found", http.StatusNotFound)
}

func initializeRouter() {
    router := mux.NewRouter()

    router.HandleFunc("/books",      createBook).Methods("POST")
    router.HandleFunc("/books",      getBooks).Methods("GET")
    router.HandleFunc("/books/{id}", getBook).Methods("GET")
    router.HandleFunc("/books/{id}", updateBook).Methods("PUT")
    router.HandleFunc("/books/{id}", deleteBook).Methods("DELETE")

    router.HandleFunc("/users",      createUser).Methods("POST")
    router.HandleFunc("/users",      getUsers).Methods("GET")
    router.HandleFunc("/users/{id}", getUser).Methods("GET")
    router.HandleFunc("/users/{id}", updateUser).Methods("PUT")
    router.HandleFunc("/users/{id}/{action}", performUserAction).Methods("PUT")
    router.HandleFunc("/users/{id}", deleteUser).Methods("DELETE")
    fmt.Println("Starting up server on localhost:8000")
    log.Fatal(http.ListenAndServe(":8000", router))
}

func main() {
    loadData()
    initializeRouter()
}
