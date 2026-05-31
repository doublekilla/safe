---
name: SpaceLink
colors:
  surface: '#f7f9ff'
  surface-dim: '#d1dbe8'
  surface-bright: '#f7f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#edf4ff'
  surface-container: '#e4effd'
  surface-container-high: '#dfe9f7'
  surface-container-highest: '#d9e3f1'
  on-surface: '#121d26'
  on-surface-variant: '#44474b'
  inverse-surface: '#27313c'
  inverse-on-surface: '#e8f2ff'
  outline: '#75777b'
  outline-variant: '#c5c6cb'
  surface-tint: '#575f69'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#141c24'
  on-primary-container: '#7c858f'
  inverse-primary: '#bfc7d2'
  secondary: '#575f6d'
  on-secondary: '#ffffff'
  secondary-container: '#d8e0f0'
  on-secondary-container: '#5b6371'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#002109'
  on-tertiary-container: '#009844'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe3ef'
  primary-fixed-dim: '#bfc7d2'
  on-primary-fixed: '#141c24'
  on-primary-fixed-variant: '#3f4851'
  secondary-fixed: '#dbe3f3'
  secondary-fixed-dim: '#bfc7d7'
  on-secondary-fixed: '#141c28'
  on-secondary-fixed-variant: '#3f4754'
  tertiary-fixed: '#6bff8f'
  tertiary-fixed-dim: '#4ae176'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005321'
  background: '#f7f9ff'
  on-background: '#121d26'
  surface-variant: '#d9e3f1'
typography:
  display:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  display-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 40px
---

## Brand & Style
The design system for this sports community app focuses on a **Modern-Premium Minimalist** aesthetic. It is engineered to feel like a high-performance athletic tool—precise, clean, and effortless. The interface prioritizes content and community interactions by utilizing expansive whitespace and a sophisticated, low-contrast foundation.

The target audience consists of active individuals who value efficiency and a high-quality digital experience. The UI evokes a sense of "quiet confidence," using a monochrome-heavy palette to allow user-generated content and vibrant "Success" states to provide the energy. The style leans into **Corporate Modern** with a touch of **Tactile Softness**, characterized by deep radius corners and layered surfaces that feel native to high-end mobile operating systems.

## Colors
This design system utilizes a "High-Contrast Core on Soft Foundation" logic. 

- **Primary & Secondary:** These dark tones are reserved for high-priority interactive elements (Buttons, Active Nav) and key branding moments to provide a grounded, premium feel.
- **Surface Strategy:** The background uses a soft off-white (#F5F6F7) to reduce eye strain, while interactive cards and containers use pure white (#FFFFFF) to create a clear "lift" from the base.
- **Functional Accents:** Success, Warning, and Error colors are used sparingly for status indicators, ensuring they stand out against the predominantly neutral palette.
- **Typography:** Three distinct tiers of gray ensure a clear information hierarchy without the harshness of pure black.

## Typography
The system uses **Inter** for its systematic, neutral, and highly legible characteristics. It mimics the utility of system fonts (SF Pro/Roboto) while maintaining a distinct, modern edge.

- **Headlines:** Use tighter letter-spacing and heavier weights to create a "locked-in" athletic look.
- **Body:** Standard weight with generous line-height to ensure readability during movement or quick scanning.
- **Labels:** Used for metadata, chips, and small buttons, often utilizing a medium or semi-bold weight to maintain legibility at small sizes.

## Layout & Spacing
This is a **Mobile-First Fluid Grid** system. 

- **Grid:** For mobile, use a 4-column layout with 16px gutters and 20px side margins. For tablet/desktop, scale to a 12-column centered layout (max-width 1200px).
- **Rhythm:** An 8pt linear scale governs all padding and margins. 
- **Sectioning:** Content is grouped in cards. Vertical spacing between cards should be consistent at 16px to create a rhythmic scroll.
- **Touch Targets:** All interactive elements (chips, buttons, links) must maintain a minimum hit area of 44x44px, regardless of their visual size.

## Elevation & Depth
Depth is conveyed through **Tonal Layering** and **Ambient Shadows**.

1.  **Level 0 (Base):** The #F5F6F7 background.
2.  **Level 1 (Cards):** #FFFFFF surfaces with a very soft, diffused shadow: `0px 4px 20px rgba(16, 24, 32, 0.04)`. This creates a subtle lift without feeling heavy.
3.  **Level 2 (Active Elements/Modals):** Elements that require immediate focus use a more pronounced shadow: `0px 8px 30px rgba(16, 24, 32, 0.08)`.

Outlines are used primarily for secondary actions or nested containers (e.g., #E3E6EA borders), ensuring the UI remains "flat-ish" and modern.

## Shapes
The shape language is defined by **High-Radius Geometry**.

- **Cards:** Use a signature 24px radius to create a friendly, premium feel. 
- **Buttons:** Slightly sharper at 12px to denote "action" and precision.
- **Chips:** Strictly pill-shaped (fully rounded) to differentiate them from buttons.
- **Input Fields:** 14px radius to sit comfortably between the card and button styles.

## Components

- **Buttons:** 
    - *Primary:* Dark (#101820) fill, White text. High-performance look.
    - *Secondary:* Light Gray (#EEF0F3) fill, Dark text (#1F2933). Low-impact, used for tertiary actions.
- **Chips:** Pill-shaped with #EEF0F3 background and #6B7280 text. Active state uses Primary Dark with White text.
- **Cards:** White background, 24px radius, subtle Level 1 shadow. Internal padding should be 20px or 24px.
- **Inputs:** #FFFFFF background with a 1px #E3E6EA border. On focus, the border becomes Primary Dark.
- **Bottom Navigation:** A persistent frosted glass or solid white bar. 5-tab layout. Active icons use Primary Dark; inactive use Muted Gray (#9CA3AF). High-quality micro-interactions for tab switching are encouraged.
- **Lists:** Clean rows with 1px #E3E6EA bottom dividers, typically nested inside rounded cards.