<?php 
    include "dbhelper.php";
    $sql = "select * from picture where url != '.'";
    $result = query_sql($sql);
    echo json_encode($result)
?>