package jampfiler.client;

import java.io.ByteArrayInputStream;

import javafx.stage.Stage;
import javafx.scene.Scene;
import javafx.scene.text.Font;
import javafx.io.http.HttpRequest;
import javafx.scene.control.ProgressBar;
import javafx.scene.layout.VBox;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.control.Button;
import javafx.geometry.VPos;
import javafx.scene.control.Label;
import javafx.io.http.HttpHeader;
import javafx.scene.control.TextBox;
import javafx.scene.layout.HBox;

import javax.swing.JFileChooser;
import javafx.scene.shape.Rectangle;
import javafx.scene.paint.Paint;
import javafx.scene.paint.Color;

/**
 * @author Alex Siman
 */

// TODO: Maximum "Content-Length" size allowed (to avoid DoS attacks): Default is 1Gb or 2Mb.
// TODO: Drag-n-Drop files for uploading.
// TODO: Image files preview (thumbnails).
// TODO: ListView of files for uploading with "remove" action on every file.
// TODO: j18n.
// TODO: Image editing (rotate, cut...)? (y)

// TODO: Get uploading URL from GUI text input.
//def uploadUrl = "http://localhost:8080/Rentshop/FileUploadServlet";

var toRead : Long = 0;
var read : Long = 0;

var toWrite : Long = 0;
var written : Long = 0;

function uploadFile(inputFiles: java.io.File[]) {
    var content = FileUtils.computeFileUploadContent(inputFiles);
//    println("mimeBuffer: {Arrays.toString(mimeBuffer)}");

    def postRequest: HttpRequest = HttpRequest {
        location: urlTextBox.text
        method: HttpRequest.POST
        headers: [
            HttpHeader {
                name: HttpHeader.CONTENT_TYPE;
                value: "{content.contentType}";
            },
            HttpHeader {
                name: HttpHeader.CONTENT_LENGTH;
                value: "{content.content.length}";
            }
        ];

        source: new ByteArrayInputStream(content.content)

        onStarted: function() { println("onStarted"); }
        onConnecting: function() { println("onConnecting") }
        onDoneConnect: function() { println("onDoneConnect") }
        onReadingHeaders: function() { println("onReadingHeaders") }
        onResponseCode: function(code : Integer) { println("onResponseCode - {code}") }
        onResponseMessage: function(msg : String) { println("onResponseMessage - {msg}") }

        onReading: function() { println("onReading") }

        onToRead: function(bytes: Long) {
            toRead = bytes;
            println("onToRead({bytes})");
        }

        onRead: function(bytes: Long) {
            read = bytes;
            println("onRead({bytes}) - {read * 100/toRead}%");
        }

        onWriting: function() { println("onWriting") }

        onToWrite: function(bytes: Long) {
            toWrite = bytes;
            println("onToWrite({bytes})");
        }

        onWritten: function(bytes: Long) {
            written = bytes;
            println("onWritten({bytes}) - {written * 100/toWrite}%");
        }

        onException: function(ex: java.lang.Exception) {
            println("onException - {ex}");
        }

        onDoneRead: function() { println("onDoneRead") }
        onDoneWrite: function() { println("onDoneWrite") }
        onDone: function() { println("onDone") }
    }

    postRequest.start();
}

/**
 * Client
 */

var urlLabel = Label {
    text: "Upload URL: "
    layoutInfo: LayoutInfo {height: 30}
};

var urlTextBox = TextBox {
    text: "http://localhost:8080/FileUploadServlet"
    layoutInfo: LayoutInfo {width: 200 height: 30}
};

var urlPanel = HBox {
    spacing: 10
    content: [urlLabel, urlTextBox]
};

var label = Label {
    font : Font { size : 12 }
    //text: bind "Uploaded - {written * 100/(toWrite + 1)}%"
    layoutInfo: LayoutInfo { vpos: VPos.CENTER height: 30 }
}

var button = Button {
    text: "Select files & Upload"
    layoutInfo: LayoutInfo {width: 300 height: 30}
    action: function() {
        var fileChooser = new JFileChooser();
        fileChooser.setMultiSelectionEnabled(true);

//        // Note: source for ExampleFileFilter can be found in FileChooserDemo,
//        // under the demo/jfc directory in the Java 2 SDK, Standard Edition.
//        ExampleFileFilter filter = new ExampleFileFilter();
//        filter.addExtension("jpg");
//        filter.addExtension("gif");
//        filter.setDescription("JPG & GIF Images");
//        chooser.setFileFilter(filter);

        var inputFile = fileChooser.showOpenDialog(null);
        if(inputFile == JFileChooser.APPROVE_OPTION) {
            var selectedFile = fileChooser.getSelectedFile();
            var selectedFiles = fileChooser.getSelectedFiles();
            var selectedFilesStr: String = java.util.Arrays.toString(fileChooser.getSelectedFiles());
            println("Selected file: {selectedFile.getAbsolutePath()}");
            println("Selected files: {selectedFilesStr}");

            uploadFile(selectedFiles);
            toWrite = 0;
            written = 0;
        }
    }
}

var progressBar = ProgressBar {
    progress: bind (written/((toWrite + 1) as Number))
    layoutInfo: LayoutInfo {width: 300 height: 30}
}

var vBox = VBox {
    spacing: 10
    content: [urlPanel, button, /*label,*/ progressBar]
    translateX: 10
    translateY: 10
}

Stage {
    title: "JampFiler"
    width: 400
    height: 200
    scene: Scene {
        content: [
            vBox
            /*HBox {
                content: [
                    Button {
                        layoutInfo: LayoutInfo {
                                width: 100
                                height: 50
                        }
                    }
                    TextBox {
                        text: "1) http://localhost:8080/FileUploadServlet"
                        width: 400
                    }
                    Rectangle { width: 400 height: 20 }
                    Button {layoutInfo: LayoutInfo {width: 400 height: 20}}
                ]
            }
            TextBox {
                text: "2) http://localhost:8080/FileUploadServlet"
                width: 400
            }
            Rectangle {
                y: 200
                width: 400
                height: 200
                fill: Color.GREEN
                stroke: Color.BLUE
                strokeWidth: 2.0
            }*/
        ]
    }
//    resizable: false
}