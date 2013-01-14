<?php

require_once("functions.php");

# setup config variables
$data_key = "<INSERT-DATA-KEY-HERE>";
$bucket_uuid = "<INSERT-BUCKET-ID-HERE>";
$url = "https://upload-api.kooaba.com/api/v4/buckets/" . $bucket_uuid . "/items";

# Image to update
$file_path = "../images/db_image.jpg";
$file_name = "db_image.jpg";
$title = "An image";
$metadata = "null";
$enabled = "true";
$reference_id = "r376466";

if (file_exists($file_path)) {
  $img = file_get_contents($file_path);
} else {
  die($file_path . ": File does not exist");
}

# Define boundary for multipart message
$boundary = uniqid();

# Construct the body of the request
$body  = image_part($boundary, "images", $file_name, $img);
$body .= text_part($boundary, "title", $title);
$body .= text_part($boundary, "metadata", $metadata);
$body .= text_part($boundary, "reference_id", $reference_id);
$body .= text_part($boundary, "enabled", $enabled);
$body .= "--" . $boundary . "--\r\n";

$context = stream_context_create(array(
              'http' => array(
                   'method' => 'POST',
                   'header' => 'Content-type: multipart/form-data; boundary=' . $boundary . "\r\n" .
                               'Authorization: Token ' . $data_key,
                   'content' => $body
                   )
              ));

$result = file_get_contents($url, false, $context);

echo "Result: ", $result;

?>
