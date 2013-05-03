package com.kooaba;

import java.io.IOException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.Map;

public class Query {

    public static void main(String[] args) throws InvalidKeyException, NoSuchAlgorithmException, IOException {
        // If you want your image to be recognized, it must be added to your reference items: https://platform.kooaba.com/items 
        String imageFile = "../images/query_image.jpg";

        // Get your query API keys at: https://platform.kooaba.com/querykeys
        // Initialize a KooabaApi object with "KA" authentication over http.
        KooabaApi kooaba = new KooabaApi("<key_id>", "<secret_token>");

        // or initialize a KooabaApi object with "Token" authentication over https.
        //KooabaApi kooaba = new KooabaApi("<secret_token>");

        // Execute a simple query.
        //kooaba.query(imageFile);

        // Execute a query passing additional parameters.
        Map<String, String> params = new HashMap<String, String>();
        params.put("max_results", "1");
        params.put("user_data", "{\"user_id\": \"Any string can be used here.\"}");
        kooaba.query(imageFile, params);

        // Print the response to console.
        System.out.println("HTTP Status: " + kooaba.getResponseStatus());
        System.out.println("HTTP Response: " + kooaba.getResponseBody());
    }
}