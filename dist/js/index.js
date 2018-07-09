const cr = function(){
    const promist = new Promise(function(resolve,reject){
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function(){
            if(xhr.readyState == 4 && xhr.status == 200){
                resolve(window.eval(xhr.responseText))
            }
        }
        xhr.open('POST','http://localhost:94/php/index.php');
        xhr.send(null);
    })
    return promist;
}

document.addEventListener('DOMContentLoaded',function(){
    let option = {
        el: document.querySelector('.box'),
        autoPlay: true,
        interval: 3000,
        slides: 5,
        width: 1200,
        height: 535,
    }
    cr().then(function(data){
        box(option, data)
    })
})

var box = function(opt, data){
    // 创建ul
    var ul = document.createElement('ul');
    ul.style.width = `${opt.slides*opt.width}px`;
    ul.style.height = `${opt.width}px`;
    //循环生成 li
    for(var i = 0;i<opt.slides; i++){
        var li = document.createElement('li');
        var imges = document.createElement('img');
        li.style.width = `${opt.width}px`;
        li.style.height = `${opt.width}px`;

        imges.setAttribute('src', data[i].url) ;
        li.appendChild(imges);
        
        
        ul.appendChild(li);

    }

        opt.el.appendChild(ul);
        //生成下标
        var ul2 = document.createElement('ul');
        var lis = [];
        for(var i =0 ; i<opt.slides;i++){
           var li = document.createElement('li');
            if(i == 0){
            li.className = 'actived';
        }
            ul2.appendChild(li);
            lis.push(li);
        }
        opt.el.appendChild(ul2);
        // 自动播放
        var index = 1;
        if (opt.autoPlay) {
        window.setInterval(function(){
         if(index >= opt.slides){
            index = 0;
        }
        ul.style.transform = `translate(${opt.width*index*-1}px)`;

         //切换下标
        for(var i =0 ; i<opt.slides;i++){
            lis[i].className = '';

        }
         lis[index].className = 'actived';
        index++;

        },opt. interval)
     };
    var wx = document.querySelector('.wx');
    var weixin = document.querySelector('.weixin');
    // console.log(wx)
    wx.onmouseover = function(){
        weixin.style.display = 'block'
        wx.onmouseout = function(){
            weixin.style.display = 'none'
        }
    }
}
