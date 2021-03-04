// on initial page load, enable teh Weed buttons
document.addEventListener('DOMContentLoaded', function(event) {
  enableWeedButtons();
});

function processDelete(event) {
  event.preventDefault();
  alert('Click')
}

function enableWeedButtons() {
  document.querySelectorAll('.deleteButton').forEach((button) => {
    button.addEventListener('click', processDelete);
  });
}
