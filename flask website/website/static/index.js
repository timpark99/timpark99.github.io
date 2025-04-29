function deleteNote(noteID) {
    fetch('/delete-note', {     // to send a request in vanilla javascript you use fetch
        method: 'POST',
        body: JSON.stringify({ noteId: noteID})
    }).then((_res) => {
        window.location.href = "/";     // redirect us to the homepage
    });
}


