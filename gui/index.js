// attach function to tabs that control the footer text
$(function(){
    $('#footercontent').addClass('invisible');
    $('#footercontent').html('I hope you enjoy this application. A <a href="https://paypal.me/chunjee/10usd" target="_blank">donation</a> is kindly requested if you found it useful');
    $("#v-pills-home-tab").on("click", function(){
        $('#footercontent').removeClass('visible');
        $('#footercontent').addClass('invisible');
    });
    $("#v-pills-settings-tab").on("click", function(){
        $('#footercontent').removeClass('invisible');
        $('#footercontent').addClass('visible');
    });
});
