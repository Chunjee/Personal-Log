// attach function to tabs that control the footer text
$(function(){
    $("#v-pills-home-tab").on("click", function(){
        $('#myFooter').removeClass('visible');
        $('#myFooter').addClass('invisible');
    });
    $("#v-pills-options-tab").on("click", function(){
        $('#myFooter').removeClass('invisible');
        $('#myFooter').addClass('visible');
        $('#footercontent').html('I hope you enjoy this application. A <a href="https://paypal.me/chunjee/10usd" target="_blank">donation</a> is kindly requested if you found it useful');
    });
});
