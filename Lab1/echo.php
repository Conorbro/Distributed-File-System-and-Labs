<?php
      if(isset($_GET['source'])) {
        if ($_GET['source'] == "raw")
           echo file_get_contents(basename($_SERVER['PHP_SELF']));
        else
           echo "<pre>" . htmlspecialchars(file_get_contents(basename($_SERVER['PHP_SELF']))) . "</pre>";
      } else if (isset($_GET['message'])){
        echo strtoupper( htmlspecialchars($_GET['message'])) . '\n';
      } else {
        echo "No message received!"
      }
?>
