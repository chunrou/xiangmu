<?php 
    include "dbhelper.php";
    $id = !isset($_POST["id"]) ? "" : $_POST["id"];
    // mysql_query('set names utf8');
    $sql = $id == "" ? "select * from yidali" : "select * from yidali where id = '$id'";
    $result = query_sql($sql);
    if(count($result) > 0){
        echo json_encode($result);
        // echo "'阿萨德我会尽快'";
    } else {
        echo "{status: false, message: '商品已失效'}";
    }
?>