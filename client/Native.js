// For image upload feature.
const reader = f =>
    new Promise((resolve) => {
        const reader = new FileReader();

        // FileReader API is event based. Once a file is selected it fires events.
        // We hook into the `onload` event for our reader.
        reader.onload = e =>
            // We build up the object here that will be passed to our Elm runtime
            // through the `fileContentRead` subscription.
            resolve({
                contents: e.target.result,              // The `target` is the file that was selected, and
                filename: f.filename                    // the result is base64 encoded contents of the file.
            });

        // Connect our FileReader with the file that was selected in our `input` node.
        reader.readAsDataURL(f.fileObject);
    });

app.ports.fileSelected.subscribe(fuploadCls => {
    const els = document.querySelectorAll(`.${fuploadCls}`);
    let files = [];

    els.forEach(el => {
        const fs = el.files;

        if (fs.length) {
            files.push({
                // Concat the `id` value (banner, logo or icon) with the file extension.
                filename: `${el.id}.${fs[0].name.replace(/.*(jpg|gif|png)/, '$1')}`,
                fileObject: fs[0]
            });
        }
    });

    Promise.all(files.map(reader))
    .then(app.ports.fileContentRead.send)      // We call the `fileContentRead` port with the file data
    .catch(console.error);                     // which will be sent to our Elm runtime via Subscriptions.
});

