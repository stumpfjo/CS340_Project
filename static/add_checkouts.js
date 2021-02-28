// on page load, enable buttons
document.addEventListener('DOMContentLoaded', function(event) {
  enableCheckoutButtons();
});

function enableCheckoutButtons() {
  var forms = document.getElementsByClassName('form_add_checkout');
  for (var i=0; i<forms.length; i++) {
    var f = forms[i];
    var b = f.getElementsByTagName('input')[2];
    b.addEventListener('click', sendCheckoutRequest)
  }
}

function fillResultTable(results) {
  //clear old list
  var tableBody = document.getElementById('myTable');
  tableBody.textContent = "";

  //fill out rows of new table
  var fieldNames = ['item_id', 'title_text']
  for (var i of results['available_items']) {
    var newRow = document.createElement('tr');
    for (var f of fieldNames) {
      var newCell = document.createElement('td');
      newCell.textContent = i[f];
      tableBody.appendChild(newCell);
    }
    var newCell = document.createElement('td');
    newCell.textContent = `${i['call_number']} ${i['cutter_number']}`;
    tableBody.appendChild(newCell);
    // add form
    var formCell = document.createElement('td');
    var newForm = document.createElement('form');
    newForm.className = 'form_add_checkout';
    bInput = document.createElement('input');
    bInput.setAttribute('type', 'hidden');
    bInput.setAttribute('name', 'borrower_id');
    bInput.setAttribute('value', results['borrower_id']);
    newForm.appendChild(bInput);
    iInput = document.createElement('input');
    iInput.setAttribute('type', 'hidden');
    iInput.setAttribute('name', 'item_id');
    iInput.setAttribute('value', i['item_id']);
    newForm.appendChild(iInput);
    var submitButton = document.createElement('input');
    submitButton.setAttribute('type', 'submit');
    submitButton.setAttribute('value', 'Add Checkout');
    submitButton.setAttribute('id', `${i['item_id']}_checkout`);
    newForm.appendChild(submitButton);
    formCell.appendChild(newForm);
    newRow.appendChild(formCell);
    tableBody.appendChild(newRow);
  }

  // add listeners to form buttons
  enableCheckoutButtons();
}

function sendCheckoutRequest(event) {
  event.preventDefault();
  // get the data from the form
  var payload = {};
  var formFields = ['item_id', 'borrower_id'];
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
      fillResultTable(JSON.parse(req.responseText));
    } else {
      console.log('Error in network request: ' + req.statusText);
      alert('Error Processing Checkout');
    }
  });

  // send the reuest to the server
  req.send(JSON.stringify(payload));
}
