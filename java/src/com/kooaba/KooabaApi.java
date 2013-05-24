package com.kooaba;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.InvalidKeyException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.codec.binary.Hex;

public class KooabaApi {

    private static final String QUERY_HOST = "query-api.kooaba.com";
    private static final String QUERY_PATH = "/v4/query";

    private static final String MULTIPART_BOUNDARY = "----------ThIs_Is_tHe_bouNdaRY_";
    private static final String CRLF = "\r\n";

    private String keyId;
    private String secretToken;
    private String authenticationMethod;

    private int responseStatus = -1;
    /**Get the http status code of the last API request.*/
    public int getResponseStatus() {return this.responseStatus;}

    private String responseBody = null;
    /**Get the http response of the last API request.*/
    public String getResponseBody() {return this.responseBody;}

    public KooabaApi(String keyId, String secretToken) {
        this.keyId = keyId;
        this.secretToken = secretToken;
        this.authenticationMethod = "KA";
    }

    public KooabaApi(String secretToken) {
        this.secretToken = secretToken;
        this.authenticationMethod = "Token";
    }

    private String sign(String verb, byte[] content, String contentType, String date, String requestPath) throws NoSuchAlgorithmException, InvalidKeyException, IllegalStateException, UnsupportedEncodingException {
        MessageDigest md = MessageDigest.getInstance("MD5");
        byte[] thedigest = md.digest(content);
        String md5sum = new String(Hex.encodeHex(thedigest));

        String message = verb + "\n" + md5sum + "\n" + contentType + "\n" + date + "\n" + requestPath;
        String signature = signHmacSha1(secretToken, message);
        return signature;
    }

    public String query(String imagePath) throws IOException, NoSuchAlgorithmException, InvalidKeyException {
        String response = "";
        Map<String, String> params = new HashMap<String, String>();
        response = query(imagePath, params);
        return response;
    }

    public String query(String imagePath, Map<String, String> params) throws IOException, NoSuchAlgorithmException, InvalidKeyException {
        this.responseStatus = -1;
        this.responseBody = null;

        byte[] requestBody = createMultipartRequest(imagePath, params);

        final String dateStr = getDateRfc1123();
        String contentType = "multipart/form-data";

        HttpURLConnection conn = (HttpURLConnection) (new URL(getQueryUrl())).openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setDoInput(true);

        conn.setRequestProperty("Content-Type", contentType + "; boundary=" + MULTIPART_BOUNDARY);
        conn.setRequestProperty("Authorization", getAuthorizationHeader(this.authenticationMethod, "POST", requestBody, contentType, dateStr, QUERY_PATH));
        conn.setRequestProperty("Accept", "application/json; charset=utf-8");
        conn.setRequestProperty("Date", dateStr);

        // Write the body of the request
        conn.getOutputStream().write(requestBody);

        return readHttpResponse(conn);
    }

    private String readHttpResponse(HttpURLConnection conn) throws IOException {
        InputStream is = null;
        try {
            is = conn.getInputStream();
            this.responseStatus = ((HttpURLConnection)conn).getResponseCode();
        } catch (IOException e) {
            try {
                this.responseStatus = ((HttpURLConnection)conn).getResponseCode();
                is = ((HttpURLConnection)conn).getErrorStream();
            } catch(IOException ex) {
                throw ex;
            }
        }

        BufferedReader bin = new BufferedReader(new InputStreamReader(is));

        StringBuilder sb = new StringBuilder();
        String inputLine;
        while ((inputLine = bin.readLine()) != null)
            sb.append(inputLine);
        bin.close();

        this.responseBody = sb.toString();
        return this.responseBody;
    }


    private String getAuthorizationHeader(String authenticationMethod, String verb, byte[] requestBody, String contentType, String date, String queryPath) throws InvalidKeyException, NoSuchAlgorithmException, IllegalStateException, UnsupportedEncodingException {
        String auth = null;
        if("Token".equals(authenticationMethod)) {
            auth = "Token " + secretToken;
        } else if ("KA".equals(authenticationMethod)) {
            auth = "KA " + keyId + ":" + sign("POST", requestBody, contentType, date, QUERY_PATH);
        }

        return auth;
    }

    private String getQueryUrl() {
        String protocol = "KA".equals(this.authenticationMethod) ? "http://" : "https://";
        return protocol + QUERY_HOST + QUERY_PATH;
    }

    private byte[] createMultipartRequest(String imagePath, Map<String, String> params) throws IOException {
        ByteArrayOutputStream bodyOutputStream = new ByteArrayOutputStream();

        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            sb.append("--" + MULTIPART_BOUNDARY + CRLF);
            sb.append("Content-Disposition: form-data; name=\"" + entry.getKey() + "\"" + CRLF);
            sb.append(CRLF);
            sb.append(entry.getValue());
            sb.append(CRLF);
        }

        sb.append("--" + MULTIPART_BOUNDARY + CRLF);
        sb.append("Content-Disposition: form-data; name=\"image\"" + CRLF);
        sb.append("Content-Type: appliation/octet-stream" + CRLF);
        sb.append(CRLF);

        bodyOutputStream.write(sb.toString().getBytes());
        writeFileToOutputStream(new File(imagePath), bodyOutputStream);
        bodyOutputStream.write((CRLF + "--" + MULTIPART_BOUNDARY + "--").getBytes());

        return bodyOutputStream.toByteArray();
    }

    private static String signHmacSha1(String key, String message) throws NoSuchAlgorithmException, InvalidKeyException, IllegalStateException {
        SecretKeySpec keySpec = new SecretKeySpec(key.getBytes(), "HmacSHA1");
        Mac mac = Mac.getInstance("HmacSHA1");
        mac.init(keySpec);
        byte[] result = mac.doFinal(message.getBytes());

        return new String(Base64.encodeBase64(result));
    }

    private static String getDateRfc1123() {
        String RFC1123_DATE_PATTERN = "EEE, dd MMM yyyy HH:mm:ss zzz";
        SimpleDateFormat dateFormat = new SimpleDateFormat(RFC1123_DATE_PATTERN, Locale.US);
        dateFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
        return dateFormat.format(new Date());
    }

    private void writeFileToOutputStream(File f, final OutputStream out) throws IOException {
        if (out == null) {
            throw new IllegalArgumentException("Output stream may not be null");
        }
        InputStream in = new FileInputStream(f);
        try {
            byte[] tmp = new byte[4096];
            int l;
            while ((l = in.read(tmp)) != -1) {
                out.write(tmp, 0, l);
            }
            out.flush();
        } finally {
            in.close();
        }
    }
}
