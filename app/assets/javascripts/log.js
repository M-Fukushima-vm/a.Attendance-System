/*global $*/
$(function() {
  $('#log-year').change(function() {
    var year = $('#log-year option:selected').val();
    $('#log-month').change(function() {
      var p_month = $('#log-month option:selected').val();
      var month = ( '00' + p_month ).slice( -2 );
      // var go = $(this).val();
      var p_day = $('#user__3i').val();
      var day = ( '00' + p_day ).slice( -2 );
      var go = (year + '-' + month + '-' + day);
      console.log(go);
      // alert(go);
      var url = ('?date=' + go);
      window.location.href = url;
      
      // var URL = $(location).attr('search');
      // alert(URL);
      
      // var http = location.protocol;
      // var dome = location.host;
      // var path = location.pathname;
      // var url = (http + '://' + dome + '/' + path + '?date=' + go);
      // // alert(url);
      // // window.location.href = url;
    });
  });
});