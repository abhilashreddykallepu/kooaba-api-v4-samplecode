Kooaba Android API v4 client
============================

Get your API keys by registering at http://platform.kooaba.com

Set the "key Id" and "secret token" in the `QueryTask` class in `MainActivity.java`.


Starting from the provided project
----------------------------------

In eclipse, go to `File -> Import -> Existing Projects into Workspace` and select the `kooaba-api-v4-samplecode/android` folder.

Run the application.  Select a picture from the gallery (make sure it's less than 2Mb).  The query results are dispayed on the screen.


Starting from an existing project
---------------------------------

 1. Add the `kooaba-api-v4-java.jar` file to the `lib` folder.
 2. Add the Internet Permission in your `AndroidManifest.xml`:

        <uses-permission android:name="android.permission.INTERNET"></uses-permission>

 3. Use the `QueryTask` class in `MainActivity.java` to asynchronously perform queries.

