$(function(){
   
    var demo=document.getElementById("demo");
    var samll=document.getElementById("small-box");
    var mark=document.getElementById("mark");
    var lfoat=document.getElementById("float-box");
    var bigbox=document.getElementById("big-box");
    var jiaru=document.getElementById("jiaru");
    var bigboximg=bigbox.getElementsByTagName("img")[0];

    // 购物车总数量显示
    if(document.cookie){
        var CookieNum = document.cookie.split('; ');
        var allNum = 0;
        for(var i=0; i<CookieNum.length; i++){
            allNum+=CookieNum[i].split('=')[1].split('&')[2]*1;
        }
        $('#nunnn').text(allNum)
    }

    //给小盒子添加事件，移入和移出--------------------------
    //移入：浮动的box和和bigBox显示
    samll.onmouseover=function(){
        lfoat.style.display="block";
        bigbox.style.display="block";
    }
    //移除：浮动的box和bigBox隐藏
    samll.onmouseout=function(){
        lfoat.style.display="none";
        bigbox.style.display="none";
    }

    //给小盒子添加鼠标移动事件
    mark.onmousemove=function(ev){
        var _event=ev||window.event;//做兼容性，兼容IE
        //1计算值：
        var left=_event.clientX-demo.offsetLeft-samll.offsetLeft-lfoat.offsetWidth/2;
        var top=_event.clientY-demo.offsetLeft-samll.offsetLeft+lfoat.offsetHeight/2;


        //5.优化，在前面加判断,不让其溢出，加判断
        if(left<0) left=0;
        if(top<0) top=0;
        if(left>samll.offsetWidth-lfoat.offsetWidth){
            left=samll.offsetWidth-lfoat.offsetWidth;
        }
              
        if(top>samll.offsetHeight-lfoat.offsetHeight){
            top=samll.offsetHeight-lfoat.offsetHeight;
        }
                
        //2把值赋值给放大镜
        lfoat.style.left=left+"px";
        lfoat.style.top=top+"px";

        //3计算比例
        var percentX=left/(mark.offsetWidth-lfoat.offsetWidth);
        var percentY=top/(mark.offsetHeight-lfoat.offsetHeight);

        //4利用这个比例计算距离后赋值给右侧的图片
        bigboximg.style.left=-percentX*(bigboximg.offsetWidth-bigbox.offsetWidth)+"px";
        bigboximg.style.top=-percentY*(bigboximg.offsetHeight-bigbox.offsetHeight)+"px";
    }

    // 获取？后面的id ------------------------------
    var xiang_url = location.search; // 获取url中"?"符后的字串
    var xiang_id = null;
    if (xiang_url.indexOf("?") != -1) {
        var str = xiang_url.substr(1);
        strs = str.split("&");
        for (var i = 0; i < strs.length; i++) {
            xiang_id = unescape(strs[i].split("=")[1]);
        }
    }
    // 使用商品id请求数据库获取商品信息
    $.ajax({
        type: 'POST',
        url: "http://localhost:94/php/list.php",
        data: {id: xiang_id},
        dataType: "json",
        contentType: "application/x-www-form-urlencoded; charset=utf-8",
        success: function(data){
            console.log(data[0])
            $('.yuan').text(data[0].price+'.00') // 价格
            $('.oneURL').attr("src", data[0].url)

        }
    });

    // 加入购物车效果 ------------`
    jiaru.onclick=function(){
        var gw =document.getElementById("gw");
        var fei =document.getElementById("one_1");
        var gw_num =document.getElementById("nunnn");
        var pay_num =Number(document.getElementById("num").value);
        var feiParent = fei.parentNode;
        var cNode = fei.cloneNode(true)
        cNode.style='position:absolute;left:0;top:0;'
        feiParent.appendChild(cNode)
        // console.log(gw.offsetLeft)
        // console.log(gw.offsetTop+30)
        var s=1000;
        var L=gw.offsetLeft+300
        var T=gw.offsetTop
        var TT=T*4;
        var LL=100;
        var a01 = setInterval(function(){
            s-=10;
            LL+=L/100;
            TT-=T/10;
            var x=s/1000
            cNode.style='position:fixed;left:'+LL+'px;top:'+TT+'px;overflow:hidden;z-index:999;transform:scale('+x+','+x+')'

            if(s<=0||TT<=-100||LL==L){
                cNode.style='display:none';
                var txt = gw_num.innerText;
                var number = Number(txt)+pay_num;
                gw_num.innerText = number;
                var name = '凡客衬衫 易打理 宽松复古开领 男款2 蓝青宽条';
                var yuan = Number($('.yuan').text())*pay_num;
                var url = $('#fei').attr('src')
                cookie(xiang_id, name, pay_num, yuan, url)
                clearInterval(a01)
            }
        }, 10)
        
    }
    function cookie(id, name, num, yuan, url){
        // 分解
        var arrCookie = document.cookie.split('; ')
        var arrId = [];
        for(var i=0; i<arrCookie.length; i++){
            arrId.push(arrCookie[i].split('=')[0])
        }
        // 判断id是否存在
        var idx = arrId.indexOf(id);
        // 购物车的数量显示
        if(idx>=0){ // 存在数量增加
            var arC = arrCookie[idx].split('=')[1].split('&');
            num = num*1+arC[1]*1;
            yuan = yuan*1+arC[2]*1;
        }
        document.cookie = `${id}=${id}&${name}&${num}&${yuan}&${url}`;
        
        
    }
 
})