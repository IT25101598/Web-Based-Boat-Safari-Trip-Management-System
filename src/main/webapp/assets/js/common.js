/**
 * Common JavaScript for Boat Safari Management System
 * Inspired by Sail Lanka Charter (sail-lanka-charter.com)
 */

document.addEventListener('DOMContentLoaded', () => {
    initNavbarScroll();
    initFlashAlerts();
    initEmergencySideBadge();
    initScrollReveal();
    initScrollProgress();
    initHeroParallax();
});

/**
 * Adds background glassmorphism effect on scroll
 */
function initNavbarScroll() {
    const header = document.querySelector('.site-header');
    if (!header) return;

    window.addEventListener('scroll', () => {
        if (window.scrollY > 40) {
            header.classList.add('scrolled');
        } else {
            header.classList.remove('scrolled');
        }
    });
}

/**
 * Auto-dismisses flash alert toasts after 5 seconds
 */
function initFlashAlerts() {
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(alert => {
        setTimeout(() => {
            alert.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            alert.style.opacity = '0';
            alert.style.transform = 'translateY(-10px)';
            setTimeout(() => alert.remove(), 500);
        }, 5000);
    });
}

/**
 * Manages the compact floating side badge / pill and flyout
 */
function initEmergencySideBadge() {
    const badgeContainer = document.getElementById('emergencySideBadge');
    const toggleBtn = document.getElementById('emergencyBadgeToggle');
    const closeBtn = document.getElementById('emergencyBadgeClose');
    const countBadge = document.getElementById('emergencyBadgeCount');
    const severityBadge = document.getElementById('emergencyBadgeSeverity');
    const severityText = document.getElementById('emergencyBadgeSeverityText');
    const titleEl = document.getElementById('emergencyBadgeTitle');
    const messageEl = document.getElementById('emergencyBadgeMessage');

    if (!badgeContainer) return;

    // Disappear when scrolling down on the home page, reappear when at the top
    const handleScroll = () => {
        if (window.scrollY > 60) {
            badgeContainer.classList.add('scrolled-hidden');
            if (badgeContainer.classList.contains('expanded')) {
                badgeContainer.classList.remove('expanded');
                if (toggleBtn) toggleBtn.setAttribute('aria-expanded', 'false');
            }
        } else {
            badgeContainer.classList.remove('scrolled-hidden');
        }
    };
    window.addEventListener('scroll', handleScroll, { passive: true });
    handleScroll();

    if (toggleBtn) {
        toggleBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            badgeContainer.classList.add('expanded');
            toggleBtn.setAttribute('aria-expanded', 'true');
        });
    }

    if (closeBtn) {
        closeBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            badgeContainer.classList.remove('expanded');
            if (toggleBtn) toggleBtn.setAttribute('aria-expanded', 'false');
        });
    }

    // Close when clicking anywhere outside the flyout card
    document.addEventListener('click', (e) => {
        if (!badgeContainer.contains(e.target) && badgeContainer.classList.contains('expanded')) {
            badgeContainer.classList.remove('expanded');
            if (toggleBtn) toggleBtn.setAttribute('aria-expanded', 'false');
        }
    });

    // Close on Escape key
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && badgeContainer.classList.contains('expanded')) {
            badgeContainer.classList.remove('expanded');
            if (toggleBtn) toggleBtn.setAttribute('aria-expanded', 'false');
        }
    });

    // Fetch dynamic live alerts feed
    fetch('/api/emergency/feed')
        .then(res => res.json())
        .then(data => {
            if (data && data.count > 0) {
                badgeContainer.classList.add('active');
                if (countBadge) countBadge.textContent = data.count;
                const latest = data.alerts[0];
                if (titleEl) titleEl.textContent = latest.title;
                if (messageEl) messageEl.textContent = latest.message;
                if (severityText) severityText.textContent = latest.severity;
                if (severityBadge) {
                    severityBadge.className = 'flyout-badge ' + (latest.badgeClass || 'badge-danger');
                }
            } else {
                badgeContainer.classList.remove('active');
                badgeContainer.classList.remove('expanded');
            }
        })
        .catch(() => {
            // Silently ignore if offline
        });
}

/**
 * Validates promo codes asynchronously in the booking form
 */
function validatePromoCode(code, totalAmount, callback) {
    if (!code || !code.trim()) return;

    const url = `/api/promo/validate?code=${encodeURIComponent(code.trim())}&total=${encodeURIComponent(totalAmount)}`;
    fetch(url)
        .then(res => res.json())
        .then(data => {
            if (callback) callback(data);
        })
        .catch(err => {
            if (callback) callback({ valid: false, message: 'Could not verify promo code.' });
        });
}

/**
 * Scroll Reveal Animations via native IntersectionObserver
 */
function initScrollReveal() {
    const reveals = document.querySelectorAll('.scroll-reveal');
    if (!reveals.length) return;

    // Check if IntersectionObserver is supported
    if (!('IntersectionObserver' in window)) {
        reveals.forEach(el => el.classList.add('revealed'));
        return;
    }

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('revealed');
                // Trigger once for performance
                observer.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.05,
        rootMargin: '80px 0px 0px 0px'
    });

    reveals.forEach(el => observer.observe(el));
}

/**
 * Nautical Champagne-Gold Scroll Progress Indicator
 */
function initScrollProgress() {
    const bar = document.getElementById('scrollProgressBar');
    if (!bar) return;

    window.addEventListener('scroll', () => {
        const total = document.documentElement.scrollHeight - window.innerHeight;
        if (total > 0) {
            const pct = Math.min(100, Math.max(0, (window.scrollY / total) * 100));
            bar.style.width = pct + '%';
        }
    }, { passive: true });
}

/**
 * Smooth Parallax on Home Page Hero Background
 */
function initHeroParallax() {
    const hero = document.querySelector('.hero-section');
    if (!hero) return;

    let ticking = false;
    window.addEventListener('scroll', () => {
        if (!ticking) {
            window.requestAnimationFrame(() => {
                const scrolled = window.scrollY;
                if (scrolled < window.innerHeight * 1.2) {
                    hero.style.backgroundPositionY = `calc(50% + ${scrolled * 0.22}px)`;
                }
                ticking = false;
            });
            ticking = true;
        }
    }, { passive: true });
}

