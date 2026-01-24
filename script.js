document.addEventListener("DOMContentLoaded", function () {
    // Navigation handling
    const navLinks = document.querySelectorAll("nav a");
    navLinks.forEach(link => {
        link.addEventListener("click", function (event) {
            const href = this.getAttribute("href");
            if (href.startsWith("http")) return; // Allow external links
            event.preventDefault();
            window.location.href = href;
        });
    });

    // Sun Wobble Animation
    const sun = document.getElementById('sun');
    if (sun) {
        let angle = 0;
        const animateSun = () => {
            angle += 0.05;
            const yOffset = Math.sin(angle) * 10;
            const xOffset = Math.cos(angle * 0.5) * 5;
            sun.style.transform = `translate(${xOffset}px, ${yOffset}px)`;
            requestAnimationFrame(animateSun);
        };
        animateSun();
    }

    // Intersection Observer for fade-in animations
    const observerOptions = {
        threshold: 0.1
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = "1";
                entry.target.style.transform = "translateY(0)";
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    document.querySelectorAll('.glass-card, section h2').forEach(el => {
        el.style.opacity = "0";
        el.style.transform = "translateY(20px)";
        el.style.transition = "all 0.6s cubic-bezier(0.4, 0, 0.2, 1)";
        observer.observe(el);
    });
});

