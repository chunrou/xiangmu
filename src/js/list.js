/* 
* @Author: Marte
* @Date:   2018-07-06 16:22:23
* @Last Modified by:   Marte
* @Last Modified time: 2018-07-07 18:12:24
*/

$(function(){
    var weizhi = document.querySelector('.weizhi');
    var list = document.querySelector('.list');
    var nan = document.querySelector('.nan');
    // console.log(list);
    weizhi.onclick = function(){
        list.style.display = "block";
        nan.style.display = "none";
    }

    // console.log($('.dian'))
    $('.dian').click(function(){
        $('.ipt').css('border','1px solid #ccc');
        $('.kong').show();
        $('.que').show();
    })


    $.ajax({
        type: 'POST',
        url: "http://localhost:94/php/list.php",
        // data: {id:1},
        dataType: "json",
        contentType: "application/x-www-form-urlencoded; charset=utf-8",
        success: function(data){
            console.log(data)
            for(var i=0; i<data.length; i++){
                $(".picture").append(
                `<li>
                <a href="html/xiangqing.html?id=${data[i].id}">
                    <img src="${data[i].url}" alt="" />
                    <p>凡客衬衫 易打理 宽松复古开领 男款2 蓝青宽条</p>
                </a>
                <span>售价￥${data[i].price}</span>
                </li>`
                )
            }
             
        }

    });



})