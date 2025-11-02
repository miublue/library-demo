#!/bin/sh

# BOOK='{"total_amount":1,"title":"The Murder of Roger Ackroyd","author":"Agatha Christie","categories":["detective", "mystery"]}'

# curl -X POST -d "$BOOK" -H 'Content-Type: application/json' localhost:8000/books

curl -X POST -d '{"name":"Test"}' -H 'Content-Type: application/json' localhost:8000/users

# curl -X GET localhost:8000/books/1

# curl -X PUT -d '{"book_id":1}' -H 'Content-Type: application/json' localhost:8000/users/1/borrow

# curl -X PUT -d '{"book_id":1}' -H 'Content-Type: application/json' localhost:8000/users/1/return

# curl -X GET localhost:8000/books
# curl -X GET localhost:8000/users/1

