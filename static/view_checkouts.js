// on initial page load, populate the checkouts table
document.addEventListener('DOMContentLoaded', function(event) {
  fillResultTable(JSON.parse(itemList));
});

function removeCheckout(event) {
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
      alert('Error Processing Return');
    }
  });

  // send the reuest to the server
  req.send(JSON.stringify(payload));
}

// iterate through a list of checked-out items and create a table row for each
function fillResultTable(rows) {
  var myTable = document.getElementById('checkout_display_area');
  // clear any old results
  myTable.textContent = "";
  // populate the table
  for (var r of rows) {
    myTable.appendChild(makeRow(r));
  }
}

// construct a row of checkout data to display
function makeRow(rowData) {
  var newRow = document.createElement('tr');
  var fields = ['title_text', 'item_id', 'due_date'];
  // add a display cells for a checkout
  for (var f of fields) {
    var newCell = document.createElement('td');
    newCell.textContent = rowData[f];
    newRow.appendChild(newCell);
  }

  // create our return form
  var newReturnForm = document.createElement('form');
  var itemId = document.createElement('input');
  var formFields = ['item_id', 'borrower_id'];
  for (var f of formFields) {
    var newField = document.createElement('input');
    newField.setAttribute('type', 'hidden');
    newField.setAttribute('value', rowData[f]);
    newField.setAttribute('name', f);
    newReturnForm.appendChild(newField);
  }
  var submitButton = document.createElement('input');
  submitButton.setAttribute('type', 'submit');
  submitButton.setAttribute('value', 'Return');
  submitButton.addEventListener('click', removeCheckout);
  newReturnForm.appendChild(submitButton);

  // wrap the form in a td and add it to the row
  var lastCell = document.createElement('td');
  lastCell.appendChild(newReturnForm);
  newRow.appendChild(lastCell);

  // return the constructed row
  return newRow;
}
