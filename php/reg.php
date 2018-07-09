<?php 
    //引用 php 文件
    include 'dbhelper.php';
    
    $pwd = !isset($_POST["password"]) ? "" : $_POST["password"];
    $age = !isset($_POST["phone"]) ? "" : $_POST["phone"];
    //判断当前注册的用户是否存在，如果存在则不能再次注册
    $sql = "select * from stus where phone = '$age'"; 
    $result = query_sql($sql);
    if(count($result) > 0) {
        echo "用户名已注册";
    } else{
           $sql = "insert into stus(phone, password) values('$age', '$pwd')";   
            $result = exec_sql($sql);
        if($result){
            echo "注册成功";
        }else {
            echo "注册失败";
        }
    }
  
?>