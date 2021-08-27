#!/usr/bin/env python3

import os
import subprocess
import web

urls = (
    "/", "index",
    "/api/node/([_a-zA-Z0-9]+)", "node",
    "/api/link/([_a-zA-Z0-9]+)/([_a-zA-Z0-9]+)", "link",
)
app = web.application(urls, globals())

class index:
    CSS = """
.edge {
    stroke-width: 5px;
}

.on {
    fill: green;
}

.off {
    fill: red;
}
    """

    JS = """

function refreshNode() {
    var node = $(this);

    $.get({ url: "/api/node/" + node.text(), success: function (data) {
    	node.removeClass(["on", "off"]);
    	node.addClass(data);
    }});
}

function toggleNode() {
    var self = this;
    var node = $(this);

    var state = node.hasClass("off") ? "on" : "off";

    $.ajax({ method: "PUT", url: "/api/node/" + node.text(), data: { state: state }, success: function (data) {
    	self.refreshState();
    }});
}

function toggleLink() {
    var self = this;
    var node = $(this).parent().find("text:first-of-type")
    var link = $(this);

    var state = link.hasClass("off") ? "on" : "off";

    $.ajax({ method: "PUT", url: "/api/link/" + node.text() + "/" + link.text(), data: { state: state }, success: function (data) {
    	link.removeClass(["on", "off"]);
    	link.addClass(state);
    }});
}

$(function () {
    $(".node text:first-of-type").each(function () {
	if ($(this).text() == "host")
		return;

    	this.refreshState = refreshNode;

    	this.refreshState();
    });

    $(".node text:first-of-type").on("click", toggleNode);
    $(".node text:not(:first-of-type)").on("click", toggleLink);
});
    """


    def GET(self):
        title = os.path.basename(os.getcwd())

        try:
            svg = subprocess.run(["dot", "-Tsvg", "topology.dot"],
                                 encoding="utf-8", capture_output=True,
                                 timeout=3, check=True).stdout
        except:
            svg = "Unable to generate topology SVG"

        return """
        <!DOCTYPE html>
        <html>
        <head>
        	<meta charset="utf-8">
        	<style>{style}</style>
        	<title>{title}</title>
        </head>
        <body>
		<h1>{title}</h1>
		{svg}
	</body>
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script>{script}</script>
        </html>
        """.format(style=index.CSS, title=title, svg=svg, script=index.JS)

class node:
    def GET(self, name):
        web.header('Content-Type', 'text/plain')
        try:
            subprocess.run("kill -0 $(cat {node}.pid)".format(node=name), shell=True, timeout=1, check=True)
            return "on"
        except:
            return "off"

    def PUT(self, name):
        web.header('Content-Type', 'text/plain')

        data = web.input()

        if "state" not in data:
            raise ValueError

        if data.state == "on":
            op = "start"
        elif data.state == "off":
            op = "stop"
        else:
            raise ValueError

        subprocess.run(["qeneth", op, name], timeout=3, check=True)

class link:
    def PUT(self, node, name):
        web.header('Content-Type', 'text/plain')

        data = web.input()

        if "state" not in data:
            raise ValueError

        subprocess.run(["qeneth", "link", node, name, data.state], timeout=3, check=True)

if __name__ == "__main__":
    app.run()
