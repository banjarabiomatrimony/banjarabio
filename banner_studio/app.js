/* ==========================================================================
   BANJARA MATRIMONY BANNER STUDIO LOGIC & EXPORT ENGINE
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  initAssets();
  initQRCode();
});

// Initialize bundled assets into img tags
function initAssets() {
  if (typeof BANNER_ASSETS !== 'undefined') {
    if (BANNER_ASSETS.sanjay_rathod && document.getElementById('img-sanjay')) {
      document.getElementById('img-sanjay').src = BANNER_ASSETS.sanjay_rathod;
    }
    if (BANNER_ASSETS.sevalal && document.getElementById('img-sevalal')) {
      document.getElementById('img-sevalal').src = BANNER_ASSETS.sevalal;
    }
    if (BANNER_ASSETS.jagadamba && document.getElementById('img-jagadamba')) {
      document.getElementById('img-jagadamba').src = BANNER_ASSETS.jagadamba;
    }
    if (BANNER_ASSETS.banti_rathod && document.getElementById('img-banti')) {
      document.getElementById('img-banti').src = BANNER_ASSETS.banti_rathod;
    }
    if (BANNER_ASSETS.bvs_logo && document.getElementById('img-bvs-logo')) {
      document.getElementById('img-bvs-logo').src = BANNER_ASSETS.bvs_logo;
    }
    if (BANNER_ASSETS.banjarabio_logo) {
      if (document.getElementById('img-logo')) document.getElementById('img-logo').src = BANNER_ASSETS.banjarabio_logo;
      if (document.getElementById('img-top-logo')) document.getElementById('img-top-logo').src = BANNER_ASSETS.banjarabio_logo;
    }
  }
}

// Generate high contrast QR Code for Play Store / Registration
function initQRCode() {
  const qrContainer = document.getElementById('qrcode-box');
  qrContainer.innerHTML = '';
  
  // URL to download BanjaraBio app / website registration
  const targetUrl = 'https://play.google.com/store/apps/details?id=com.avishio.banjarabio';
  
  new QRCode(qrContainer, {
    text: targetUrl,
    width: 70,
    height: 70,
    colorDark: '#000000',
    colorLight: '#ffffff',
    correctLevel: QRCode.CorrectLevel.H
  });
}

/// Master Theme Palettes
const BANNER_THEMES = {
  'maroon-gold': {
    name: 'Royal_Maroon',
    bg: 'radial-gradient(ellipse at 50% 35%, #880006 0%, #520004 38%, #280002 72%, #100001 100%)',
    archGlow: 'radial-gradient(circle, rgba(248, 200, 81, 0.4) 0%, rgba(248, 200, 81, 0.15) 50%, transparent 80%)',
    lightBeam: 'linear-gradient(180deg, rgba(248, 200, 81, 0.25) 0%, transparent 100%)'
  },
  'crimson-gold': {
    name: 'Saffron_Crimson',
    bg: 'radial-gradient(ellipse at 50% 35%, #e65100 0%, #c43200 25%, #8a1500 55%, #4a0300 80%, #1e0000 100%)',
    archGlow: 'radial-gradient(circle, rgba(255, 140, 0, 0.55) 0%, rgba(255, 69, 0, 0.28) 50%, transparent 80%)',
    lightBeam: 'linear-gradient(180deg, rgba(255, 180, 50, 0.45) 0%, transparent 100%)'
  },
  'navy-gold': {
    name: 'Royal_Navy',
    bg: 'radial-gradient(ellipse at 50% 35%, #1e3a8a 0%, #172554 38%, #0f172a 72%, #020617 100%)',
    archGlow: 'radial-gradient(circle, rgba(59, 130, 246, 0.5) 0%, rgba(29, 78, 216, 0.25) 50%, transparent 80%)',
    lightBeam: 'linear-gradient(180deg, rgba(147, 197, 253, 0.35) 0%, transparent 100%)'
  }
};

let currentTheme = 'maroon-gold';

// Theme Switcher
function setTheme(themeName) {
  currentTheme = themeName;
  const canvas = document.getElementById('banner-canvas');
  if (!canvas) return;

  canvas.className = `banner-hoarding theme-${themeName}`;
  const theme = BANNER_THEMES[themeName] || BANNER_THEMES['maroon-gold'];
  canvas.style.background = theme.bg;

  const archGlow = canvas.querySelector('.arch-glow');
  if (archGlow) archGlow.style.background = theme.archGlow;

  const lightBeam = canvas.querySelector('.light-beam');
  if (lightBeam) lightBeam.style.background = theme.lightBeam;
  
  document.querySelectorAll('.theme-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.theme === themeName);
  });
}

// Toggle Text Editor Drawer
function toggleEditor() {
  const drawer = document.getElementById('editor-drawer');
  drawer.classList.toggle('open');
}

// Live Text Synchronization
function syncText(targetId, value) {
  const el = document.getElementById(targetId);
  if (el) {
    el.innerText = value;
  }
}

// Real-time Photo Zoom & Position Adjustment
function adjustPhoto() {
  const zoom = document.getElementById('inp-zoom')?.value || 1.22;
  const posY = document.getElementById('inp-pos')?.value || 25;
  const photo = document.getElementById('img-banti');
  
  if (photo) {
    photo.style.transform = `scale(${zoom})`;
    photo.style.transformOrigin = `center ${posY}%`;
  }
  
  const lblZoom = document.getElementById('lbl-zoom');
  if (lblZoom) lblZoom.innerText = `${zoom}x`;
  
  const lblPos = document.getElementById('lbl-pos');
  if (lblPos) lblPos.innerText = `${posY}%`;
}

// Ultra-High-Resolution Canvas Export Engine for Flex/Hoarding Printers
async function exportHighRes(scaleFactor = 3) {
  const banner = document.getElementById('banner-canvas');
  const btn = event?.currentTarget;
  const originalText = btn ? btn.innerHTML : '';
  
  if (btn) {
    btn.innerHTML = `
      <svg class="spin" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="animation: spin 1s linear infinite;"><circle cx="12" cy="12" r="10" stroke="currentColor" stroke-opacity="0.25"></circle><path d="M12 2a10 10 0 0 1 10 10" stroke="currentColor" stroke-linecap="round"></path></svg>
      रेंडरिंग सुरु आहे (${scaleFactor >= 3 ? '8K Master' : '4K HD'})...
    `;
    btn.disabled = true;
  }

  try {
    // Wait for all web fonts to be completely ready
    if (document.fonts) {
      await document.fonts.ready;
    }

    const theme = BANNER_THEMES[currentTheme] || BANNER_THEMES['maroon-gold'];

    // Render at specified scale with onclone theme guarantee
    const canvas = await html2canvas(banner, {
      scale: scaleFactor,
      useCORS: true,
      allowTaint: true,
      backgroundColor: null,
      logging: false,
      scrollX: 0,
      scrollY: 0,
      onclone: (clonedDoc) => {
        const clonedBanner = clonedDoc.getElementById('banner-canvas');
        if (clonedBanner) {
          clonedBanner.className = `banner-hoarding theme-${currentTheme}`;
          clonedBanner.style.background = theme.bg;
          const glow = clonedBanner.querySelector('.arch-glow');
          if (glow) glow.style.background = theme.archGlow;
          const beam = clonedBanner.querySelector('.light-beam');
          if (beam) beam.style.background = theme.lightBeam;
        }
      }
    });

    const resolutionLabel = scaleFactor >= 3 ? '8K_Flex_Master' : '4K_Social_HD';
    const fileName = `BanjaraBio_Melawa_Banner_20x10ft_${theme.name}_${resolutionLabel}.png`;

    // Use toBlob + ObjectURL (safe for large master files, prevents corrupted DataURL downloads)
    canvas.toBlob((blob) => {
      if (!blob) {
        alert('इमेज तयार करताना त्रुटी आली. कृपया पुन्हा प्रयत्न करा.');
        return;
      }
      const blobUrl = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.download = fileName;
      link.href = blobUrl;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      setTimeout(() => URL.revokeObjectURL(blobUrl), 15000);
    }, 'image/png', 1.0);

  } catch (err) {
    console.error('Export Error:', err);
    alert('निर्यात करताना त्रुटी आली. कृपया पुन्हा प्रयत्न करा.');
  } finally {
    if (btn) {
      setTimeout(() => {
        btn.innerHTML = originalText;
        btn.disabled = false;
      }, 1500);
    }
  }
}

// High-Resolution Vector/Print-Ready PDF Export Engine
async function exportPDF() {
  const banner = document.getElementById('banner-canvas');
  const btn = event?.currentTarget;
  const originalText = btn ? btn.innerHTML : '';
  
  if (btn) {
    btn.innerHTML = `
      <svg class="spin" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="animation: spin 1s linear infinite;"><circle cx="12" cy="12" r="10" stroke="currentColor" stroke-opacity="0.25"></circle><path d="M12 2a10 10 0 0 1 10 10" stroke="currentColor" stroke-linecap="round"></path></svg>
      PDF तयार होत आहे...
    `;
    btn.disabled = true;
  }

  try {
    if (document.fonts) {
      await document.fonts.ready;
    }

    const theme = BANNER_THEMES[currentTheme] || BANNER_THEMES['maroon-gold'];

    const canvas = await html2canvas(banner, {
      scale: 3,
      useCORS: true,
      allowTaint: true,
      backgroundColor: null,
      logging: false,
      scrollX: 0,
      scrollY: 0,
      onclone: (clonedDoc) => {
        const clonedBanner = clonedDoc.getElementById('banner-canvas');
        if (clonedBanner) {
          clonedBanner.className = `banner-hoarding theme-${currentTheme}`;
          clonedBanner.style.background = theme.bg;
          const glow = clonedBanner.querySelector('.arch-glow');
          if (glow) glow.style.background = theme.archGlow;
          const beam = clonedBanner.querySelector('.light-beam');
          if (beam) beam.style.background = theme.lightBeam;
        }
      }
    });

    const imgData = canvas.toDataURL('image/jpeg', 0.95);
    const { jsPDF } = window.jspdf;
    
    // Landscape 20x10 proportion in mm: width 508mm x height 254mm (2:1 exact banner ratio)
    const pdf = new jsPDF({
      orientation: 'landscape',
      unit: 'mm',
      format: [508, 254]
    });

    pdf.addImage(imgData, 'JPEG', 0, 0, 508, 254);
    pdf.save(`BanjaraBio_Melawa_Banner_20x10ft_${theme.name}_PrintReady.pdf`);

  } catch (err) {
    console.error('PDF Export Error:', err);
    alert('PDF तयार करताना त्रुटी आली. कृपया पुन्हा प्रयत्न करा.');
  } finally {
    if (btn) {
      setTimeout(() => {
        btn.innerHTML = originalText;
        btn.disabled = false;
      }, 1500);
    }
  }
}
