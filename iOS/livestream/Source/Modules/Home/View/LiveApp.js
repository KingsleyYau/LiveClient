var LiveApp ={
    
callbackAppGAEvent:function(params){
    var message;
    message = {'CallBack':"callbackAppGAEvent",'Event':params};
    window.webkit.messageHandlers.LiveApp.postMessage(message);
},
    
callbackAppCloseWebView:function(){
    var message;
    message = {'CallBack':"callbackAppCloseWebView"};
    window.webkit.messageHandlers.LiveApp.postMessage(message);
},
    
callbackWebReload:function(params){
    var message;
    message = {'CallBack':"callbackWebReload",'Errno':params};
    window.webkit.messageHandlers.LiveApp.postMessage(message);
},
    
callbackWebAuthExpired:function(params){
    var message;
    message = {'CallBack':"callbackWebAuthExpired",'Errno':params};
    window.webkit.messageHandlers.LiveApp.postMessage(message);
},
    
callbackWebRechange:function(params){
    var message;
    message = {'CallBack':"callbackWebRechange",'Errno':params};
    window.webkit.messageHandlers.LiveApp.postMessage(message);
},
    
callbackAppPublicGAEvent:function(parameter1, parameter2, parameter3){
    var message;
    message = {'CallBack':"callbackAppPublicGAEvent",'category':parameter1,'event':parameter2,'label':parameter3};
    window.webkit.messageHandlers.LiveApp.postMessage(message);
}
};





var Event = {
    
_listeners: {},
    
    
addEvent: function(type, fn) {
    if (typeof this._listeners[type] === "undefined") {
        this._listeners[type] = [];
    }
    if (typeof fn === "function") {
        this._listeners[type].push(fn);
    }
    
    return this;
},
    
    
fireEvent: function(type,param) {
    var arrayEvent = this._listeners[type];
    if (arrayEvent instanceof Array) {
        for (var i=0, length=arrayEvent.length; i<length; i+=1) {
            if (typeof arrayEvent[i] === "function") {
                arrayEvent[i](param);
            }
        }
    }
    
    return this;
},
    
removeEvent: function(type, fn) {
    var arrayEvent = this._listeners[type];
    if (typeof type === "string" && arrayEvent instanceof Array) {
        if (typeof fn === "function") {
            for (var i=0, length=arrayEvent.length; i<length; i+=1){
                if (arrayEvent[i] === fn){
                    this._listeners[type].splice(i, 1);
                    break;
                }
            }
        } else {
            delete this._listeners[type];
        }
    }
    
    return this;
}
};


