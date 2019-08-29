var Writable = require('web-audio-stream/writable');

const config = {
    url_login : 'https://ptt-demo.herokuapp.com/login',
    url_subscribe: 'https://ptt-demo.herokuapp.com/subscribe?channel=',
    url_socket: 'wss://ptt-demo.herokuapp.com/wss?id='
};


var iOS = (function(){
    return{
        start: (callback)=>{ // callback = name of the method to invoke from iOS native code
            window.webkit.messageHandlers.start.postMessage(callback);
        },
        stop: ()=>{
            window.webkit.messageHandlers.stop.postMessage('');
        }
    }
})()


const ptt = (function() {

    var writable;
    var context;
    var ws;
    var button;
    var id;

    const recorder = {
        start: ()=>{
            ws.send('started');
            iOS.start('ptt.onDataReceived');
        },
        stop: ()=>{
            iOS.stop();
            setTimeout(()=>{
                ws.send('stopped');
            }, 500);
        }
    };

    /**
     * Invoked by iOS native code, whenever audio data is available
     */
    function onDataReceived(stringArray){
        var byteArray = JSON.parse(stringArray);
        var arraybuffer = new Int8Array(byteArray).buffer;
        ws.send(arraybuffer);
    }

    return{

        onDataReceived,

        connect : function(){

            const subscribe = (channel)=>{
                return fetch(config.url_subscribe+channel+"&id="+id, {method: 'GET'});
            };

            const bind = (btn)=>{
                button = btn;

                button.addEventListener('touchstart', (e)=>{
                    console.log("pointer down");
                    recorder.start();
                });

                button.addEventListener('touchend', (e)=>{
                    recorder.stop();
                });
            };

            return new Promise((resolve, reject) =>{
                fetch(config.url_login, { method: 'GET' })
                .then(r=>r.json())
                .then(data=>{
                      
                    id = data.id;
                      console.log("fetched id = "+id);

                    var reconnect = ()=>{
                        var socket = new WebSocket(config.url_socket+id);
                        socket.binaryType = ws.binaryType;
                        socket.onopen = ws.onopen;
                        socket.onerror = ws.onerror;
                        socket.onmessage = ws.onmessage;
                        socket.onclose = ws.onclose;
                        ws = socket;
                    }

                    ws = new WebSocket(config.url_socket+id);
                    ws.binaryType = 'arraybuffer';

                    ws.onopen = function(){
                        console.log("opened websocket");
                        resolve({subscribe, bind});
                    }

                    ws.onerror = function(e) {
                        reject(e);
                        console.log("rejected");
                    };

                    ws.onclose = function(e){
                      console.log("connection closed");
                      if(e.code == 1011 || e.code == 1006){
                            var msg = `Could not connect to websocket. reason=${e.reason}`;
                            console.log(msg);
                            reject({error: msg});
                        }else{
                            console.log(e);
                            reconnect();
                        }
                    }

                    ws.onmessage = (e)=>{
                      
                        if(e.data == 'ping'){
                            ws.send('pong');
                        }else if(e.data == 'started'){

                            if(button){
                                button.disabled = true;
                            }

                            if (context){
                                if(context.state == 'running'){
                                    context.close();
                                }
                            }

                            context = new (window.AudioContext || window.webkitAudioContext)();

                            writable = Writable(context.destination, {
                                context: context,
                                //channels: 2,
                                //sampleRate: context.sampleRate,
                                autoend: true
                            });

                        }else if(e.data == 'stopped'){
                            context.close();

                            if(button){
                                button.disabled = false;
                            }

                        }else{
                            if (context.state == 'running'){
                                context.decodeAudioData(e.data, (buffer)=>{
                                    writable.write(buffer);
                                });
                            }
                        }
                    }

                    /*
                     setInterval(()=>{
                        if(ws.readyState == 3 || ws.readyState == 2){
                            reconnect();
                        }
                    }, 5000);
                    */
                })
                .catch(function(err) {
                    reject(err);
                });
            });
        }
    }

})();
