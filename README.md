# Library Demo

Some library game that's actually a frontend for an actual library system.

<img src="https://i.imgur.com/NE3OlhU.png" width="400" align="left" />
<img src="https://i.imgur.com/WJbBDBy.png" width="400" />
<img src="https://i.imgur.com/sR1nyAQ.png" width="400" align="left" />
<img src="https://i.imgur.com/Up1bkwf.png" width="400" />

## Yapping

I was told to come up with some "interesting" way to organize some books and
automate the process of borrowing/returning said books.

My little group wanted to make a game because yes, but I also wanted it to
actually work (apparently that wasn't really needed, we just had to come up
with an interesting enough demo/presentation). I couldn't figure out how to
integrate it with excel (because it would've been so much easier to just
automate it with excel, but alas) so I decided to write the system myself.

It consists of a server with a text-based database (because I didn't have time
to learn or use SQL), and a client that connects to it through libcurl.

## Backend

The backend is a simple go server I wrote in ~3 hours that uses a JSON-based
database and mux. It has a separate books.json and users.json because it was just
easier to implement it that way.

## Frontend

The frontend is a game looking thing that took >90% of the time of the whole project
to make, and was also the hardest because of certain technical difficulties (Mainly
miscommunication lmfao).

I tried writing the client in a couple of different languages (languages that would
be easier to implement the game in), but everything failed so I kinda gave up and
used the godly language, [Dlang](https://dlang.org) with
[libcurl](https://dlang.org/library/std/net/curl.html) for the client, and
[raylib](https://www.raylib.com/) for the graphics.

The game is not really needed for the system to work. In fact, it'd actually be less
convenient to have to borrow the books from a game.

I personally think it'd be nicer to have a mobile app with a QR code inside the book's
cover that you scan to automagically borrow it, and another QR code at the library to
return it.

(Or just write your name and the borrow date on a sheet of paper, really)

Unfortunately I didn't have the time for adding an options menu so there is no way
to configure the keybinds, font size or language (everything is in portuguese, ew).

No safety precautions have been taken for anything in the program, and users
have no password or any sort of authentication, but that is not my problem
because this is just a demo and I'm really not paid for that.

## Building
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

Then (on a new terminal) start the game:
```
cd game
dub build
./library_game
```

## How to play

There isn't really any gameplay. Here's a list of what you can do:

* You can create a new user in the login screen (button "criar conta") and login into the library.
* You can interact with the NPCs using the spacebar.
* You can access the books by interacting with any bookshelf.
* You can search for books, borrow or return them.

