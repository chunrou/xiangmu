/* 
* @Author: Marte
* @Date:   2018-07-08 20:21:32
* @Last Modified by:   Marte
* @Last Modified time: 2018-07-08 22:42:22
*/

$(function(){
    if(document.cookie){ // 存在cookie
        $('.shopping').show()
        // 提取数据
        var cookie = document.cookie.split('; ');
        console.log(cookie)
        var pay = 0;
        var allNumber = 0;
        for(var i=0; i<cookie.length; i++){
            var arr = cookie[i].split('=')[1].split('&');
            pay+=arr[3]*1;
            allNumber+=arr[2]*1;
            var data = {
                id: arr[0],
                name: arr[1],
                number: arr[2],
                danY: arr[3]/arr[2],
                allY: arr[3],
                src: arr[4],
            }
            // <input type="checkbox">
            $('.tian>ul').append(`
                <li id='${data.id}&${data.name}&${data.src}'>
                   <span></span>
                   <span><img src="${data.src}" alt="">${data.name}</span>
                   <span>s</span>
                   <span>￥${data.allY}</span>
                   <span class='click_i' danY='${data.danY}'>
                       <i>-</i>
                       <i>${data.number}</i>
                       <i>+</i>
                   </span>
                   <span>-</span>
                   <span>￥${data.danY}</span>
                   <span class='del'>删除</span>
                </li>
            `)
        }
        $('#shuliang').text(allNumber)
        $('#qian').text('￥'+pay+'.00')
        // 数据以及cookie修改
        $('.click_i').on("click","i",function(){
            // 数量html
            var numHtml = $(this).parent().find('i:nth-of-type(2)');
            var allY = $(this).parent().prev(); // 总价元素
            var num = numHtml.text()*1;
            var danjia = $(this).parent().attr('danY')*1;
            var data = $(this).parent().parent().attr('id').split('&');
            // console.log(data)

            if($(this).text()=='-' && num>1){
                change(-1, data)
            } else if($(this).text()=='+'){
                change(1, data)
            }
            function change(n, data){
                numHtml.text(num+n)
                allNumber+=n;
                $('#shuliang').text(allNumber)
                pay+=danjia*n
                $('#qian').text('￥'+pay+'.00')
                allY.text('￥'+danjia*(num+n))
                // 覆盖旧cookie
                document.cookie = `${data[0]}=${data[0]}&${data[1]}&${num+n}&${danjia*(num+n)}&${data[2]}`;
            }
        })
        // 删除
        $('.del').click(function(){
            var id = $(this).parent().attr('id').split('&')[0]
            // 删除元素
            $(this).parent().remove();
            $('.shop').show()
            $('.shopping').hide()
            // 删除cookie
            var CookieNum = document.cookie.split('; ');
            for(var i=0; i<CookieNum.length; i++){
                var data = CookieNum[i].split('=');
                if(data[0] == id){
                    var date = new Date();
                    date.setDate(date.getDate()-10);
                    document.cookie = `${CookieNum[i]};expires=${date}`
                }
            }
        })
    } else { // 不存在cookie
        $('.shop').show()
    }
});