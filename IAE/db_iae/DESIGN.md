# EithSpace - System & Design Documentation

## 1. Project Overview
**EithSpace** is a full-stack minimalist sports venue booking platform designed for renting sports fields such as badminton, tennis, mini soccer, futsal, basketball, volleyball, and more. 

### Technology Stack
- **Backend**: Laravel (REST API)
- **Frontend**: React.js (Component-based UI)
- **Architecture**: API-based full-stack application

---

## 2. Design System & Aesthetics
EithSpace adopts a **minimalist, premium, modern, clean, and professional** aesthetic. The design is tailored to feel like a real product with an elegant "sport-tech" vibe.

### 2.1. Color Palette (Sport-Tech Minimalist)
The color scheme is designed to convey energy, professionalism, and high readability.

- **Primary Colors:**
  - `Primary Brand`: **#0F172A** (Slate 900) - Used for primary buttons, active states, strong accents, and active navigation.
  - `Primary Brand Accent`: **#3B82F6** (Blue 500) - Used for links, highlights, and secondary call-to-actions to give a sporty energy.
- **Background Colors:**
  - `Background Main`: **#F8FAFC** (Slate 50) - Dominant background for the application, an off-white that reduces eye strain.
  - `Background Card/Surface`: **#FFFFFF** (White) - For venue cards, form containers, dropdowns, and modals.
  - `Background Dark Section`: **#1E293B** (Slate 800) - Used strategically for footers, dark headers, or contrast marketing sections.
- **Text Colors:**
  - `Text Primary`: **#0F172A** (Slate 900) - High contrast headings and primary body text.
  - `Text Secondary`: **#64748B** (Slate 500) - Subtitles, placeholders, labels, and supporting text.
- **Status & Feedback Colors:**
  - `Success`: **#10B981** (Emerald 500) - Paid statuses, available slots, success toast messages.
  - `Warning`: **#F59E0B** (Amber 500) - Pending statuses, reschedule requests.
  - `Error / Danger`: **#EF4444** (Red 500) - Failed payments, cancelled bookings, error states, destructive actions.
  - `Disabled / Neutral`: **#E2E8F0** (Slate 200) - Blocked slots, disabled buttons, subtle borders.

### 2.2. Typography
A modern, geometric sans-serif typeface will be used to ensure high readability and a tech-forward look.
- **Primary Font**: **Inter** or **Outfit** (via Google Fonts).
  - *Headings*: Bold (700) or SemiBold (600) for high impact (`h1` to `h4`).
  - *Body*: Regular (400) or Medium (500) for UI elements.
  - *Small / Meta*: Text size `12px` - `14px` for tags, times, and secondary info.

### 2.3. UI Components & Elements
- **Border Radius (Rounded Corners)**: 
  - `Small`: `6px` (Inputs, badges, checkboxes, small buttons).
  - `Medium`: `12px` (Cards, dropdowns, primary buttons, schedule slots).
  - `Large`: `24px` (Modals, featured sections, hero images).
- **Shadows (Soft & Layered)**:
  - `Subtle Shadow`: `0 1px 3px rgba(0, 0, 0, 0.05)` (Input fields, sticky headers).
  - `Card Shadow`: `0 4px 6px -1px rgba(0, 0, 0, 0.05)` (Default state for venue cards).
  - `Hover Shadow`: `0 10px 15px -3px rgba(0, 0, 0, 0.1)` (Interactive cards on hover for dynamic feel).
- **Borders**: 
  - Subtle borders `1px solid #E2E8F0` for separating clean white spaces without adding visual clutter.
- **Micro-Animations**:
  - `Hover States`: Buttons and cards must slightly shift upward (`translateY(-2px)`) with a `transition: all 0.2s ease` to feel responsive and alive.

---

## 3. User Roles
The system strictly features **ONLY 2 roles** (No super admin, staff, or owner roles exist):
1. **Admin**: Manages venues, schedules, bookings, payments, and views reports.
2. **Customer**: Searches, books venues, manages profile, and views booking history.

---

## 4. Core Features

### Customer Features
1. **Authentication**: Login / Register (Clean forms).
2. **Venue Discovery**: 
   - Venue listing with high-quality thumbnails.
   - Search and functional filters (e.g., location: Jakarta, Bandung; category: Futsal, Badminton).
3. **Booking Flow**:
   - Real-time schedule checking (interactive time grid).
   - Booking placement (single or multi-slot selection).
   - Online payment integration (IDR pricing).
   - Booking confirmation & e-receipt.
4. **Management & Support**:
   - Booking history (timeline or tabbed view).
   - Reschedule requests (subject to admin approval).
   - Customer profile management.
   - Reviews and ratings (1-5 stars + text).
   - FAQ / Customer support section.

### Admin Features
1. **Dashboard**: Admin overview metrics (revenue charts, upcoming bookings, venue utilization stats).
2. **Venue Management**: Add, edit, and manage venue details, galleries, facility tags, and statuses.
3. **Schedule Management**: Manage operational hours (e.g., 08:00 - 22:00) and slot statuses dynamically.
4. **Booking Management**: Oversee customer bookings, approve/reject reschedule requests.
5. **Payment Management**: Track transaction statuses and handle manual verifications if necessary.
6. **Reports**: Generate operational and financial reports (tabular data view).

---

## 5. System Statuses & Enums

### Payment Statuses
- `pending`: Waiting for customer payment.
- `paid`: Payment successful and verified.
- `failed`: Payment attempt failed.
- `expired`: Payment time limit exceeded.

### Booking Statuses
- `pending`: Awaiting payment.
- `confirmed`: Paid and scheduled.
- `completed`: Booking slot has passed and been used.
- `cancelled`: Cancelled by user or system.
- `reschedule_requested`: Customer wants to move slot.
- `rescheduled`: Approved and moved to new slot.

### Venue Statuses
- `active`: Bookable by customers.
- `inactive`: Hidden from search.
- `maintenance`: Visible but slots are blocked.

### Slot Statuses
- `available`: Open for booking (Clickable).
- `booked`: Paid and confirmed by another customer (Disabled).
- `pending`: Locked temporarily while another user pays (Disabled).
- `blocked`: Closed by admin (Disabled).
- `maintenance`: Unavailable due to field repairs (Disabled).

---

## 6. UI/UX Interaction Requirements
To ensure a premium and production-ready feel, the following interaction states must be thoroughly implemented across both frontend and backend handling:
- **Feedback States**: 
  - Skeleton loading screens (avoid standard spinners where possible).
  - Empty state illustrations (e.g., "No venues found in your area").
  - Inline error validations on forms.
  - Toast success/error notifications.
  - Disabled button states during API calls.
- **Components**: 
  - Destructive action confirmation dialogs (e.g., "Are you sure you want to cancel this booking?").
  - Dynamic interactive data tables for the Admin panel.
  - Interactive clickable cards with hover micro-animations.
  - Real-time schedule grids that clearly distinguish slot statuses visually.
- **Data Reality**: 
  - Use realistic placeholder data (e.g., "GOR Badminton Sudirman", "Rp 150.000 / jam", actual sport categories like "Mini Soccer", realistic city names).
  - No static "lorem ipsum" text or fake conceptual UIs.
