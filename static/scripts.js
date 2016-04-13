$('#submit-equation').on("click", function(e){
  $.ajax({
    url: '/submit-equation',
    data: {
      "equation":$("#user-input").val()
    },
    type: 'POST',
    success: function(res){
      console.log(res);
      $('.panel').removeClass('empty');
      $('.panel').addClass('filled');
      $('#clear-eqn').show();
      $('#output').html(res);
      MathJax.Hub.Queue(['Typeset', MathJax.Hub, 'output']);
    },
    error: function(error){
      $('.panel').addClass('empty');
      $('.panel').removeClass('filled');
      console.log(error);
    }
  });
});

$('#clear-eqn').on("click", function(e){
  $('.panel').addClass('empty');
  $('.panel').removeClass('filled');
  $('#user-input').val('');
  $('#output').html('');
  $('#clear-eqn').hide();
});