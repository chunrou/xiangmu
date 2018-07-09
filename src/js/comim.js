/* 
* @Author: Marte
* @Date:   2018-06-20 19:15:39
* @Last Modified by:   Marte
* @Last Modified time: 2018-07-04 13:02:26
*/

var $ = {};

$.baseUrl = 'http://localhost:94/project/';

$.filterUrl = function(url){
    if(url.startsWith('http')){
        return url;
    }
    return $.baseUrl + url;
}

$.ajax = function(options){
    let {api, method = 'get', params = {}, success} = options;

    // document.getElementById('mask').style.display = 'block';
    let xhr = new XMLHttpRequest();

    xhr.onreadystatechange = function(){
        if(xhr.readyState == 4 && xhr.status == 200){
            // document.getElementById('mask').style.display = 'none';
            success(xhr.responseText);
        }
    }
    api = $.filterUrl(api);
    let _params = [];
    for(key in params){
        _params.push(`${key}=${params[key]}`);
    }

    if(method.toLowerCase() == 'get'){
        api += '?' + _params.join('&');
        xhr.open(method, api);
        xhr.send(null);
    } else if(method.toLowerCase() == 'post'){
        xhr.open(method, api);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.send(_params.join('&'));
    }
}