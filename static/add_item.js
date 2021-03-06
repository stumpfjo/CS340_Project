// based on code by Jon Frosch from CS290

document.addEventListener('DOMContentLoaded', function(event) {
  document.getElementById('add_item').addEventListener('click', addTitle);
});

function addTitle(event) {
  event.preventDefault();
  var req = new XMLHttpRequest();
  //collect the form data to send to the server
  var fields = ['add_cutter_num', 'add_title_id'];
  var payload = {};
  var formData = document.getElementById('add_item_form').elements;
  for (var f of fields) {
    payload[f] = formData[f].value;
  }

  console.log(payload)

  var url = document.getElementById('add_item_form').action;
  //send our form data to the server
  req.open('POST', url, true);
  req.setRequestHeader('Content-Type', 'application/json');
  req.addEventListener('load', function(){
    if(req.status == 201 && req.status < 400){
      res = JSON.parse(req.responseText);
      alert('Added Item!');
      // add the new item to the results list
      var itemBody = document.getElementById('currentItems');
      var newRow = document.createElement('tr');
      var tableFields = ['title_text','call_number','cutter_number'];
      for (var f of tableFields) {
        var newCell = document.createElement('td');
        newCell.textContent = res[f];
        newRow.appendChild(newCell)
      }
      itemBody.appendChild(newRow);
    } else if(req.status == 400){
      res = JSON.parse(req.responseText);
      for (var f of fields) {
        formData[f].value = res[f];
      }
      alert('Could not add item, check data.')
    } else {
      console.log('Error in network request: ' + req.statusText);
      alert('Error processing add');
    }
  });
  req.send(JSON.stringify(payload));
}
