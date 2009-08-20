package jampfiler.client;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import javax.activation.DataHandler;
import javax.activation.FileDataSource;
import javax.mail.internet.InternetHeaders;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMultipart;

/**
 * @author Alex Siman
 */
public class FileUtils {
    public static class Content {
        byte[] content;
        String contentType;
    }

    public static Content computeFileUploadContent(File[] uploadFiles) 
            throws Exception {
        MimeMultipart multiPart = new MimeMultipart("form-data");
        for (File file : uploadFiles) {

            /*
             * FIXME: Remove "Content-Type" hardcode. See JavaMail & JAF.
             * FIXME: Define content type by file extension? (y)
             * Create ContentTypeUtil based on "tomcat/conf/web.xml" mime-mapping +
             * if file has no ext then content type is "application/octet-stream" +
             * load ext-to-mime in "mime.properties" as do mime-utils.
             */

            // v1: Bad: hardcoded Content-Type.
            InputStream fileInputStream = new FileInputStream(file);
            MimeBodyPart mimeBodyPart = new MimeBodyPart(fileInputStream);
            mimeBodyPart.setDisposition("form-data; name=\"file\"; filename=" + file.getName());
            mimeBodyPart.addHeader("Content-Type", "image/jpeg");

            // v2: Bad: Content-Type is null.
//            FileDataSource dataSource = new FileDataSource(file);
//            MimeBodyPart mimeBodyPart = new MimeBodyPart();
//            mimeBodyPart.setDisposition("form-data; name=\"file\"; filename=" + file.getName());
//            mimeBodyPart.setDataHandler(new DataHandler(dataSource));

            multiPart.addBodyPart(mimeBodyPart);
        }

        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        multiPart.writeTo(stream);

        Content c = new Content();
        c.content = stream.toByteArray();
        c.contentType = multiPart.getContentType();

        return c;
    }
}
