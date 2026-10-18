import '../models/website_spec.dart';

class CodeGenerator {
  /// Generates complete, responsive, modern HTML/CSS/JS from a specification
  static String generateFullHtml(WebsiteSpecification spec) {
    final css = generateCss(spec);
    final bodyHtml = generateBodyHtml(spec);
    final js = generateJs(spec);

    return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${spec.title}</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;600;700&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">
  <style>
$css
  </style>
</head>
<body>
$bodyHtml
  <script>
$js
  </script>
</body>
</html>''';
  }

  static String generateCss(WebsiteSpecification spec) {
    return '''
:root {
  --primary: ${spec.primaryColor};
  --secondary: ${spec.secondaryColor};
  --bg: ${spec.backgroundColor};
  --text: ${spec.textColor};
  --card-bg: rgba(255, 255, 255, 0.04);
  --glass-border: rgba(255, 255, 255, 0.12);
  --font-heading: 'Space Grotesk', sans-serif;
  --font-body: 'Inter', sans-serif;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  background-color: var(--bg);
  color: var(--text);
  font-family: var(--font-body);
  overflow-x: hidden;
  line-height: 1.6;
}

/* Header & Navigation */
header {
  position: sticky;
  top: 0;
  z-index: 100;
  background: rgba(7, 11, 20, 0.85);
  backdrop-filter: blur(16px);
  border-bottom: 1px solid var(--glass-border);
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.brand {
  font-family: var(--font-heading);
  font-size: 1.5rem;
  font-weight: 700;
  background: linear-gradient(135deg, var(--primary), var(--secondary));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

nav a {
  color: var(--text);
  text-decoration: none;
  margin-left: 1.5rem;
  font-size: 0.95rem;
  font-weight: 500;
  opacity: 0.85;
  transition: opacity 0.2s, color 0.2s;
}

nav a:hover {
  opacity: 1;
  color: var(--primary);
}

.btn-cta {
  background: linear-gradient(135deg, var(--primary), var(--secondary));
  color: #070b14;
  padding: 0.6rem 1.4rem;
  border-radius: 9999px;
  text-decoration: none;
  font-weight: 600;
  box-shadow: 0 4px 20px rgba(0, 240, 255, 0.25);
  transition: transform 0.2s, box-shadow 0.2s;
  display: inline-block;
}

.btn-cta:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 24px rgba(0, 240, 255, 0.4);
}

/* Hero Section */
.hero {
  position: relative;
  min-height: 75vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  padding: 4rem 1.5rem;
  perspective: 1200px;
}

.hero h1 {
  font-family: var(--font-heading);
  font-size: clamp(2.2rem, 5vw, 4.2rem);
  font-weight: 700;
  letter-spacing: -0.03em;
  margin-bottom: 1rem;
  background: linear-gradient(180deg, #ffffff 30%, rgba(255, 255, 255, 0.65) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.hero p {
  font-size: clamp(1rem, 2vw, 1.25rem);
  color: rgba(248, 250, 252, 0.7);
  max-width: 650px;
  margin-bottom: 2rem;
}

/* 3D Showcase & Canvas Simulation */
.showcase-3d {
  width: 100%;
  max-width: 500px;
  height: 280px;
  margin: 2rem auto;
  perspective: 1000px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.cube-3d {
  width: 160px;
  height: 160px;
  position: relative;
  transform-style: preserve-3d;
  animation: rotate3d 14s infinite linear;
}

@keyframes rotate3d {
  0% { transform: rotateX(15deg) rotateY(0deg); }
  50% { transform: rotateX(25deg) rotateY(180deg); }
  100% { transform: rotateX(15deg) rotateY(360deg); }
}

.cube-face {
  position: absolute;
  width: 160px;
  height: 160px;
  background: rgba(0, 240, 255, 0.08);
  border: 2px solid var(--primary);
  box-shadow: inset 0 0 20px rgba(0, 240, 255, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  font-family: var(--font-heading);
  font-weight: 700;
  color: var(--primary);
  border-radius: 12px;
  backdrop-filter: blur(8px);
}

.cube-face.front  { transform: translateZ(80px); }
.cube-face.back   { transform: rotateY(180deg) translateZ(80px); }
.cube-face.right  { transform: rotateY(90deg) translateZ(80px); }
.cube-face.left   { transform: rotateY(-90deg) translateZ(80px); }
.cube-face.top    { transform: rotateX(90deg) translateZ(80px); }
.cube-face.bottom { transform: rotateX(-90deg) translateZ(80px); }

/* Grid Sections */
.section {
  padding: 5rem 1.5rem;
  max-width: 1200px;
  margin: 0 auto;
}

.section-title {
  font-family: var(--font-heading);
  font-size: 2.2rem;
  font-weight: 700;
  text-align: center;
  margin-bottom: 0.75rem;
}

.section-subtitle {
  text-align: center;
  color: rgba(248, 250, 252, 0.65);
  margin-bottom: 3rem;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
}

.grid-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
}

/* 3D Tilt Card */
.card-tilt {
  background: var(--card-bg);
  border: 1px solid var(--glass-border);
  border-radius: 20px;
  padding: 2.2rem;
  transition: transform 0.3s cubic-bezier(0.25, 1, 0.5, 1), border-color 0.3s, box-shadow 0.3s;
  transform-style: preserve-3d;
  position: relative;
  overflow: hidden;
}

.card-tilt:hover {
  transform: translateY(-8px) rotateX(4deg) rotateY(-4deg);
  border-color: var(--primary);
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4), 0 0 30px rgba(0, 240, 255, 0.15);
}

.card-icon {
  font-size: 2rem;
  margin-bottom: 1.2rem;
  color: var(--primary);
}

.card-title {
  font-family: var(--font-heading);
  font-size: 1.3rem;
  font-weight: 600;
  margin-bottom: 0.6rem;
}

.card-desc {
  color: rgba(248, 250, 252, 0.7);
  font-size: 0.95rem;
  line-height: 1.6;
}

/* Footer */
footer {
  border-top: 1px solid var(--glass-border);
  padding: 3rem 1.5rem;
  text-align: center;
  color: rgba(248, 250, 252, 0.5);
  font-size: 0.9rem;
}

/* Mobile Responsiveness */
@media (max-width: 768px) {
  header {
    flex-direction: column;
    gap: 1rem;
    padding: 1rem;
  }
  nav {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 0.75rem;
  }
  nav a {
    margin-left: 0;
  }
  .hero {
    min-height: 60vh;
    padding: 3rem 1rem;
  }
}
''';
  }

  static String generateBodyHtml(WebsiteSpecification spec) {
    final navItems = spec.navigationLinks
        .map(
          (link) =>
              '<a href="#${link.toLowerCase().replaceAll(' ', '-')}">$link</a>',
        )
        .join('\n');

    final sectionsHtml = spec.sections
        .map((section) {
          if (section.type == 'showcase3d' || spec.enable3DEffects) {
            return '''
<section id="${section.id}" class="section">
  <h2 class="section-title">${section.title}</h2>
  <p class="section-subtitle">${section.description}</p>
  <div class="showcase-3d">
    <div class="cube-3d">
      <div class="cube-face front">CYBER</div>
      <div class="cube-face back">INNOVATION</div>
      <div class="cube-face right">FUTURE</div>
      <div class="cube-face left">DESIGN</div>
      <div class="cube-face top">AI</div>
      <div class="cube-face bottom">STUDIO</div>
    </div>
  </div>
</section>''';
          }

          return '''
<section id="${section.id}" class="section">
  <h2 class="section-title">${section.title}</h2>
  <p class="section-subtitle">${section.description}</p>
  <div class="grid-cards">
    <div class="card-tilt">
      <div class="card-icon">⚡</div>
      <h3 class="card-title">Autonomous Performance</h3>
      <p class="card-desc">Engineered for real-time responsiveness and seamless client-side execution.</p>
    </div>
    <div class="card-tilt">
      <div class="card-icon">💎</div>
      <h3 class="card-title">Fluid Glassmorphism</h3>
      <p class="card-desc">Modern translucent aesthetics calibrated with precision 3D depth and shadows.</p>
    </div>
    <div class="card-tilt">
      <div class="card-icon">🌐</div>
      <h3 class="card-title">Adaptive Hierarchy</h3>
      <p class="card-desc">Designed to scale effortlessly from ultra-wide displays down to Android phones.</p>
    </div>
  </div>
</section>''';
        })
        .join('\n');

    return '''
<header>
  <div class="brand">${spec.title}</div>
  <nav>
    $navItems
  </nav>
  <a href="#contact" class="btn-cta">Explore Now</a>
</header>

<main>
  <section class="hero">
    <h1>${spec.title}</h1>
    <p>${spec.tagline}</p>
    <div>
      <a href="#showcase" class="btn-cta">Launch Experience</a>
    </div>
  </section>

  $sectionsHtml
</main>

<footer>
  <p>&copy; ${DateTime.now().year} ${spec.title}. Built autonomously with Cyber AI Studio.</p>
</footer>
''';
  }

  static String generateJs(WebsiteSpecification spec) {
    return '''
// Interactive 3D Card Hover Tilt Controller
document.querySelectorAll('.card-tilt').forEach(card => {
  card.addEventListener('mousemove', e => {
    const rect = card.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    const centerX = rect.width / 2;
    const centerY = rect.height / 2;
    const rotateX = ((y - centerY) / centerY) * -12;
    const rotateY = ((x - centerX) / centerX) * 12;
    card.style.transform = `perspective(1000px) rotateX(\${rotateX}deg) rotateY(\${rotateY}deg) scale3d(1.02, 1.02, 1.02)`;
  });

  card.addEventListener('mouseleave', () => {
    card.style.transform = 'perspective(1000px) rotateX(0deg) rotateY(0deg) scale3d(1, 1, 1)';
  });
});
''';
  }
}
