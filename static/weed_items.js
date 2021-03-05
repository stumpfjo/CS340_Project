// on initial page load, enable teh Weed buttons
document.addEventListener('DOMContentLoaded', function(event) {
  enableWeedButtons();
});

// remove the row of the item that got deleted from the display
function removeRow(reply) {
  if (reply && reply['i_id']) {
    rowId = "row_" + reply['i_id'];
    document.getElementById(rowId).remove();
  }
}

// send a DELETE request to the server for a given item
function processDelete(event) {
  event.preventDefault();
  payload = {};
  payload['item_id'] = this.form.elements['item_id'].value;
  var url = this.form.action.split('?')[0];
  var req = new XMLHttpRequest();
  req.open('delete', url, true);
  req.setRequestHeader('Content-Type', 'application/json');
  req.addEventListener('load',function(event){
    if(req.status >= 200 && req.status < 400){
      // refresh the display
      removeRow(JSON.parse(req.responseText));
    } else {
      console.log('Error in network request: ' + req.statusText);
      alert('Error Processing Return');
    }
  });

  // send the reuest to the server
  req.send(JSON.stringify(payload));
}

// Citation for the following function:
//     Date: 2021-02-06
//     Copied from /OR/ Adapted from /OR/ Based on:
//     Source URL: https://css-tricks.com/a-bunch-of-options-for-looping-over-queryselectorall-nodelists/
function enableWeedButtons() {
  // attach an event listener to each Weed button
  document.querySelectorAll('.deleteButton').forEach((button) => {
    button.addEventListener('click', processDelete);
  });
}
