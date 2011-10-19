// http://img.tweetimag.es/i/40494198_n

var source = new EventSource('stream');
var max_length = 10000;
var uid;
source.onmessage = function (event) {
  if( $("#log").html().length > max_length )
    $("#log").html( $("#log").html().substring(0, max_length));

  $("#log").html( 
    event.data + "\n\n" + $("#log").html() );
    event.data.match( /&(user_id|hb)=(\d+)/ );
    uid = RegExp.$2;
    $("body").append( "<img src='http://img.tweetimag.es/i/" + uid + "_n' title='" + uid + "' width='73' height='73' />" );
};

