// on initial page load see if we have a form and take it over
document.addEventListener('DOMContentLoaded', function(event) {
  updateButton = document.getElementById('updateTitle');
  if (updateButton !== null) {
    updateButton.addEventListener('click', sendUpdate);
  }
});

function sendUpdate(event) {
  event.preventDefault();
  // get the data from the form
  var payload = {};
  var formFields = [
    'title_id',
    'title_text',
    'publication_year',
    'edition',
    'language',
    'call_number'
  ];
  for(var f of formFields) {
    payload[f] = this.form.elements[f].value;
  }
  // open a http request and send the data
  var req = new XMLHttpRequest();
  req.open('put', this.form.action, true);
  req.setRequestHeader('Content-Type', 'application/json');
  req.addEventListener('load',function(event){
    if(req.status >= 200 && req.status < 400){
      // refresh the display
      newData = JSON.parse(req.responseText);
      alert('Success!');
      changeId = `optionTitle${newData['title_id']}`;
      newTitle = `${newData['title_text']}`;
      document.getElementById(changeId).textContent = newTitle;
      document.getElementById('currentTitle').textContent = newTitle;
      var fields = [
        'title_id',
        'title_text',
        'publication_year',
        'edition',
        'language',
        'call_number'
      ];
      updateButton = document.getElementById('updateTitle');
      for(var f of fields) {
        updateButton.form.elements[f].value = newData[f];
      }
      $("#select_title_id").selectmenu("refresh", true);
    } else {
      console.log('Error in network request: ' + req.statusText);
      alert('Error Processing Update');
    }
  });

  // send the reuest to the server
  req.send(JSON.stringify(payload));
}
