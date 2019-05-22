app.ports.setSessionCredentials.subscribe(user => {
    const timestamp = user.userID !== -1 ?
        (+new Date()) :
        0;

    localStorage.setItem('userID', user.userID);
    localStorage.setItem('sessionName', user.sessionName);
    localStorage.setItem('expiry', user.expiry);
    localStorage.setItem('lastLogin', timestamp);
    localStorage.setItem('currentLogin', timestamp);

    // Send back into Elm to set the populate the session upon a new login!
    app.ports.getSessionCredentials.send({
        userID: Number(localStorage.getItem('userID')) || 0,
        sessionName: localStorage.getItem('sessionName') || '',
        expiry: localStorage.getItem('expiry') || '',
        lastLogin: Number(localStorage.getItem('lastLogin')) || 0,
        currentLogin: timestamp
    });
});

app.ports.getSessionCredentials.send({
    userID: Number(localStorage.getItem('userID')) || 0,
    sessionName: localStorage.getItem('sessionName') || '',
    expiry: localStorage.getItem('expiry') || '',
    lastLogin: Number(localStorage.getItem('lastLogin')) || 0,
    currentLogin: (+new Date())
});

