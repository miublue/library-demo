#!/usr/bin/env python3
from dataclasses import dataclass

@dataclass
class Book:
    id: int
    title: str
    author: str
    categories: list[str]
    total_amount = 1

    def dump_json(self) -> str:
        return f'{{"id":{self.id},"title":"{self.title}","author":"{self.author}","categories":{list_to_str(self.categories)},"total_amount":{self.total_amount},"borrower_ids":[]}}'

def list_to_str(lst: list) -> str:
    res = '['
    for itm in lst:
        if itm != lst[0]: res += ', '
        res += '\"' + itm + '\"'
    return res + ']'

books: list[Book] = []
current_genres: list[str]
book_id_counter: int = 0
text: str

with open('books.txt') as f:
    text = f.read()

for line in text.split('\n'):
    if not line: continue
    if line.startswith('# '):
        current_genres = line.split('# ')[1].split(', ')
        continue

    book_id_counter += 1

    title = line.split(' - ')[0]
    author = line.split(' - ')[1]

    book = Book(book_id_counter, title, author, current_genres)
    books.append(book)

s = '['
for book in books:
    s += book.dump_json()
    if book != books[-1]: s += ','
s += ']'

with open('books.json', 'w') as f:
    f.write(s)


