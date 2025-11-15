# Library Demo

I was told to come up with some "interesting" way to organize some books
and automate the process of borrowing/returning said books (for whatever reason).

My little group wanted to make a game because yes, and I couldn't figure out
how to integrate it with excel (because it would've been so much easier to just
automate it with excel, but alas) so I had to write the system myself.

It consists of a server with a text-based database (because I didn't have time
to learn or use SQL), and a client that connects to it through libcurl.

The backend is a simple go server I wrote in ~3 hours that uses a JSON-based
database and mux. It has a separate books.json and users.json because it was easier
to implement it that way.

The frontend is a game looking thing that I half-assed due to my lack of time
and my going insane because the level files were a complete mess and literally
unusable and every single sprite being a separate file even though I had asked
for a tilesheet multiple times and none of the libraries I tried using to make
my life easier working so I had to write almost everything from scratch and I'm
so not paid enough for this shit.

I tried connecting to the server a couple of different times but I just couldn't
get the client to work nicely so I kinda gave up and used the godly language, Dlang
with libcurl for the client, and raylib for the graphics.

The game is not really needed for the system to work. In fact, it'd actually be more
inconvenient to have to borrow the books from a game.

I personally think it'd actually be nicer to have a mobile app with a QR code inside
the book's cover that you scan to automagically borrow it, and another QR code at
the library to return it.

(Or just write your name and the borrow date on a sheet of paper)

Unfortunately I didn't have the time for adding an options menu so there is no way
to configure the keybinds, font size or language (everything is in portuguese, ew).

No safety precautions have been taken for anything in the program, and users
have no password or any sort of authentication, but that is not my problem
because this is just a demo and I'm really not paid for that.

# Building
This thing was only made for a demonstration and completely abandoned afterwards.
I have no idea if it would build on anyone else's computer, or if anyone would
even want to play with this. But anyways...

Dependencies:
* Git
* A Go compiler (>= 1.25.x)
* A D compiler (only tested with dmd 2.1x)
* [DUB](https://github.com/dlang/dub) (>= 1.27.x)
* Raylib (>= 5.0.x)
* Libcurl

(You may need to put raylib and curl DLLs on the game directory if on windows)

First start up the server:
```
cd server
go build
./library_server
```

Then start the game:
```
cd game
dub build
./library_game
```

