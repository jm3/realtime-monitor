// http://img.tweetimag.es/i/40494198_n

var source = new EventSource('stream');
var max_length = 10000;
var max_faces = 200; 
var uid, faces = 0, users = [];

source.onmessage = function (event) {
  if( $("#log").html().length > max_length )
    $("#log").html( $("#log").html().substring(0, max_length));

  $("#log").html( 
    event.data + "\n" + $("#log").html() );

  if( ++faces > max_faces ) { 
    $("#faces").html( "" );
    faces = 0;
  }

  event.data.match( /&(user_id|hb)=(\d+)/ );
  uid = RegExp.$2;
  $("#faces").append( "<img src='http://img.tweetimag.es/i/" + uid + "_n' title='" + uid + "' width='73' height='73' />" );

};

$("#faces img").live("click", function(){
  var u = $(this).attr("title");
  console.log( "handling click on user " + u );
  get_user_for_id( u );
});

function get_user_for_id( uid ) {
  $.ajax({
    url: "http://api.twitter.com/1/users/lookup.json?user_id=" + uid,
    dataType: 'jsonp',
    jsonp: 'callback',
    jsonpCallback: 'handle_user_data',
    success: function(data){
      var u = data;
      users.push( u[0] );
      window.open( "http://twitter.com/" + u[0]["screen_name"] );
    }
  });
}

