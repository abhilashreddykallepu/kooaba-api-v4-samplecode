# kooaba api v4 - php

The two scripts in this directory show how you can use php to upload and query items using the kooaba API.

## Prerequisites

To use the scripts you first need an account on the [kooaba platform](https://platform.kooaba.com/). There is a free plan so go ahead and do this if you haven't already.

For more documentation on the platform see [http://kooaba.github.com/](http://kooaba.github.com/).

## Uploading an item

The _upload.php_ script allows you to upload `items` to your account. An item has one or more images.

Modify the config variables in the script:

   `$data_key` - you need a `data-key` and a `bucket-id` which the bucket you want to put images into. The `data-key` you can find on your account on the [kooaba platform, data keys section](https://platform.kooaba.com/datakeys/). You need to use the `secret-token` string. The `bucket-id` you can find on [Reference Items section](https://platform.kooaba.com/items/).

   `bucket_uuid` - The id of the bucket you want to put the image into.

   `file_path` - The path to the image on the local filesystem.

   `title` - The title of the item.

   `metadata` - The metadata of an item. It should be a valid JSON string.

   `enabled` - Weather item should be available for recognition immediately. Defaults to "true".

Run the script with:

    php upload.php

You should see something like this:

    Result: {"uuid":"05b5e75e-a7cf-496b-9bf8-83bfa3fb39ef","enabled":true,"images":[{"sha1":"057c10bba45e37a0c079cf2eb6ed1389e4e00615"}]}

The result is in JSON format.


## Making a query

You can query against your uploaded items. Use _query.php_ for this.

Modify the config variables in the script:

   `$query_key` - to make queries with the kooaba API, you need a `query-key`. The `query-key` can be found on your account on [kooaba platform, query keys section](https://platform.kooaba.com/querykeys). You need to use the `secret-token` string.

   `$file_path` - path to the local image to query with.

Run the script with:

    php upload.php

The result will be a JSON string:

    Result: {"query_id":"ca465e7c38c8481ea798a9471912c48a","results":[{"item_uuid":"05b5e75e-a7cf-496b-9bf8-83bfa3fb39ef","bucket_uuid":"108695a2-7825-4a98-8bda-b980782c5e33","service_id":"object_retrieval","score":0.777778,"recognitions":[{"score":0.777778,"id":"image.sha1:057c10bba45e37a0c079cf2eb6ed1389e4e00615","reference_projection":[{"x":1128.413452,"y":-164.773743},{"x":-100.0,"y":-39.0},{"x":-94.0,"y":242.0},{"x":281.0,"y":243.0}],"bounding_box":[{"x":15.0,"y":17.0},{"x":15.0,"y":172.0},{"x":232.0,"y":172.0},{"x":232.0,"y":17.0}]}],"metadata":null,"title":"An image","reference_id":"r376466"},{"item_uuid":"b8bdfe2d-5310-4e67-8294-b6c4bc224d5e","bucket_uuid":"108695a2-7825-4a98-8bda-b980782c5e33","service_id":"object_retrieval","score":0.777778,"recognitions":[{"score":0.777778,"id":"image.sha1:057c10bba45e37a0c079cf2eb6ed1389e4e00615","reference_projection":[{"x":1128.413452,"y":-164.773743},{"x":-100.0,"y":-39.0},{"x":-94.0,"y":242.0},{"x":281.0,"y":243.0}],"bounding_box":[{"x":15.0,"y":17.0},{"x":15.0,"y":172.0},{"x":232.0,"y":172.0},{"x":232.0,"y":17.0}]}],"metadata":null,"title":"An image"}]}

## Troubleshooting

Make sure you have configured php to use the openssl and `allow_url_encode = On` in your `php.ini`.
You can use this snippet to see if you have configured ssl:

    $w = stream_get_wrappers();
    echo 'openssl: ',  extension_loaded  ('openssl') ? 'yes':'no', "\n";
    echo 'http wrapper: ', in_array('http', $w) ? 'yes':'no', "\n";
    echo 'https wrapper: ', in_array('https', $w) ? 'yes':'no', "\n";
    echo 'wrappers: ', var_dump($w);
