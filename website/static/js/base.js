// Easter egg: Click the copyright symbol multiple times
(function() {
    let clickCount = 0;
    const clicksRequired = 5;

    document.addEventListener('DOMContentLoaded', function() {
        const copyrightSymbol = document.getElementById('copyright-symbol');
        if (!copyrightSymbol) return;

        copyrightSymbol.addEventListener('click', function() {
            clickCount++;

            if (clickCount === clicksRequired) {
                // Redirect to easter egg page
                window.location.href = '/easter-egg';
            } else if (clickCount >= clicksRequired - 2) {
                // Give a subtle hint when close (last 2 clicks)
                copyrightSymbol.style.cursor = 'pointer';
            }
        });
    });
})();

// Mobile dropdown toggle
(function() {
    document.addEventListener('DOMContentLoaded', function() {
        const dropdownToggle = document.querySelector('.nav-item.dropdown > a');
        if (!dropdownToggle) return;

        // Only add click behavior on touch devices
        if ('ontouchstart' in window || navigator.maxTouchPoints > 0) {
            dropdownToggle.addEventListener('click', function(e) {
                e.preventDefault();
                const dropdown = this.closest('.nav-item.dropdown');
                const menu = dropdown.querySelector('.dropdown-menu');

                // Toggle display
                if (menu.style.display === 'block') {
                    menu.style.display = 'none';
                } else {
                    menu.style.display = 'block';
                }
            });

            // Close dropdown when clicking outside
            document.addEventListener('click', function(e) {
                const dropdown = document.querySelector('.nav-item.dropdown');
                if (dropdown && !dropdown.contains(e.target)) {
                    const menu = dropdown.querySelector('.dropdown-menu');
                    if (menu) menu.style.display = 'none';
                }
            });
        }
    });
})();
