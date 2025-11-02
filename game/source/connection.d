module connection;
import config;
import client;

User getUserByName(string username) {
    try {
        auto users = getUsers();
        foreach (user; users) {
            if (user.name == username)
                return user;
        }
    } catch (Exception _) {}
    return User(username);
}

