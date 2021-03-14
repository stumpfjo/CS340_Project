document.addEventListener('DOMContentLoaded', function(event) {
  selectButton = document.getElementById('submitSubjectSelect');
  if (selectButton !== null) { 
    selectButton.addEventListener('click', function() {
      var subjectId = document.getElementById('selectSubject').value;
      var url = `/subjects/view_subjects?subjectId=${subjectId}`
      window.location.replace(url);
    });
  }
});
