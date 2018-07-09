<?php 
    // session_start();
    
    include "dbhelper.php"; //c# asp.net 
    $username= !isset($_POST["phone"]) ? "" : $_POST["phone"];
    $age= !isset($_POST["password"]) ? "" : $_POST["password"];

    $sql = "select * from stus where phone = '$username' and password = '$age'";

    $result = query_sql($sql);
    if(count($result) > 0){
        // 保存登录信息
        $_SESSION['phone'] = $username;
        echo "{status: true}";
    } else {
        echo "{status: false, message: '登录失败'}";
    }
?>