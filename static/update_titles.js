// on initial page load see if we have a form and take it over
document.addEventListener('DOMContentLoaded', function(event) {
  updateButton = document.getElementById('updateTitle');
  if (updateButton !== null) {
    updateButton.addEventListener('click', sendUpdate);
  }
  // add event listeners to handle linking/unlinking Creators and Subjects
  // with the current title
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
  addSubjectButtons = document.getElementsByClassName('addSubjectButton');
  if (addSubjectButtons.length>0) {
    for (var i = 0; i<addSubjectButtons.length;i++) {
      addSubjectButtons[i].addEventListener('click', linkSubject);
    }
  }
});

// Build a new row to display a linked subject based on some data
function newSubjectRow(subjectData) {
  //create a new row container
  newRow = document.createElement('tr');
  newRow.setAttribute(
    'id',`deleteSubjectRow_${subjectData['subject_catalog_id']}`
  );

  //build the row contents
  newCell = document.createElement('td');
  newCell.textContent = subjectData['subject_heading'];
  newRow.appendChild(newCell);

  //create a form for deleting the new entry
  newForm = document.createElement('form');
  newForm.setAttribute('action', subjectData['action']);
  newForm.setAttribute('method','post');

  newInput = document.createElement('input');
  newInput.setAttribute('type','hidden');
  newInput.setAttribute('name','subject_catalog_id');
  newInput.setAttribute('value', subjectData['subject_catalog_id']);
  newForm.appendChild(newInput);

  newInput = document.createElement('input');
  newInput.setAttribute('type','hidden');
  newInput.setAttribute('name','title_id');
  newInput.setAttribute('value', subjectData['title_id']);
  newForm.appendChild(newInput);

  newInput = document.createElement('input');
  newInput.setAttribute('type','submit');
  newInput.setAttribute('name','delete_subject');
  newInput.setAttribute('value', 'Remove Subject');
  newInput.setAttribute('class', 'removeSubjectButton');
  newForm.appendChild(newInput);

  newCell = document.createElement('td');
  newCell.appendChild(newForm);
  newRow.appendChild(newCell);

  // add the new row to the page and activate the event listener for the submit
  insertLocation = document.getElementById('currentSubjects');
  insertLocation.appendChild(newRow);
  document.getElementById(`deleteSubjectRow_${subjectData['subject_catalog_id']}`).getElementsByTagName('input')[2].addEventListener('click', removeSubject);
}

// link a clicked subject to the current title
function linkSubject(event) {
  event.preventDefault();
  console.log(this.form.elements)
  payload = {
    'subject_id': this.form.elements['subject_id'].value,
    'title_id': this.form.elements['title_id'].value,
    'request_type': 'linkSubject'
  };
  console.log(payload)
  // send a POST request for the new Title_Subjects entry
  var req = new XMLHttpRequest();
  req.open('post', this.form.action, true);
  req.setRequestHeader('Content-Type', 'application/json');
  req.addEventListener('load',function(event){
    if(req.status >= 200 && req.status < 400){
      // refresh the display
      newData = JSON.parse(req.responseText);
      newSubjectRow(newData);
    } else {
      console.log('Error in network request: ' + req.statusText);
      alert('Error Processing Update');
    }
  });

  // send the reuest to the server
  req.send(JSON.stringify(payload));
}

// Build a new row to display a linked creator based on some data
function newCreatorRow(creatorData) {
  //create a new row for out new instance
  newRow = document.createElement('tr');
  newRow.setAttribute(
    'id',`deleteCreatorRow_${creatorData['creator_catalog_id']}`
  );

  // populate data cells
  newCell = document.createElement('td');
  newCell.textContent = creatorData['first_name'];
  newRow.appendChild(newCell);

  newCell = document.createElement('td');
  newCell.textContent = creatorData['last_name'];
  newRow.appendChild(newCell);

  //create a form for deleting the new instance
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

  //add the new row to the page and activate the delete event listener
  insertLocation = document.getElementById('currentCreators');
  insertLocation.appendChild(newRow);
  document.getElementById(`deleteCreatorRow_${creatorData['creator_catalog_id']}`).getElementsByTagName('input')[2].addEventListener('click', removeCreator);
}

//link a clicked Creator to the current title
function linkCreator(event) {
  event.preventDefault();
  console.log(this.form.elements)
  payload = {
    'creator_id': this.form.elements['creator_id'].value,
    'title_id': this.form.elements['title_id'].value,
    'request_type': 'linkCreator'
  };

  // send a POST for the nee Title_Creators entry to INSERT
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

//event listener for the delete button on a subject_heading.
//unlinks the selected subject from the current title
//(DELETE from composite entity)
function removeSubject(event) {
  event.preventDefault();
  payload = {
    'subject_catalog_id': this.form.elements['subject_catalog_id'].value,
    'request_type': 'removeSubject'
  };
  var req = new XMLHttpRequest();
  //sen DELETE request
  req.open('delete', this.form.action, true);
  req.setRequestHeader('Content-Type', 'application/json');
  req.addEventListener('load',function(event){
    if(req.status >= 200 && req.status < 400){
      // refresh the display
      newData = JSON.parse(req.responseText);
      alert('Success!');
      //erase the deleted row from the page
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

//event listener for the delete button on a creator.
//unlinks the selected creator from the current title
//(DELETE from composite entity)
function removeCreator(event) {
  event.preventDefault();
  payload = {
    'creator_catalog_id': this.form.elements['creator_catalog_id'].value,
    'request_type': 'removeCreator'
  };
  var req = new XMLHttpRequest();
  //send a DELETE request
  req.open('delete', this.form.action, true);
  req.setRequestHeader('Content-Type', 'application/json');
  req.addEventListener('load',function(event){
    if(req.status >= 200 && req.status < 400){
      // refresh the display
      newData = JSON.parse(req.responseText);
      alert('Success!');
      //erase the now-invalid row
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

// Update the information in the Titles table
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
  // open a http request and send the data.
  // use PUT since this is an update
  var req = new XMLHttpRequest();
  req.open('put', this.form.action, true);
  req.setRequestHeader('Content-Type', 'application/json');
  req.addEventListener('load',function(event){
    if(req.status >= 200 && req.status < 400){
      // refresh the display
      newData = JSON.parse(req.responseText);
      alert('Success!');
      //refresh page display to reflect changes
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
      //update the selectmenu control
      $("#select_title_id").selectmenu("refresh", true);
    } else {
      console.log('Error in network request: ' + req.statusText);
      alert('Error Processing Update');
    }
  });

  // send the reuest to the server
  req.send(JSON.stringify(payload));
}
