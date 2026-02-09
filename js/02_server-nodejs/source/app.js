${{VAR_COPYRIGHT_HEADER}}

import express from "express";
import logger from "morgan";
import cookieParser from "cookie-parser";

var app = express();

app.use(logger(":date[iso] :remote-addr - :remote-user :method :url HTTP/:http-version :status :res[content-length]"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

// Serve the content of the 'public' directory
app.use(express.static("public"));

// Example API endpoint
app.get("/hello", function(req, res) {
    res.statusCode = 200;
    res.setHeader("Content-Type", "text/plain");
    res.send("${{VAR_PROJECT_SLOGAN_STRING}}");
});

// Create the server
var server = app.listen(8080, function() {
    const port = server.address().port;
    console.log("Listening on port %s", port);
})
