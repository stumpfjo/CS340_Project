document.addEventListener('DOMContentLoaded', function(event) {
  document.getElementById('add_title').addEventListener('click', addTitle);
});

function addTitle(event) {
  event.preventDefault();
  var req = new XMLHttpRequest();
  //collect the form data to send to the server
  var fields = ['new_title', 'new_pub_year', 'new_edition', 'new_language', 'new_call_num'];
  var payload = {};
  var formData = document.getElementById('newTitleForm').elements;
  for (var f of fields) {
    payload[f] = formData[f].value;
  }

  console.log(payload)

  var url = document.getElementById('newTitleForm').action;
  //send our form data to the workout log server
  req.open('POST', url, true);
  req.setRequestHeader('Content-Type', 'application/json');
  req.addEventListener('load', function(){
    if(req.status == 201 && req.status < 400){
      res = JSON.parse(req.responseText);
      alert('Added ' + res['title_added'] + ' with id ' + res['new_title_id']);
      for (var f of fields) {
        formData[f].value = '';
      }
    } else if(req.status == 400){
      res = JSON.parse(req.responseText);
      for (var f of fields) {
        form[f].value = res[f];
      }
      alert('Could not add title, check data.')
    } else {
      console.log('Error in network request: ' + req.statusText);
      alert('Error processing add');
    }
  });
  req.send(JSON.stringify(payload));
}
