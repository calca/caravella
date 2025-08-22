/* Main JavaScript for Caravella Website */

class CaravellaWebsite {
  constructor() {
    this.currentLanguage = this.getStoredLanguage() || this.detectBrowserLanguage();
    this.init();
  }

  init() {
    this.initNavigation();
    this.initLanguageSelector();
    this.initSmoothScrolling();
    this.initLazyLoading();
    this.updateLanguage(this.currentLanguage);
    this.initAccessibility();
    
    // Initialize after DOM is fully loaded
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => {
        this.initAnimations();
      });
    } else {
      this.initAnimations();
    }
  }

  // Language Management
  getStoredLanguage() {
    return localStorage.getItem('caravella-language');
  }

  setStoredLanguage(lang) {
    localStorage.setItem('caravella-language', lang);
  }

  detectBrowserLanguage() {
    const browserLang = navigator.language || navigator.userLanguage;
    const langCode = browserLang.split('-')[0];
    
    // Support only languages we have translations for
    const supportedLanguages = ['it', 'en', 'es'];
    return supportedLanguages.includes(langCode) ? langCode : 'it';
  }

  updateLanguage(lang) {
    if (!window.translations || !window.translations[lang]) {
      console.warn(`Language ${lang} not found, falling back to Italian`);
      lang = 'it';
    }

    this.currentLanguage = lang;
    this.setStoredLanguage(lang);

    // Update HTML lang attribute
    document.documentElement.lang = lang;

    // Update language selector
    const selector = document.getElementById('language-selector');
    if (selector) {
      selector.value = lang;
    }

    // Update page title and meta description
    this.updateMetaTags(lang);

    // Update all elements with data-i18n attribute
    const elements = document.querySelectorAll('[data-i18n]');
    elements.forEach(element => {
      const key = element.getAttribute('data-i18n');
      const translation = this.getTranslation(key, lang);
      if (translation) {
        element.textContent = translation;
      }
    });

    // Update placeholder texts if any
    this.updatePlaceholders(lang);
  }

  getTranslation(key, lang = this.currentLanguage) {
    const keys = key.split('.');
    let translation = window.translations[lang];
    
    for (const k of keys) {
      if (translation && typeof translation === 'object') {
        translation = translation[k];
      } else {
        return null;
      }
    }
    
    return translation;
  }

  updateMetaTags(lang) {
    const titles = {
      it: 'Caravella - Gestione Spese di Gruppo',
      en: 'Caravella - Group Expense Management',
      es: 'Caravella - Gestión de Gastos Grupales'
    };

    const descriptions = {
      it: 'App moderna per la gestione di gruppi di spesa, viaggi e partecipanti. Ideale per viaggi di gruppo, coinquilini ed eventi.',
      en: 'Modern app for managing group expenses, trips and participants. Ideal for group trips, roommates and events.',
      es: 'App moderna para gestionar gastos grupales, viajes y participantes. Ideal para viajes en grupo, compañeros de piso y eventos.'
    };

    document.title = titles[lang] || titles.it;
    
    const metaDescription = document.querySelector('meta[name="description"]');
    if (metaDescription) {
      metaDescription.content = descriptions[lang] || descriptions.it;
    }

    // Update Open Graph tags
    const ogTitle = document.querySelector('meta[property="og:title"]');
    if (ogTitle) {
      ogTitle.content = titles[lang] || titles.it;
    }

    const ogDescription = document.querySelector('meta[property="og:description"]');
    if (ogDescription) {
      ogDescription.content = descriptions[lang] || descriptions.it;
    }

    const twitterTitle = document.querySelector('meta[property="twitter:title"]');
    if (twitterTitle) {
      twitterTitle.content = titles[lang] || titles.it;
    }

    const twitterDescription = document.querySelector('meta[property="twitter:description"]');
    if (twitterDescription) {
      twitterDescription.content = descriptions[lang] || descriptions.it;
    }
  }

  updatePlaceholders(lang) {
    // Update any input placeholders if we add forms later
    const inputsWithPlaceholders = document.querySelectorAll('[data-i18n-placeholder]');
    inputsWithPlaceholders.forEach(input => {
      const key = input.getAttribute('data-i18n-placeholder');
      const translation = this.getTranslation(key, lang);
      if (translation) {
        input.placeholder = translation;
      }
    });
  }

  // Navigation
  initNavigation() {
    const navToggle = document.getElementById('nav-toggle');
    const navMenu = document.getElementById('nav-menu');

    if (navToggle && navMenu) {
      navToggle.addEventListener('click', () => {
        navMenu.classList.toggle('show');
        navToggle.setAttribute('aria-expanded', 
          navMenu.classList.contains('show') ? 'true' : 'false'
        );
      });

      // Close menu when clicking on a link
      const navLinks = navMenu.querySelectorAll('.nav__link');
      navLinks.forEach(link => {
        link.addEventListener('click', () => {
          navMenu.classList.remove('show');
          navToggle.setAttribute('aria-expanded', 'false');
        });
      });

      // Close menu when clicking outside
      document.addEventListener('click', (e) => {
        if (!navMenu.contains(e.target) && !navToggle.contains(e.target)) {
          navMenu.classList.remove('show');
          navToggle.setAttribute('aria-expanded', 'false');
        }
      });
    }

    // Active navigation link highlighting
    this.updateActiveNavLink();
    window.addEventListener('scroll', () => {
      this.updateActiveNavLink();
    });
  }

  updateActiveNavLink() {
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav__link[href^="#"]');
    
    let currentSection = '';
    
    sections.forEach(section => {
      const sectionTop = section.offsetTop - 100;
      const sectionHeight = section.offsetHeight;
      
      if (window.scrollY >= sectionTop && window.scrollY < sectionTop + sectionHeight) {
        currentSection = section.getAttribute('id');
      }
    });

    navLinks.forEach(link => {
      link.classList.remove('active');
      if (link.getAttribute('href') === `#${currentSection}`) {
        link.classList.add('active');
      }
    });
  }

  // Language Selector
  initLanguageSelector() {
    const selector = document.getElementById('language-selector');
    if (selector) {
      selector.value = this.currentLanguage;
      selector.addEventListener('change', (e) => {
        this.updateLanguage(e.target.value);
      });
    }
  }

  // Smooth Scrolling
  initSmoothScrolling() {
    const links = document.querySelectorAll('a[href^="#"]');
    links.forEach(link => {
      link.addEventListener('click', (e) => {
        e.preventDefault();
        const targetId = link.getAttribute('href').substring(1);
        const targetSection = document.getElementById(targetId);
        
        if (targetSection) {
          const headerHeight = document.querySelector('.header').offsetHeight;
          const targetPosition = targetSection.offsetTop - headerHeight;
          
          window.scrollTo({
            top: targetPosition,
            behavior: 'smooth'
          });
        }
      });
    });
  }

  // Lazy Loading
  initLazyLoading() {
    const images = document.querySelectorAll('img[loading="lazy"]');
    
    if ('IntersectionObserver' in window) {
      const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            const img = entry.target;
            img.classList.add('loaded');
            observer.unobserve(img);
          }
        });
      });

      images.forEach(img => imageObserver.observe(img));
    } else {
      // Fallback for older browsers
      images.forEach(img => img.classList.add('loaded'));
    }
  }

  // Animations
  initAnimations() {
    if ('IntersectionObserver' in window && !window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      const animateOnScroll = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            entry.target.classList.add('animate-in');
          }
        });
      }, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
      });

      // Add animation classes to elements
      const animatedElements = document.querySelectorAll('.feature__card, .download__card, .stat__card');
      animatedElements.forEach((el, index) => {
        el.style.animationDelay = `${index * 0.1}s`;
        animateOnScroll.observe(el);
      });
    }
  }

  // Accessibility
  initAccessibility() {
    // Add skip link
    const skipLink = document.createElement('a');
    skipLink.href = '#main';
    skipLink.className = 'sr-only';
    skipLink.textContent = 'Skip to main content';
    skipLink.addEventListener('focus', () => {
      skipLink.classList.remove('sr-only');
    });
    skipLink.addEventListener('blur', () => {
      skipLink.classList.add('sr-only');
    });
    document.body.insertBefore(skipLink, document.body.firstChild);

    // Add main landmark
    const main = document.querySelector('.main');
    if (main) {
      main.id = 'main';
    }

    // Keyboard navigation for mobile menu
    const navToggle = document.getElementById('nav-toggle');
    if (navToggle) {
      navToggle.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          navToggle.click();
        }
      });
    }

    // Focus management for download cards
    const downloadCards = document.querySelectorAll('.download__card');
    downloadCards.forEach(card => {
      card.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          card.click();
        }
      });
    });

    // Announce language changes to screen readers
    const languageSelector = document.getElementById('language-selector');
    if (languageSelector) {
      languageSelector.addEventListener('change', () => {
        const announcement = document.createElement('div');
        announcement.setAttribute('aria-live', 'polite');
        announcement.setAttribute('aria-atomic', 'true');
        announcement.className = 'sr-only';
        
        const languageNames = { it: 'Italiano', en: 'English', es: 'Español' };
        announcement.textContent = `Language changed to ${languageNames[this.currentLanguage]}`;
        
        document.body.appendChild(announcement);
        setTimeout(() => document.body.removeChild(announcement), 1000);
      });
    }
  }

  // Utility Methods
  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }

  // Theme detection (for future dark mode support)
  detectTheme() {
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark';
    }
    return 'light';
  }
}

// Initialize the website when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    new CaravellaWebsite();
  });
} else {
  new CaravellaWebsite();
}

// Handle back/forward browser navigation
window.addEventListener('popstate', () => {
  // Update active nav link when user uses browser navigation
  setTimeout(() => {
    const website = new CaravellaWebsite();
    website.updateActiveNavLink();
  }, 100);
});

// Add CSS animations
const style = document.createElement('style');
style.textContent = `
  @keyframes fadeInUp {
    from {
      opacity: 0;
      transform: translateY(30px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  .feature__card,
  .download__card,
  .stat__card {
    opacity: 0;
    transform: translateY(30px);
    transition: opacity 0.6s ease, transform 0.6s ease;
  }

  .feature__card.animate-in,
  .download__card.animate-in,
  .stat__card.animate-in {
    opacity: 1;
    transform: translateY(0);
  }

  .nav__link.active {
    color: var(--primary);
  }

  .nav__link.active::after {
    width: 100%;
  }

  /* Skip link styles */
  .sr-only:not(:focus) {
    position: absolute !important;
    width: 1px !important;
    height: 1px !important;
    padding: 0 !important;
    margin: -1px !important;
    overflow: hidden !important;
    clip: rect(0, 0, 0, 0) !important;
    white-space: nowrap !important;
    border: 0 !important;
  }

  .sr-only:focus {
    position: absolute !important;
    top: 0 !important;
    left: 0 !important;
    width: auto !important;
    height: auto !important;
    padding: 8px 16px !important;
    margin: 0 !important;
    background: var(--primary) !important;
    color: var(--on-primary) !important;
    text-decoration: none !important;
    border-radius: 0 0 4px 0 !important;
    z-index: 9999 !important;
    clip: auto !important;
    white-space: normal !important;
  }
`;
document.head.appendChild(style);