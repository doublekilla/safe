import defaultTheme from 'tailwindcss/defaultTheme';
import forms from '@tailwindcss/forms';

/** @type {import('tailwindcss').Config} */
export default {
    content: [
        './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
        './storage/framework/views/*.php',
        './resources/views/**/*.blade.php',
        './resources/js/**/*.jsx',
    ],

    theme: {
        extend: {
            colors: {
                primary: {
                    DEFAULT: '#1a1a2e',
                    light: '#16213e',
                    dark: '#0f0f1e',
                    50: '#f0f0f5',
                    100: '#d9d9e6',
                    200: '#b3b3cc',
                    300: '#8c8cb3',
                    400: '#666699',
                    500: '#404080',
                    600: '#2d2d5e',
                    700: '#1a1a2e',
                    800: '#0f0f1e',
                    900: '#070710',
                },
                accent: {
                    DEFAULT: '#d4a843',
                    hover: '#c49a3a',
                    light: '#f0dca0',
                    dark: '#a88530',
                    50: '#fdf8eb',
                    100: '#f9ecc8',
                    200: '#f3d98f',
                    300: '#edc656',
                    400: '#d4a843',
                    500: '#b8912e',
                    600: '#967222',
                    700: '#74571a',
                    800: '#523d12',
                    900: '#30230a',
                },
                surface: {
                    DEFAULT: '#ffffff',
                    alt: '#f8f9fa',
                    dark: '#f1f3f5',
                    border: '#e5e7eb',
                },
                status: {
                    success: '#10b981',
                    'success-light': '#d1fae5',
                    warning: '#f59e0b',
                    'warning-light': '#fef3c7',
                    danger: '#ef4444',
                    'danger-light': '#fee2e2',
                    info: '#3b82f6',
                    'info-light': '#dbeafe',
                },
            },
            fontFamily: {
                sans: ['Inter', ...defaultTheme.fontFamily.sans],
            },
            borderRadius: {
                'card': '12px',
                'input': '8px',
                'badge': '20px',
                'button': '10px',
            },
            boxShadow: {
                'card': '0 1px 3px rgba(0, 0, 0, 0.08), 0 1px 2px rgba(0, 0, 0, 0.06)',
                'card-hover': '0 4px 12px rgba(0, 0, 0, 0.1), 0 2px 4px rgba(0, 0, 0, 0.06)',
                'elevated': '0 10px 40px rgba(0, 0, 0, 0.12)',
                'sidebar': '4px 0 24px rgba(0, 0, 0, 0.08)',
                'dropdown': '0 8px 24px rgba(0, 0, 0, 0.12)',
                'modal': '0 20px 60px rgba(0, 0, 0, 0.2)',
                'input-focus': '0 0 0 3px rgba(212, 168, 67, 0.15)',
            },
            spacing: {
                '18': '4.5rem',
                '88': '22rem',
                '100': '25rem',
                '112': '28rem',
                '128': '32rem',
            },
            animation: {
                'fade-in': 'fadeIn 0.3s ease-out',
                'fade-in-up': 'fadeInUp 0.4s ease-out',
                'fade-in-down': 'fadeInDown 0.3s ease-out',
                'slide-in-left': 'slideInLeft 0.3s ease-out',
                'slide-in-right': 'slideInRight 0.3s ease-out',
                'scale-in': 'scaleIn 0.2s ease-out',
                'pulse-soft': 'pulseSoft 2s ease-in-out infinite',
                'shimmer': 'shimmer 1.5s ease-in-out infinite',
                'bounce-subtle': 'bounceSubtle 0.5s ease-out',
            },
            keyframes: {
                fadeIn: {
                    '0%': { opacity: '0' },
                    '100%': { opacity: '1' },
                },
                fadeInUp: {
                    '0%': { opacity: '0', transform: 'translateY(16px)' },
                    '100%': { opacity: '1', transform: 'translateY(0)' },
                },
                fadeInDown: {
                    '0%': { opacity: '0', transform: 'translateY(-16px)' },
                    '100%': { opacity: '1', transform: 'translateY(0)' },
                },
                slideInLeft: {
                    '0%': { opacity: '0', transform: 'translateX(-24px)' },
                    '100%': { opacity: '1', transform: 'translateX(0)' },
                },
                slideInRight: {
                    '0%': { opacity: '0', transform: 'translateX(24px)' },
                    '100%': { opacity: '1', transform: 'translateX(0)' },
                },
                scaleIn: {
                    '0%': { opacity: '0', transform: 'scale(0.95)' },
                    '100%': { opacity: '1', transform: 'scale(1)' },
                },
                pulseSoft: {
                    '0%, 100%': { opacity: '1' },
                    '50%': { opacity: '0.7' },
                },
                shimmer: {
                    '0%': { backgroundPosition: '-200% 0' },
                    '100%': { backgroundPosition: '200% 0' },
                },
                bounceSubtle: {
                    '0%': { transform: 'translateY(0)' },
                    '40%': { transform: 'translateY(-6px)' },
                    '60%': { transform: 'translateY(-3px)' },
                    '100%': { transform: 'translateY(0)' },
                },
            },
            backgroundImage: {
                'gradient-primary': 'linear-gradient(135deg, #1a1a2e 0%, #16213e 100%)',
                'gradient-accent': 'linear-gradient(135deg, #d4a843 0%, #edc656 100%)',
                'gradient-surface': 'linear-gradient(180deg, #ffffff 0%, #f8f9fa 100%)',
            },
        },
    },

    plugins: [forms],
};
