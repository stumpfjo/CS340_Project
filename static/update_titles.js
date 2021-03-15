// on initial page load see if we have a form and take it over
document.addEventListener('DOMContentLoaded', function(event) {
  updateButton = document.getElementById('updateTitle');
  if (updateButton !== null) {
    updateButton.addEventListener('click', sendUpdate);
  }
  deleteCreatorButtons = document.getElementsByClassName('removeCreatorButton');
  if (deleteCreatorButtons.length>0) {
    for (var i = 0; i<deleteCreatorButtons.length;i++) {
      deleteCreatorButtons[i].addEventListener('click', removeCreator);
    }
  }
  deleteSubjectButtons = document.getElementsByClassName('removeSubjectButton');
  if (deleteSubjectButtons.length>0) {
    for (var i = 0; i<deleteSubjectButtons.length;i++) {
      deleteSubjectButtons[i].addEventListener('click', removeSubject);
    }
  }
  addCreatorButtons = document.getElementsByClassName('addCreatorButton');
  if (addCreatorButtons.length>0) {
    for (var i = 0; i<addCreatorButtons.length;i++) {
      addCreatorButtons[i].addEventListener('click', linkCreator);
    }
  }
});

function newCreatorRow(creatorData) {
  newRow = document.createElement('tr');
  newRow.setAttribute(
    'id',`deleteCreatorRow_${creatorData['creator_catalog_id']}`
  );
  newCell = document.createElement('td');
  newCell.textContent = creatorData['first_name'];
  newRow.appendChild(newCell);

  newCell = document.createElement('td');
  newCell.textContent = creatorData['last_name'];
  newRow.appendChild(newCell);

  newForm = document.createElement('form');
  newForm.setAttribute('action', creatorData['action']);
  newForm.setAttribute('method','post');

  newInput = document.createElement('input');
  newInput.setAttribute('type','hidden');
  newInput.setAttribute('name','creator_catalog_id');
  newInput.setAttribute('value',creatorData['creator_catalog_id']);
  newForm.appendChild(newInput);

  newInput = document.createElement('input');
  newInput.setAttribute('type','hidden');
  newInput.setAttribute('name','title_id');
  newInput.setAttribute('value',creatorData['title_id']);
  newForm.appendChild(newInput);

  newInput = document.createElement('input');
  newInput.setAttribute('type','submit');
  newInput.setAttribute('name','delete_creator');
  newInput.setAttribute('value', 'Remove Creator');
  newInput.setAttribute('class', 'removeCreatorButton');
  newForm.appendChild(newInput);

  newCell = document.createElement('td');
  newCell.appendChild(newForm);
  newRow.appendChild(newCell);
  insertLocation = document.getElementById('currentCreators');
  insertLocation.appendChild(newRow);
  document.getElementById(`deleteCreatorRow_${creatorData['creator_catalog_id']}`).getElementsByTagName('input')[2].addEventListener('click', removeCreator);
}

function linkCreator(event) {
  event.preventDefault();
  console.log(this.form.elements)
  payload = {
    'creator_id': this.form.elements['creator_id'].value,
    'title_id': this.form.elements['title_id'].value,
    'request_type': 'linkCreator'
  };
  console.log(payload)
  var req = new XMLHttpRequest();
  req.open('post', this.form.action, true);
  req.setRequestHeader('Content-Type', 'application/json');
  req.addEventListener('load',function(event){
    if(req.status >= 200 && req.status < 400){
      // refresh the display
      newData = JSON.parse(req.responseText);
      newCreatorRow(newData);
    } else {
      console.log('Error in network request: ' + req.statusText);
      alert('Error Processing Update');
    }
  });

  // send the reuest to the server
  req.send(JSON.stringify(payload));
}

function removeSubject(event) {
  event.preventDefault();
  payload = {
    'subject_catalog_id': this.form.elements['subject_catalog_id'].value,
    'request_type': 'removeSubject'
  };
  var req = new XMLHttpRequest();
  req.open('delete', this.form.action, true);
  req.setRequestHeader('Content-Type', 'application/json');
  req.addEventListener('load',function(event){
    if(req.status >= 200 && req.status < 400){
      // refresh the display
      newData = JSON.parse(req.responseText);
      alert('Success!');
      changeId = `deleteSubjectRow_${newData['subject_catalog_id']}`;
      deletedRow = document.getElementById(changeId);
      deletedRow.remove();
    } else {
      console.log('Error in network request: ' + req.statusText);
      alert('Error Processing Update');
    }
  });

  // send the reuest to the server
  req.send(JSON.stringify(payload));
}

function removeCreator(event) {
  event.preventDefault();
  payload = {
    'creator_catalog_id': this.form.elements['creator_catalog_id'].value,
    'request_type': 'removeCreator'
  };
  var req = new XMLHttpRequest();
  req.open('delete', this.form.action, true);
  req.setRequestHeader('Content-Type', 'application/json');
  req.addEventListener('load',function(event){
    if(req.status >= 200 && req.status < 400){
      // refresh the display
      newData = JSON.parse(req.responseText);
      alert('Success!');
      changeId = `deleteCreatorRow_${newData['creator_catalog_id']}`;
      deletedRow = document.getElementById(changeId);
      deletedRow.remove();
    } else {
      console.log('Error in network request: ' + req.statusText);
      alert('Error Processing Update');
    }
  });

  // send the reuest to the server
  req.send(JSON.stringify(payload));
}

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
