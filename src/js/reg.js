$(function(){
    var yan = document.querySelector('.yan');
    var yan_w = document.querySelector('.yan_w');
    var btn = document.querySelector('.btn');
    var tel = document.querySelector('.tel');
    var paw = document.querySelector('.paw');
    var paw2 = document.querySelector('.paw2');
    var checkbox = document.querySelector('#checkbox');
    

    // 验证码
    function code(){

        res = '';
        var str = '0123456789ABCDEF';
        for(var i =0;i<6;i++){
           res += str[parseInt(Math.random()*str.length)];
        }

        yan.innerHTML = res;
    }
    code();
        // 点击重新生成验证码
        yan.onclick = function(){
            code();
        }

        // 登录验证
            btn.onclick = function(){
                var _yan_w  = yan_w.value;    
                var _tel  = tel.value;
                var _paw  = paw.value; 
                var _paw2  = paw2.value;
                var _checkbox = checkbox.checked;
                if(!_yan_w) alert('请输入验证码')
                else if(!_tel) alert('请输入手机号码')
                else if(!_paw ) alert('请输入密码')   
                else if(_paw  != _paw2) alert('密码不一致')
                else if(!_checkbox) alert('请阅读服务条款')
                else if(_yan_w === res){
                    var params = {
                        password: _paw,
                        phone: _tel,
                    }
                    console.log(_paw,_tel)
                    $.ajax({
                        api: 'http://localhost:94/php/reg.php',
                        method: 'post',
                        params,
                        success: function(res){
                            console.log(res);
                            var txt = JSON.parse(JSON.stringify(res))
                            alert(txt)
                        }
                    })
                    
                }
                else{
                alert('验证码错误');}
            }
})