// on initial page load see if we have a form and take it over
document.addEventListener('DOMContentLoaded', function(event) {
  updateButton = document.getElementById('updateBorrower');
  if (updateButton !== null) {
    updateButton.addEventListener('click', sendUpdate);
  }
});

function doSuccess(newData) {
  alert('Success!');
  changeId = `optionBorrower${newData['borrower_id']}`;
  newName = `${newData['first_name']} ${newData['last_name']}`
  document.getElementById(changeId).textContent = newName;
  document.getElementById('currentBorrower').textContent = newName;
}

function sendUpdate(event) {
  event.preventDefault();
  // get the data from the form
  var payload = {};
  var formFields = [
    'borrower_id',
    'first_name',
    'last_name',
    'email',
    'street_address',
    'city_name',
    'state',
    'zip_code'
  ];
  for(var f of formFields) {
    payload[f] = this.form.elements[f].value;
  }
  // open a http request and send the data
  var req = new XMLHttpRequest();
  req.open('put', thisPage, true);
  req.setRequestHeader('Content-Type', 'application/json');
  req.addEventListener('load',function(event){
    if(req.status >= 200 && req.status < 400){
      // refresh the display
      doSuccess(JSON.parse(req.responseText));
    } else {
      console.log('Error in network request: ' + req.statusText);
      alert('Error Processing Checkout');
    }
  });

  // send the reuest to the server
  req.send(JSON.stringify(payload));
}
