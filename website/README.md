# Caravella Website

This directory contains the public website for the Caravella app.

## Overview

The website is a static site designed to promote and provide information about the Caravella group expense management app. It features:

- **Multi-language support**: Italian, English, and Spanish
- **Responsive design**: Mobile-first approach with Material 3-inspired design
- **Accessibility**: WCAG 2.1 AA compliant with proper semantic HTML and ARIA attributes
- **SEO optimized**: Meta tags, Open Graph, and structured content
- **GitHub Pages ready**: Automated deployment via GitHub Actions

## Structure

```
website/
├── index.html              # Main HTML file
├── css/
│   ├── style.css          # Main styles with Caravella theme colors
│   └── responsive.css     # Responsive and accessibility styles
├── js/
│   ├── main.js           # Main JavaScript functionality
│   └── translations.js   # Multi-language translations
├── assets/
│   ├── favicon.png       # App favicon
│   ├── favicon.svg       # SVG favicon
│   ├── logo.svg          # App logo
│   ├── hero-phone.png    # Hero section phone mockup
│   └── icons/            # Store and platform icons
└── README.md             # This file
```

## Features

### Design System
- **Colors**: Based on Caravella Flutter app theme
  - Primary: `#4C9BBA` (Caravella blue)
  - Secondary: `#FC6E75` (Caravella pink)
  - Material 3 color tokens for consistency
- **Typography**: Montserrat font family (matching the app)
- **Spacing**: Consistent spacing scale using CSS custom properties
- **Components**: Reusable button styles, cards, and layouts

### Sections
1. **Hero Section**: Main app promotion with download CTA
2. **Features Section**: Key app functionality showcase
3. **Download Section**: Store links (currently placeholders)
4. **About Section**: Open source information and developer links
5. **Footer**: Additional navigation and contact information

### Functionality
- **Language Switching**: Dynamic content translation
- **Smooth Scrolling**: Enhanced navigation experience
- **Lazy Loading**: Optimized image loading
- **Navigation**: Mobile-friendly hamburger menu
- **Accessibility**: Keyboard navigation and screen reader support

## Development

### Local Development
1. Serve the website directory with any HTTP server:
   ```bash
   # Using Python
   cd website && python -m http.server 8000
   
   # Using Node.js
   cd website && npx serve .
   
   # Using PHP
   cd website && php -S localhost:8000
   ```

2. Open `http://localhost:8000` in your browser

### Adding Translations
To add a new language:

1. Add the language code to `js/translations.js`
2. Add all translation keys for the new language
3. Update the language selector in `index.html`
4. Update the `detectBrowserLanguage()` function in `js/main.js`

### Customizing Styles
The website uses CSS custom properties for easy theming:

```css
:root {
  --primary: #4C9BBA;
  --secondary: #FC6E75;
  --spacing-md: 1.5rem;
  /* etc... */
}
```

## Deployment

The website is automatically deployed to GitHub Pages when changes are pushed to the `main` branch in the `website/` directory.

### GitHub Pages Setup
1. Go to repository Settings > Pages
2. Set source to "GitHub Actions"
3. The `.github/workflows/pages.yml` workflow will handle deployment

### Manual Deployment
The website can be deployed to any static hosting service by uploading the contents of the `website/` directory.

## Browser Support

- **Modern browsers**: Chrome 80+, Firefox 75+, Safari 13+, Edge 80+
- **Mobile browsers**: iOS Safari 13+, Chrome Mobile 80+
- **Accessibility**: Screen readers, keyboard navigation
- **Progressive enhancement**: Graceful degradation for older browsers

## Performance

- **Optimized images**: SVG icons and compressed images
- **Minimal JavaScript**: Vanilla JS without heavy frameworks
- **CSS optimization**: Efficient selectors and minimal specificity
- **Lazy loading**: Images load only when needed
- **Caching**: Static assets with appropriate cache headers

## Accessibility

- **WCAG 2.1 AA**: Meets accessibility guidelines
- **Semantic HTML**: Proper heading hierarchy and landmarks
- **ARIA labels**: Enhanced screen reader support
- **Keyboard navigation**: Full keyboard accessibility
- **Color contrast**: Sufficient contrast ratios
- **Focus management**: Visible focus indicators

## SEO

- **Meta tags**: Proper title, description, and keywords
- **Open Graph**: Social media sharing optimization
- **Structured data**: JSON-LD markup for search engines
- **Sitemap**: Auto-generated sitemap for search indexing
- **Mobile-friendly**: Google Mobile-Friendly Test compliant

## License

This website is part of the Caravella project and is released under the MIT License.