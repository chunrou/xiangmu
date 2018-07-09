
$(function(){
    var pu = document.querySelector('.pu');
    var kuai = document.querySelector('.kuai');
    var query = document.querySelector('.query');
    var zhong = document.querySelector('.zhong');
    
    pu.onclick = function(){
        pu.style.backgroundColor = '#a10000';
        kuai.style.backgroundColor = '#f5f5f5';
        zhong.style.display = 'block';
        query.style.display = 'none';
    }
    kuai.onclick = function(){
        kuai.style.backgroundColor = '#a10000';
        pu.style.backgroundColor = '#f5f5f5';
        query.style.display = 'block';
        zhong.style.display = 'none';
    }


    var btn_l =document.getElementById('btn_login')
    btn_l.onclick = function(){
        var params = {
            password: document.getElementById('password').value,
            phone: document.getElementById('phone').value
        };
        console.log(params)
        $.ajax({
            api: 'http://localhost:94/php/login.php',
            params,
            method: 'post',
            success: function(res){
                console.log(res)
                var r = window.eval('(' + res + ')');
                if (r.status) {
                    window.location.href = 'http://localhost:94/src';
                }
            }
        })
    }

})


