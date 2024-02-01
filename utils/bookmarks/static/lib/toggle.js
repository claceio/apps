// Check for saved theme on page load and update the toggle
document.addEventListener('DOMContentLoaded', (event) => {
    const theme = localStorage.getItem('theme') || 'theme-light';
    if (theme == 'theme-light') {
        document.querySelector('#theme-toggle').checked = false;
    } else {
        document.querySelector('#theme-toggle').checked = true;
    }
});

// Update theme switch logic to save preference
document.getElementById('theme-toggle').addEventListener('change', function(event){
    if(event.target.checked){
        document.documentElement.setAttribute("data-theme", "dim")
        localStorage.setItem('theme', 'theme-dark');
    } else {
        document.documentElement.setAttribute("data-theme", "lemonade")
        localStorage.setItem('theme', 'theme-light');
    }
});