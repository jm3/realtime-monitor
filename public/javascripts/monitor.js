// http://img.tweetimag.es/i/40494198_n

var source = new EventSource('stream');
var max_length = 10000;
var max_faces = 200; 
var uid, faces = 0, users = [];
var BOGUS_USER_ID = 289057210;

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
  if( uid != BOGUS_USER_ID && uid != "log" )
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
      window.open( "http://twitter.com/" + u[0]["screen_name"], "twitter_bio" );
    }
  });
}

function init_config_ui() {
  $("a.ajax").click( function() {
    console.log( "clicked cfg link: " + $(this).attr("href") );
    console.log( $(this) );
    change_config_setting( "track", $(this).data("value") );
    event.preventDefault();
  });
}

function change_config_setting( setting, value ) {
  console.log( "changing " + setting + " to " + value );

  $.getJSON("track/" + value + ".json", function(data) {
    var items = [];
    console.log( "something happened!" );

    $.each(data, function(key, val) {
      items.push('<li id="' + key + '">' + val + '</li>');
      console.log( key + ": " + val );
    });

    $('<ul/>', {
      'class': 'my-new-list',
      html: items.join('')
    }).appendTo('body');
  });
}

$(document).ready( function() {
  init_config_ui();
});

