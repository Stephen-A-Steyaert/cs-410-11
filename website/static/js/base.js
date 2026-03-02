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
