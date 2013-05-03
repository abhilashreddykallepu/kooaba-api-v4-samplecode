package com.kooaba;

import java.io.IOException;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.provider.MediaStore;
import android.view.Menu;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends Activity {

    private static final int SELECT_PICTURE = 1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);

        Toast.makeText(getApplicationContext(), "Please select a query image.", Toast.LENGTH_LONG).show();

        Intent intent = new Intent();
        intent.setType("image/*");
        intent.setAction(Intent.ACTION_GET_CONTENT);
        startActivityForResult(Intent.createChooser(intent, "Select Picture"), SELECT_PICTURE);

    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == RESULT_OK) {
            if (requestCode == 1) {
                new QueryTask(this).execute(getPath(data.getData()));
            }
        }
    }

    public String getPath(Uri uri) {
        String[] projection = { MediaStore.Images.Media.DATA };
        @SuppressWarnings("deprecation")
        Cursor cursor = managedQuery(uri, projection, null, null, null);
        int column_index = cursor
                .getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
        cursor.moveToFirst();
        return cursor.getString(column_index);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }
}

class QueryTask extends AsyncTask<String, Integer, Object> {

    private Activity activity;
    private KooabaApi kooaba;
    private TextView tv; 

    public QueryTask(Activity activity) {
        this.activity = activity;
        this.kooaba = new KooabaApi("<key_id>", "<secret_token>");
        this.tv = (TextView)this.activity.findViewById(R.id.text);
    }

    protected void onPreExecute() {
        tv.append("\n\n");
        tv.append("Recognizing image... ");
    }

    protected Long doInBackground(String... paths) {
        String imagePath = paths[0];

        try {
            kooaba.query(imagePath);
        } catch (InvalidKeyException e) {
            e.printStackTrace();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return null;
    }

    protected void onPostExecute(Object result) {
        tv.append("Done.\n\n");
        tv.append("HTTP Status: " + kooaba.getResponseStatus() + "\n");
        tv.append("HTTP Response: " + kooaba.getResponseBody() + "\n");
    }
}
