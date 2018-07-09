﻿(function($){$.fn.extend({autocomplete:function(urlOrData,options){var isUrl=typeof urlOrData=="string";options=$.extend({},$.Autocompleter.defaults,{url:isUrl?urlOrData:null,data:isUrl?null:urlOrData,delay:isUrl?$.Autocompleter.defaults.delay:10,max:options&&!options.scroll?10:150},options);options.highlight=options.highlight||function(value){return value};options.formatMatch=options.formatMatch||options.formatItem;return this.each(function(){new $.Autocompleter(this,options)})},result:function(handler){return this.bind("result",handler)},search:function(handler){return this.trigger("search",[handler])},flushCache:function(){return this.trigger("flushCache")},setOptions:function(options){return this.trigger("setOptions",[options])},unautocomplete:function(){return this.trigger("unautocomplete")},noresult:function(handler){return this.bind("noresult",handler)}});$.Autocompleter=function(input,options){var KEY={UP:38,DOWN:40,DEL:46,TAB:9,RETURN:13,ESC:27,COMMA:188,PAGEUP:33,PAGEDOWN:34,BACKSPACE:8};var $input=$(input).attr("autocomplete","off").addClass(options.inputClass);var timeout;var previousValue="";var cache=$.Autocompleter.Cache(options);var hasFocus=0;var lastKeyPressCode;var config={mouseDownOnSelect:false};var select=$.Autocompleter.Select(options,input,selectCurrent,config);var blockSubmit;var requestQueue=0;$.browser.opera&&$(input.form).bind("submit.autocomplete",function(){if(blockSubmit){blockSubmit=false;return false}});$input.bind(($.browser.opera?"keypress":"keydown")+".autocomplete",function(event){hasFocus=1;lastKeyPressCode=event.keyCode;switch(event.keyCode){case KEY.UP:event.preventDefault();if(select.visible()){select.prev()}else{onChange(0,true)}break;case KEY.DOWN:event.preventDefault();if(select.visible()){select.next()}else{onChange(0,true)}break;case KEY.PAGEUP:event.preventDefault();if(select.visible()){select.pageUp()}else{onChange(0,true)}break;case KEY.PAGEDOWN:event.preventDefault();if(select.visible()){select.pageDown()}else{onChange(0,true)}break;case options.multiple&&$.trim(options.multipleSeparator)==","&&KEY.COMMA:case KEY.TAB:case KEY.RETURN:if(selectCurrent()){event.preventDefault();blockSubmit=true;return false}else{$input.trigger("noresult")}break;case KEY.ESC:select.hide();break;default:clearTimeout(timeout);timeout=setTimeout(onChange,options.delay);break}}).focus(function(){hasFocus++}).blur(function(){hasFocus=0;if(!config.mouseDownOnSelect){hideResults()}}).click(function(){if(hasFocus++>1&&!select.visible()){onChange(0,true)}}).bind("search",function(){var fn=(arguments.length>1)?arguments[1]:null;function findValueCallback(q,data){var result;if(data&&data.length){for(var i=0;i<data.length;i++){if(data[i].result.toLowerCase()==q.toLowerCase()){result=data[i];break}}}if(typeof fn=="function"){fn(result)}else{$input.trigger("result",result&&[result.data,result.value])}}$.each(trimWords($input.val()),function(i,value){request(value,findValueCallback,findValueCallback)})}).bind("flushCache",function(){cache.flush()}).bind("setOptions",function(){$.extend(options,arguments[1]);if("data" in arguments[1]){cache.populate()}}).bind("unautocomplete",function(){select.unbind();$input.unbind();$(input.form).unbind(".autocomplete")}).bind("input",function(){onChange(0,true)});function selectCurrent(){var selected=select.selected();if(!selected){return false}var v=selected.result;previousValue=v;if(options.multiple){var words=trimWords($input.val());if(words.length>1){var seperator=options.multipleSeparator.length;var cursorAt=$(input).selection().start;var wordAt,progress=0;$.each(words,function(i,word){progress+=word.length;if(cursorAt<=progress){wordAt=i;return false}progress+=seperator});words[wordAt]=v;v=words.join(options.multipleSeparator)}v+=options.multipleSeparator}$input.val(v);hideResultsNow();$input.trigger("result",[selected.data,selected.value,selected.idx]);return true}function onChange(crap,skipPrevCheck){if(lastKeyPressCode==KEY.DEL){select.hide();return}var currentValue=$input.val();if(!skipPrevCheck&&currentValue==previousValue){return}previousValue=currentValue;currentValue=lastWord(currentValue);if(currentValue.length>=options.minChars){$input.addClass(options.loadingClass);if(!options.matchCase){currentValue=currentValue.toLowerCase()}request(currentValue,receiveData,hideResultsNow)}else{stopLoading();select.hide()}}function trimWords(value){if(!value){return[""]}if(!options.multiple){return[$.trim(value)]}return $.map(value.split(options.multipleSeparator),function(word){return $.trim(value).length?$.trim(word):null})}function lastWord(value){if(!options.multiple){return value}var words=trimWords(value);if(words.length==1){return words[0]}var cursorAt=$(input).selection().start;if(cursorAt==value.length){words=trimWords(value)}else{words=trimWords(value.replace(value.substring(cursorAt),""))}return words[words.length-1]}function autoFill(q,sValue){if(options.autoFill&&(lastWord($input.val()).toLowerCase()==q.toLowerCase())&&lastKeyPressCode!=KEY.BACKSPACE){$input.val($input.val()+sValue.substring(lastWord(previousValue).length));$(input).selection(previousValue.length,previousValue.length+sValue.length)}}function hideResults(){clearTimeout(timeout);timeout=setTimeout(hideResultsNow,200)}function hideResultsNow(){var wasVisible=select.visible();select.hide();clearTimeout(timeout);stopLoading();if(options.mustMatch){$input.search(function(result){if(!result){if(options.multiple){var words=trimWords($input.val()).slice(0,-1);$input.val(words.join(options.multipleSeparator)+(words.length?options.multipleSeparator:""))}else{$input.val("");$input.trigger("result",null)}}})}}function receiveData(q,data){if(data&&data.length&&hasFocus){stopLoading();select.display(data,q);autoFill(q,data[0].value);select.show()}else{hideResultsNow()}}function request(term,success,failure){if(!options.matchCase){term=term.toLowerCase()}var data=cache.load(term);if(data&&data.length){success(term,data)}else{if((typeof options.url=="string")&&(options.url.length>0)){var extraParams={};$.each(options.extraParams,function(key,param){extraParams[key]=typeof param=="function"?param():param});var current=++requestQueue;window.setTimeout(function(){if(current!=requestQueue){return}$.ajax({mode:"abort",port:"autocomplete"+input.name,dataType:options.dataType,jsonpCallback:"jqautocompletecallback",cache:true,url:options.url,data:$.extend({k:lastWord(term),limit:options.max},extraParams),success:function(data){var parsed=options.parse&&options.parse(data)||parse(data);cache.add(term,parsed);success(term,parsed)}})},200)}else{select.emptyList();failure(term)}}}function parse(data){var parsed=[];var json=eval(data);if(typeof(json)!="undefined"&&json!=null&&json.length>0){for(var i=0;i<json.length;i++){parsed.push({data:json[i],value:json[i],result:json[i].name,idx:i})}}return parsed}function stopLoading(){$input.removeClass(options.loadingClass)}};$.Autocompleter.defaults={inputClass:"ac_input",resultsClass:"ac_results",loadingClass:"ac_loading",minChars:1,delay:400,matchCase:false,matchSubset:false,matchContains:false,cacheLength:10,max:100,mustMatch:false,extraParams:{},selectFirst:true,formatItem:function(row){return row[0]},formatMatch:null,autoFill:false,width:0,multiple:false,multipleSeparator:", ",highlight:function(value,term){return value.replace(new RegExp("(?![^&;]+;)(?!<[^<>]*)("+term.replace(/([\^\$\(\)\[\]\{\}\*\.\+\?\|\\])/gi,"\\$1")+")(?![^<>]*>)(?![^&;]+;)","gi"),"<strong>$1</strong>")},scroll:false,scrollHeight:180};$.Autocompleter.Cache=function(options){var data={};var length=0;function matchSubset(s,sub){if(!options.matchCase){s=s.toLowerCase()}var i=s.indexOf(sub);if(options.matchContains=="word"){i=s.toLowerCase().search("\\b"+sub.toLowerCase())}if(i==-1){return false}return i==0||options.matchContains}function add(q,value){if(length>options.cacheLength){flush()}if(!data[q]){length++}data[q]=value}function populate(){if(!options.data){return false}var stMatchSets={},nullData=0;if(!options.url){options.cacheLength=1}stMatchSets[""]=[];for(var i=0,ol=options.data.length;i<ol;i++){var rawValue=options.data[i];rawValue=(typeof rawValue=="string")?[rawValue]:rawValue;var value=options.formatMatch(rawValue,i+1,options.data.length);if(value===false){continue}var firstChar=value.charAt(0).toLowerCase();if(!stMatchSets[firstChar]){stMatchSets[firstChar]=[]}var row={value:value,data:rawValue,result:options.formatResult&&options.formatResult(rawValue)||value};stMatchSets[firstChar].push(row);if(nullData++<options.max){stMatchSets[""].push(row)}}$.each(stMatchSets,function(i,value){options.cacheLength++;add(i,value)})}setTimeout(populate,25);function flush(){data={};length=0}return{flush:flush,add:add,populate:populate,load:function(q){if(!options.cacheLength||!length){return null}if(!options.url&&options.matchContains){var csub=[];for(var k in data){if(k.length>0){var c=data[k];$.each(c,function(i,x){if(matchSubset(x.value,q)){csub.push(x)}})}}return csub}else{if(data[q]){return data[q]}else{if(options.matchSubset){for(var i=q.length-1;i>=options.minChars;i--){var c=data[q.substr(0,i)];if(c){var csub=[];$.each(c,function(i,x){if(matchSubset(x.value,q)){csub[csub.length]=x}});return csub}}}}}return null}}};$.Autocompleter.Select=function(options,input,select,config){var CLASSES={ACTIVE:"ac_over"};var listItems,active=-1,data,term="",needsInit=true,element,list;function init(){if(!needsInit){return}element=$("<div/>").hide().addClass(options.resultsClass).css("position","absolute").appendTo(document.body);list=$("<ul/>").appendTo(element).mouseover(function(event){if(target(event).nodeName&&target(event).nodeName.toUpperCase()=="LI"){active=$("li",list).removeClass(CLASSES.ACTIVE).index(target(event));$(target(event)).addClass(CLASSES.ACTIVE)}}).click(function(event){$(target(event)).addClass(CLASSES.ACTIVE);select();input.focus();return false}).mousedown(function(){config.mouseDownOnSelect=true}).mouseup(function(){config.mouseDownOnSelect=false});if(options.width>0){element.css("width",options.width)}needsInit=false}function target(event){var element=event.target;while(element&&element.tagName!="LI"){element=element.parentNode}if(!element){return[]}return element}function moveSelect(step){listItems.slice(active,active+1).removeClass(CLASSES.ACTIVE);movePosition(step);var activeItem=listItems.slice(active,active+1).addClass(CLASSES.ACTIVE);input.value=data[active].data.name;if(options.scroll){var offset=0;listItems.slice(0,active).each(function(){offset+=this.offsetHeight});if((offset+activeItem[0].offsetHeight-list.scrollTop())>list[0].clientHeight){list.scrollTop(offset+activeItem[0].offsetHeight-list.innerHeight())}else{if(offset<list.scrollTop()){list.scrollTop(offset)}}}}function movePosition(step){active+=step;if(active<0){active=listItems.size()-1}else{if(active>=listItems.size()){active=0}}}function limitNumberOfItems(available){return options.max&&options.max<available?options.max:available}function fillList(){list.empty();var max=limitNumberOfItems(data.length);for(var i=0;i<max;i++){if(!data[i]){continue}var formatted=options.formatItem(data[i].data,i+1,max,data[i].value,term);if(formatted===false){continue}var li=$("<li/>").html(options.highlight(formatted,term)).addClass(i%2==0?"ac_even":"ac_odd").appendTo(list)[0];$.data(li,"ac_data",data[i])}listItems=list.find("li");if(options.selectFirst){listItems.slice(0,1).addClass(CLASSES.ACTIVE);active=0}if($.fn.bgiframe){list.bgiframe()}}return{display:function(d,q){init();data=d;term=q;fillList()},next:function(){moveSelect(1)},prev:function(){moveSelect(-1)},pageUp:function(){if(active!=0&&active-8<0){moveSelect(-active)}else{moveSelect(-8)}},pageDown:function(){if(active!=listItems.size()-1&&active+8>listItems.size()){moveSelect(listItems.size()-1-active)}else{moveSelect(8)}},hide:function(){element&&element.hide();listItems&&listItems.removeClass(CLASSES.ACTIVE);active=-1},visible:function(){return element&&element.is(":visible")},current:function(){return this.visible()&&(listItems.filter("."+CLASSES.ACTIVE)[0]||options.selectFirst&&listItems[0])},show:function(){var offset=$(input).offset();var offsetleft=offset.left;var bodyleft=$("#Head").offset().left;if($(document.body).css("position")=="relative"){offsetleft=offsetleft-bodyleft}element.css({width:typeof options.width=="string"||options.width>0?options.width:$(input).width(),top:offset.top+input.offsetHeight,left:offsetleft}).show();if(options.scroll){list.scrollTop(0);list.css({maxHeight:options.scrollHeight,overflow:"auto"});if($.browser.msie&&typeof document.body.style.maxHeight==="undefined"){var listHeight=0;listItems.each(function(){listHeight+=this.offsetHeight});var scrollbarsVisible=listHeight>options.scrollHeight;list.css("height",scrollbarsVisible?options.scrollHeight:listHeight);if(!scrollbarsVisible){listItems.width(list.width()-parseInt(listItems.css("padding-left"))-parseInt(listItems.css("padding-right")))}}}},selected:function(){var selected=listItems&&listItems.filter("."+CLASSES.ACTIVE).removeClass(CLASSES.ACTIVE);return selected&&selected.length&&$.data(selected[0],"ac_data")},emptyList:function(){list&&list.empty()},unbind:function(){element&&element.remove()}}};$.fn.selection=function(start,end){if(start!==undefined){return this.each(function(){if(this.createTextRange){var selRange=this.createTextRange();if(end===undefined||start==end){selRange.move("character",start);selRange.select()}else{selRange.collapse(true);selRange.moveStart("character",start);selRange.moveEnd("character",end);selRange.select()}}else{if(this.setSelectionRange){this.setSelectionRange(start,end)}else{if(this.selectionStart){this.selectionStart=start;this.selectionEnd=end}}}})}var field=this[0];if(field.createTextRange){var range=document.selection.createRange(),orig=field.value,teststring="<->",textLength=range.text.length;range.text=teststring;var caretAt=field.value.indexOf(teststring);field.value=orig;this.selection(caretAt,caretAt+textLength);return{start:caretAt,end:caretAt+textLength}}else{if(field.selectionStart!==undefined){return{start:field.selectionStart,end:field.selectionEnd}}}}})(jQuery);var VA_GLOBAL={};VA_GLOBAL.shopid="";VA_GLOBAL.pagetype="";VA_GLOBAL.namespace=function(c){var a=c.split("."),b=VA_GLOBAL;for(i=(a[0]=="VA_GLOBAL")?1:0;i<a.length;i++){b[a[i]]=b[a[i]]||{};b=b[a[i]]}};VA_GLOBAL.namespace("Lang");VA_GLOBAL.Lang.trim=function(a){return a.replace(/^\s+|\s+$/g,"")};VA_GLOBAL.Lang.isEmpty=function(a){return/^\s*$/.test(a)};VA_GLOBAL.Lang.isNone=function(a){return((typeof a=="undefined")||a==null||((typeof a=="string")&&VA_GLOBAL.Lang.trim(a)=="")||a=="undefined")};VA_GLOBAL.Lang.isNumber=function(a){return !isNaN(a)};VA_GLOBAL.Lang.random=function(b,c){var a=c-b+1;return Math.floor(Math.random()*a+b)};VA_GLOBAL.Lang.dateTimeStrWms0=function(b){try{var j=b.getFullYear()}catch(c){b=new Date()}var f=b.getMonth()+1;f=f<10?"0"+f:""+f;var a=b.getDate();a=a<10?"0"+a:""+a;var d=b.getHours();d=d<10?"0"+d:""+d;var e=b.getMinutes();e=e<10?"0"+e:""+e;var h=b.getSeconds();h=h<10?"0"+h:""+h;var g=b.getMilliseconds();if(g<10){g="00"+g}else{if(g<100){g="0"+g}}return b.getFullYear()+f+a+d+e+h+g};VA_GLOBAL.Lang.timeSeq32=function(){return VA_GLOBAL.Lang.dateTimeStrWms0()+VA_GLOBAL.Lang.random(100000000000000,999999999999999)};VA_GLOBAL.namespace("Http");VA_GLOBAL.Http={isIp:function(a){var b=/^(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])$/;return(b.test(a))},getQueryStringArgs:function(){var g=(location.search.length>0?location.search.substring(1):"");var a={};var e=g.split("&");var d=null,f=null,j=null;for(var c=0;c<e.length;c++){d=e[c].split("=");if(d.length>1){try{f=decodeURIComponent(d[0]);j=decodeURIComponent(d[1]);a[f]=j}catch(h){}}}var b=(window.location.hash.length>0?window.location.hash.substring(1):"");e=b.split("&");for(var c=0;c<e.length;c++){d=e[c].split("=");if(d.length>1){try{f=decodeURIComponent(d[0]);j=decodeURIComponent(d[1]);a[f]=j}catch(h){}}}return a}};VA_GLOBAL.namespace("Dom");VA_GLOBAL.Dom.loadScriptURL=function(b){var a=document.createElement("script");a.type="text/javascript";a.src=b;document.body.appendChild(a)};VA_GLOBAL.Dom.loadImageBeacon=function(b){var a=document.createElement("img");a.type="image/png";a.src=b;a.border=0;a.height=1;a.width=1;document.body.appendChild(a)};VA_GLOBAL.namespace("Event");VA_GLOBAL.Event={getEvent:function(a){return a?a:window.event},getTarget:function(a){a=a?a:window.event;return a.target||a.srcElement},stopPropagation:function(a){a=a?a:window.event;if(a.stopPropagation){a.stopPropagation()}else{a.cancelBubble=true}},preventDefault:function(a){a=a?a:window.event;if(a.preventDefault){a.preventDefault()}else{a.returnValue=false}},addHandler:function(a,c,b){a=typeof a=="string"?document.getElementById(a):a;if(a.addEventListener){a.addEventListener(c,b,false)}else{if(a.attachEvent){a.attachEvent("on"+c,b)}else{a["on"+c]=b}}}};VA_GLOBAL.namespace("Cookie");VA_GLOBAL.Cookie={get:function(e){var b=null;var a=document.cookie.split("; ");for(var c=0,d=a.length;c<d;c++){var f=a[c].split("=");if(f!=null&&f!="undefined"){if(f[0]===e){if(f[1]!=null&&f[1]!="undefined"){b=f[1]}}}}return b},set:function(d,g,c,e,b,f){var a=encodeURIComponent(d)+"="+encodeURIComponent(g);if(c instanceof Date){a+="; expires="+c.toGMTString()}if(e){a+="; path="+e}if(b){a+="; domain="+b}if(f){a+="; secure"}document.cookie=a},unset:function(b,c,a,d){this.set(b,"",new Date(0),c,a,d)}};VA_GLOBAL.namespace("SubCookie");VA_GLOBAL.SubCookie={get:function(a,c){var b=this.getAll(a);if(b){return b[c]}else{return null}},getAll:function(g){var b=encodeURIComponent(g)+"=",c=document.cookie.indexOf(b),d=null,j={};if(c>-1){var a=document.cookie.indexOf(";",c);if(a==-1){a=document.cookie.length}d=document.cookie.substring(c+b.length,a);if(d.length>0){var k=d.split("&");for(var e=0,f=k.length;e<f;e++){var h=k[e].split("=");j[decodeURIComponent(h[0])]=decodeURIComponent(h[1])}return j}}return j},set:function(c,g,h,b,d,a,e){var f=this.getAll(c)||{};f[g]=h;this.setAll(c,f,b,d,a,e)},setAll:function(d,h,c,e,b,f){var a=encodeURIComponent(d)+"=";var g=new Array();for(var j in h){if(j.length>0&&h.hasOwnProperty(j)){g.push(encodeURIComponent(j)+"="+encodeURIComponent(h[j]))}}if(g.length>0){a+=g.join("&");if(c instanceof Date){a+="; expires="+c.toGMTString()}if(e){a+="; path="+e}if(b){a+="; domain="+b}if(f){a+="; secure"}}else{a+="; expires="+(new Date(0)).toGMTString()}document.cookie=a},unset:function(b,f,c,a,d){var e=this.getAll(b);if(e){delete e[f];this.setAll(b,e,null,c,a,d)}},unsetAll:function(b,c,a,d){this.setAll(b,null,new Date(0),c,a,d)}};VA_GLOBAL.namespace("vanew");VA_GLOBAL.vanew={prepare:function(){var c=new Date().getTime();VA_GLOBAL.new_begintime=c;VA_GLOBAL.new_requestid=VA_GLOBAL.Lang.timeSeq32();var p=window.location.protocol.toLowerCase();VA_GLOBAL.new_protocol=p;VA_GLOBAL.new_resolution=window.screen.width+"*"+window.screen.height;var e="//vamr.vancl.com:";var f=p=="https:"?443:80;VA_GLOBAL.new_server=p+e+f;var g=window.location.hostname.toLowerCase();VA_GLOBAL.new_domain=g;var m=VA_GLOBAL.Http.isIp(g);var k=g.lastIndexOf(".");if(k>0){k=g.lastIndexOf(".",k-1)}var h=m?g:(k==-1?("."+g):g.substring(k));VA_GLOBAL.new_domain1=h;var v=window.location.pathname;if(VA_GLOBAL.Lang.isEmpty(v)){v="/"}VA_GLOBAL.uri=v;var q=window.location.search;if(q.length>0){q=q.substring(1)}VA_GLOBAL.new_query=q;var o=VA_GLOBAL.Http.getQueryStringArgs();var t=o.source;if(VA_GLOBAL.Lang.isNone(t)){t=null}var j=(window.location.hash.length>0?window.location.hash.substring(1):"");if(VA_GLOBAL.Lang.isNone(j)){j="-"}VA_GLOBAL.new_source=t;VA_GLOBAL.new_hash=j;var r=document.referrer;if(r==null||(typeof r=="undefined")||r==""){VA_GLOBAL.Cookie.unset("va_click","/",VA_GLOBAL.new_domain1,null)}else{if(r.indexOf(".vancl.com")==-1){VA_GLOBAL.Cookie.unset("va_click","/",VA_GLOBAL.new_domain1,null)}}VA_GLOBAL.new_referer=r;VA_GLOBAL.new_useragent=navigator.userAgent;var s=VA_GLOBAL.Cookie.get("sid");if((typeof s=="undefined")||s==null||s==""){s="-"}var z=VA_GLOBAL.Cookie.get("va_sid");var A=null;if(z!=null&&z==s){A="g"}else{if(r==null||(typeof r=="undefined")||r==""){A="l";VA_GLOBAL.Cookie.unset("va_click","/",VA_GLOBAL.new_domain1,null)}else{if(r.indexOf(".vancl.com")==-1){A="l";VA_GLOBAL.Cookie.unset("va_click","/",VA_GLOBAL.new_domain1,null)}else{A="g"}}z=s}VA_GLOBAL.new_sid=z;VA_GLOBAL.new_visitsequence=A;var b=new Date();b.setTime(c+24*60*60*1000);VA_GLOBAL.Cookie.set("va_sid",z,b,"/",VA_GLOBAL.new_domain1,null);var d=VA_GLOBAL.SubCookie.getAll("va_click");VA_GLOBAL.new_parentrequestid=(typeof d.rid=="undefined")?"-":d.rid;VA_GLOBAL.new_clickid=(typeof d.cid=="undefined")?"-":d.cid;VA_GLOBAL.new_trackurl=(typeof d.turl=="undefined")?"-":decodeURIComponent(d.turl);VA_GLOBAL.new_trackname=(typeof d.tname=="undefined")?"-":d.tname;VA_GLOBAL.new_tracklabel=VA_GLOBAL.Lang.trim((typeof d.tlabel=="undefined")?"-":d.tlabel);var w=VA_GLOBAL.SubCookie.getAll("va_visit");var u=w.uid;var x=w.uvc;if(VA_GLOBAL.Lang.isNone(u)){u=VA_GLOBAL.Lang.timeSeq32();x=1;w.uid=u;w.uvc=x;w.ft=c;w.lt=c;w.tt=c}else{if(A=="l"){try{x=Number(x)+1;if(Number(x)>999){x=999}}catch(y){x=1}w.uvc=x;w.lt=w.tt;w.tt=c}else{try{x=Number(x);if(Number(x)>999){x=999}}catch(y){x=1}w.uvc=x}}VA_GLOBAL.new_uid=w.uid;VA_GLOBAL.new_uservisitcount=w.uvc;VA_GLOBAL.new_firsttime=w.ft;VA_GLOBAL.new_lasttime=w.lt;VA_GLOBAL.new_thistime=w.tt;var a=new Date();a.setTime(c+365*24*60*60*1000);VA_GLOBAL.SubCookie.setAll("va_visit",w,a,"/",VA_GLOBAL.new_domain1,null);var l="-";if((typeof track_sinput!="undefined")&&track_sinput!=null&&track_sinput!=""){l=track_sinput}VA_GLOBAL.new_insitesearchway=l;var n=getPageLab();if(n!=""){VA_GLOBAL.new_pagelab=n}else{VA_GLOBAL.new_pagelab="-"}},request:function(){try{if(typeof VA_GLOBAL.new_server!="undefined"){var c=VA_GLOBAL.new_referer;var b=VA_GLOBAL.new_hash;var f=VA_GLOBAL.new_trackname;var e=VA_GLOBAL.new_tracklabel;var d=VA_GLOBAL.new_server+"/visit.ashx?";d+="version=1.2";d+="&requestid="+VA_GLOBAL.new_requestid;d+="&parentrequestid="+VA_GLOBAL.new_parentrequestid;d+="&sid="+VA_GLOBAL.new_sid;d+="&uid="+VA_GLOBAL.new_uid;d+="&referer="+(c==""?"-":encodeURIComponent(c.replace(/[\r\n\t]/g," ").substring(0,400)));d+="&visitsequence="+VA_GLOBAL.new_visitsequence;d+="&uservisitcount="+VA_GLOBAL.new_uservisitcount;d+="&firsttime="+VA_GLOBAL.new_firsttime;d+="&lasttime="+VA_GLOBAL.new_lasttime;d+="&thistime="+VA_GLOBAL.new_thistime;d+="&insitesearchway="+VA_GLOBAL.new_insitesearchway;d+="&pagelab="+encodeURIComponent(VA_GLOBAL.new_pagelab);d+="&resolution="+encodeURIComponent(VA_GLOBAL.new_resolution);d+="&title="+encodeURIComponent(document.title);d+="&hash="+(b==""?"-":encodeURIComponent(b));d+="&clickid="+VA_GLOBAL.new_clickid;d+="&trackname="+(f==""?"-":encodeURIComponent(f.replace(/[\r\n\t\'\"]/g," ")));d+="&tracklabel="+(e==""?"-":encodeURIComponent(e.replace(/[\r\n\t\'\"]/g," ")));d+="&shopid="+(VA_GLOBAL.shopid==""?"-":VA_GLOBAL.shopid);d+="&pagetype="+(VA_GLOBAL.pagetype==""?"-":VA_GLOBAL.pagetype);$.getScript(d)}}catch(a){}},loadtime:function(){try{if(typeof VA_GLOBAL.new_server!="undefined"){var c=new Date().getTime()-VA_GLOBAL.new_begintime;var b=VA_GLOBAL.new_referer;var d=VA_GLOBAL.new_server+"/render.ashx?";d+="version=1.2";d+="&requestid="+VA_GLOBAL.new_requestid;d+="&parentrequestid="+VA_GLOBAL.new_parentrequestid;d+="&sid="+VA_GLOBAL.new_sid;d+="&uid="+VA_GLOBAL.new_uid;d+="&rendertime="+c;d+="&referer="+(b==""?"-":encodeURIComponent(b.replace(/[\r\n\t]/g," ").substring(0,400)));$.getScript(d)}}catch(a){}},listenclick:function(){try{VA_GLOBAL.Event.addHandler(document,"mousedown",function(b){var d=VA_GLOBAL.Event.getTarget(b);if(d.nodeType==1){var c=VA_GLOBAL.vanew.elementclicked(d);if(c==false){VA_GLOBAL.vanew.elementclicked(d.parentNode)}}})}catch(a){}},elementclicked:function(h){if(h.nodeType!=1){return false}var g=false;var c=h.className;if(c==null||(typeof c=="undefined")){c=""}c=c.toLowerCase();var b=c.split(" ");for(var f=0;f<b.length;f++){if(b[f]=="track"){g=true;break}}var l=null;if(g){try{l=h.name}catch(d){}}if(g==false||(typeof l=="undefined")||l==null||l==""){l="-"}var j=h.nodeName.toLowerCase();var k=null;var m=null;if(j=="a"){try{k=h.innerHTML;var e=h.href;if((typeof e!="undefined")&&e!=null){if(/^https?:\/\/./i.test(e)){m=e}else{if(/^\/\/./i.test(e)){m=e}else{if(/^\/./i.test(e)){m=e}}}}m=encodeURIComponent(m)}catch(d){}}else{try{k=h.value;if((typeof k=="undefined")||k==null){k=h.title;if((typeof k=="undefined")||k==null){k=h.data}}}catch(d){}}if((typeof k=="undefined")||k==null){k="-"}try{if(typeof k!="string"){k=""}else{k=k.replace(/[\r\n\t\'\"]/g," ")}}catch(d){}k=VA_GLOBAL.Lang.trim(k);if(k.length>100){k=encodeURIComponent(k.substring(0,100))}else{k=encodeURIComponent(k)}var a=VA_GLOBAL.Lang.timeSeq32();if(g){VA_GLOBAL.vanew.recordtrackclick(a,l,m,k)}if(j=="a"){VA_GLOBAL.vanew.recordaclick(a,l,m,k)}return g||j=="a"},recordaclick:function(b,e,f,d){if(e==null||(typeof e=="undefined")||e==""){e="-"}if(d==null||(typeof d=="undefined")||d==""){d="-"}if(f==null||(typeof f=="undefined")||f==""){f="-"}var c={};c.rid=VA_GLOBAL.new_requestid;c.cid=b;c.turl=f;c.tname=e;c.tlabel=d;var a=new Date();a.setTime(new Date().getTime()+60*1000);VA_GLOBAL.SubCookie.setAll("va_click",c,a,"/",VA_GLOBAL.new_domain1,null)},recordtrackclick:function(a,e,f,d){if(e==null||(typeof e=="undefined")||e==""){e="-"}if(d==null||(typeof d=="undefined")||d==""){d="-"}if(f==null||(typeof f=="undefined")||f==""){f="-"}if(typeof VA_GLOBAL.new_server!="undefined"){var b=VA_GLOBAL.new_referer;var c=VA_GLOBAL.new_server+"/click.ashx?";c+="version=1.2";c+="&clickid="+a;c+="&trackurl="+(f==""?"-":encodeURIComponent(f.replace(/[\r\n\t]/g," ").substring(0,400)));c+="&trackname="+(e==""?"-":encodeURIComponent(e.replace(/[\r\n\t]/g," ").substring(0,400)));c+="&tracklabel="+(d==""?"-":encodeURIComponent(d.replace(/[\r\n\t]/g," ").substring(0,400)));c+="&requestid="+VA_GLOBAL.new_requestid;c+="&sid="+VA_GLOBAL.new_sid;c+="&uid="+VA_GLOBAL.new_uid;c+="&referer="+(b==""?"-":encodeURIComponent(b.replace(/[\r\n\t]/g," ").substring(0,400)));c+="&shopid="+(VA_GLOBAL.shopid==""?"-":VA_GLOBAL.shopid);c+="&pagetype="+(VA_GLOBAL.pagetype==""?"-":VA_GLOBAL.pagetype);$.getScript(c)}},send:function(){try{if(typeof VA_GLOBAL.v4sreadyed!="undefined"){return}VA_GLOBAL.v4sreadyed="1";VA_GLOBAL.vanew.prepare();VA_GLOBAL.vanew.request()}catch(a){}},loaded:function(){try{if(typeof VA_GLOBAL.v4sloaded!="undefined"){return}VA_GLOBAL.v4sloaded="1";VA_GLOBAL.vanew.loadtime();VA_GLOBAL.vanew.listenclick()}catch(a){}}};var PAGELAB_PATTERN=/^(PageLab_PLE[0-9]{4})=([^;]*)$/;var weblog_loadtime=new Date();try{$(document).ready(function(){VA_GLOBAL.vanew.send()})}catch(err){}function getPageLab(){var b="";var c=document.cookie.split(";");for(var a=0;a<c.length;a++){if(PAGELAB_PATTERN.test(trim(c[a]))){b+=trim(c[a].split("=")[1])+","}}b=(b.length>0)?b.substr(0,b.length-1):"";return b}function trim(c){for(var a=0;a<c.length&&c.charAt(a)==" ";a++){}for(var b=c.length;b>0&&c.charAt(b-1)==" ";b--){}if(a>b){return""}return c.substring(a,b)}try{$(window).load(function(){VA_GLOBAL.vanew.loaded()})}catch(err){};