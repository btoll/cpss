app.ports.setSessionCredentials.subscribe(user => {
    localStorage.setItem('user', user.user);

    // Send back into Elm to set the populate the session upon a new login!
    app.ports.getSessionCredentials.send({
        user: Number(localStorage.getItem('user')) || -1
    });
});

app.ports.getSessionCredentials.send({
    user: Number(localStorage.getItem('user')) || -1,
});

