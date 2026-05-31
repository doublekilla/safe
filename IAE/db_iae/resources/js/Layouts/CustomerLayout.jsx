import { Link, usePage } from '@inertiajs/react';
import { useState, useEffect } from 'react';


// --- Toast Notification Component ---
function Toast({ message, type = 'success', onClose }) {
    useEffect(() => {
        const timer = setTimeout(onClose, 4000);
        return () => clearTimeout(timer);
    }, []);

    const bgColor = type === 'success' ? 'bg-emerald-500' : type === 'error' ? 'bg-red-500' : 'bg-amber-500';

    return (
        <div className={`${bgColor} text-white px-5 py-3 rounded-button shadow-elevated flex items-center gap-3 animate-fade-in-down min-w-[300px]`}>
            <span className="text-lg">{type === 'success' ? '✓' : type === 'error' ? '✕' : '⚠'}</span>
            <span className="text-sm font-medium flex-1">{message}</span>
            <button onClick={onClose} className="text-white/80 hover:text-white">✕</button>
        </div>
    );
}

export default function CustomerLayout({ children, title }) {
    const { auth, cart_count, flash } = usePage().props;
    const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
    const [userMenuOpen, setUserMenuOpen] = useState(false);
    const [toasts, setToasts] = useState([]);
    const [scrolled, setScrolled] = useState(false);

    useEffect(() => {
        const handleScroll = () => setScrolled(window.scrollY > 10);
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    useEffect(() => {
        if (flash?.success) setToasts(prev => [...prev, { id: Date.now(), message: flash.success, type: 'success' }]);
        if (flash?.error) setToasts(prev => [...prev, { id: Date.now(), message: flash.error, type: 'error' }]);
    }, [flash?.success, flash?.error]);

    const removeToast = (id) => setToasts(prev => prev.filter(t => t.id !== id));

    const navLinks = [
        { href: '/', label: 'Beranda', icon: '🏠', routeName: 'home' },
        { href: route('venues.index'), label: 'Lapangan', icon: '🏟️', routeName: 'venues.*' },
        { href: route('faq.index'), label: 'FAQ', icon: '❓', routeName: 'faq.*' },
    ];

    return (
        <div className="min-h-screen bg-surface-alt">
            {/* Navbar */}
            <nav className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
                scrolled ? 'bg-white/95 backdrop-blur-md shadow-card border-b border-surface-border' : 'bg-white'
            }`}>
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex items-center justify-between h-16">
                        {/* Logo */}
                        <Link href="/" className="flex items-center gap-2.5">
                            <div className="w-9 h-9 bg-gradient-primary rounded-lg flex items-center justify-center">
                                <span className="text-accent font-black text-sm">ES</span>
                            </div>
                            <span className="text-xl font-bold text-primary tracking-tight">EithSpace</span>
                        </Link>

                        {/* Desktop Nav Links */}
                        <div className="hidden md:flex items-center gap-1">
                            {navLinks.map(link => (
                                <Link
                                    key={link.label}
                                    href={link.href}
                                    className={`px-3.5 py-2 text-sm font-medium rounded-lg transition-all duration-200 ${
                                        route().current(link.routeName)
                                            ? 'text-accent bg-accent/5'
                                            : 'text-gray-600 hover:text-primary hover:bg-gray-50'
                                    }`}
                                >
                                    {link.label}
                                </Link>
                            ))}
                        </div>

                        {/* Right Side */}
                        <div className="flex items-center gap-3">
                            {auth?.user ? (
                                <>
                                    {/* Cart Button */}
                                    <Link
                                        href={route('cart.index')}
                                        className="relative p-2 text-gray-600 hover:text-primary hover:bg-gray-50 rounded-lg transition-all"
                                    >
                                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 100 4 2 2 0 000-4z" />
                                        </svg>
                                        {cart_count > 0 && (
                                            <span className="absolute -top-1 -right-1 bg-accent text-primary-dark text-[10px] font-bold w-5 h-5 rounded-full flex items-center justify-center animate-scale-in">
                                                {cart_count}
                                            </span>
                                        )}
                                    </Link>

                                    {/* User Menu */}
                                    <div className="relative">
                                        <button
                                            onClick={() => setUserMenuOpen(!userMenuOpen)}
                                            className="flex items-center gap-2 px-3 py-1.5 rounded-lg hover:bg-gray-50 transition-all"
                                        >
                                            <div className="w-8 h-8 bg-gradient-primary rounded-full flex items-center justify-center">
                                                <span className="text-accent text-xs font-bold">
                                                    {auth.user.name.charAt(0).toUpperCase()}
                                                </span>
                                            </div>
                                            <span className="hidden sm:block text-sm font-medium text-gray-700">{auth.user.name.split(' ')[0]}</span>
                                            <svg className="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                                            </svg>
                                        </button>

                                        {userMenuOpen && (
                                            <>
                                                <div className="fixed inset-0 z-30" onClick={() => setUserMenuOpen(false)} />
                                                <div className="absolute right-0 mt-2 w-56 bg-white rounded-card shadow-dropdown border border-surface-border z-40 py-1 animate-fade-in-down">
                                                    <div className="px-4 py-3 border-b border-surface-border">
                                                        <p className="text-sm font-semibold text-gray-900">{auth.user.name}</p>
                                                        <p className="text-xs text-gray-500">{auth.user.email}</p>
                                                    </div>
                                                    <Link href={route('customer.dashboard')} className="flex items-center gap-2 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50">
                                                        <span></span> Dashboard
                                                    </Link>
                                                    <Link href={route('bookings.index')} className="flex items-center gap-2 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50">
                                                        <span></span> Booking Saya
                                                    </Link>
                                                    <Link href={route('profile.edit')} className="flex items-center gap-2 px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50">
                                                        <span></span> Profil
                                                    </Link>
                                                    {auth.user.is_admin && (
                                                        <Link href={route('admin.dashboard')} className="flex items-center gap-2 px-4 py-2.5 text-sm text-accent-dark hover:bg-accent/5 font-medium">
                                                            <span></span> Admin Panel
                                                        </Link>
                                                    )}
                                                    <div className="border-t border-surface-border mt-1 pt-1">
                                                        <Link
                                                            href={route('logout')}
                                                            method="post"
                                                            as="button"
                                                            className="flex items-center gap-2 px-4 py-2.5 text-sm text-red-600 hover:bg-red-50 w-full"
                                                        >
                                                            <span></span> Keluar
                                                        </Link>
                                                    </div>
                                                </div>
                                            </>
                                        )}
                                    </div>
                                </>
                            ) : (
                                <div className="flex items-center gap-2">
                                    <Link href={route('login')} className="btn-ghost btn-sm">Masuk</Link>
                                    <Link href={route('register')} className="btn-accent btn-sm">Daftar</Link>
                                </div>
                            )}

                            {/* Mobile Menu Button */}
                            <button
                                onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                                className="md:hidden p-2 text-gray-600 hover:bg-gray-50 rounded-lg"
                            >
                                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    {mobileMenuOpen
                                        ? <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                                        : <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
                                    }
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>

                {/* Mobile Menu */}
                {mobileMenuOpen && (
                    <div className="md:hidden bg-white border-t border-surface-border animate-fade-in-down">
                        <div className="px-4 py-3 space-y-1">
                            {navLinks.map(link => (
                                <Link
                                    key={link.label}
                                    href={link.href}
                                    className="flex items-center gap-3 px-3 py-2.5 text-sm font-medium text-gray-600 hover:text-primary hover:bg-gray-50 rounded-lg"
                                    onClick={() => setMobileMenuOpen(false)}
                                >
                                    <span>{link.icon}</span> {link.label}
                                </Link>
                            ))}
                            {auth?.user && (
                                <Link
                                    href={route('bookings.index')}
                                    className="flex items-center gap-3 px-3 py-2.5 text-sm font-medium text-gray-600 hover:text-primary hover:bg-gray-50 rounded-lg"
                                    onClick={() => setMobileMenuOpen(false)}
                                >
                                    <span>📋</span> Booking Saya
                                </Link>
                            )}
                        </div>
                    </div>
                )}
            </nav>

            {/* Content */}
            <main className="pt-16">
                {children}
            </main>

            {/* Footer */}
            <footer className="bg-primary text-white mt-16">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
                    <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
                        <div className="md:col-span-1">
                            <div className="flex items-center gap-2.5 mb-4">
                                <div className="w-9 h-9 bg-accent rounded-lg flex items-center justify-center">
                                    <span className="text-primary-dark font-black text-sm">ES</span>
                                </div>
                                <span className="text-xl font-bold">EithSpace</span>
                            </div>
                            <p className="text-gray-400 text-sm leading-relaxed">
                                Platform booking lapangan olahraga terpercaya. Badminton, Futsal, Basket, Padel & Voli dalam satu lokasi.
                            </p>
                        </div>
                        <div>
                            <h3 className="font-semibold text-accent mb-3">Navigasi</h3>
                            <div className="space-y-2">
                                <Link href="/" className="block text-sm text-gray-400 hover:text-white transition-colors">Beranda</Link>
                                <Link href={route('venues.index')} className="block text-sm text-gray-400 hover:text-white transition-colors">Lapangan</Link>
                                <Link href={route('faq.index')} className="block text-sm text-gray-400 hover:text-white transition-colors">FAQ</Link>
                            </div>
                        </div>
                        <div>
                            <h3 className="font-semibold text-accent mb-3">Olahraga</h3>
                            <div className="space-y-2">
                                <span className="block text-sm text-gray-400">🏸 Badminton</span>
                                <span className="block text-sm text-gray-400">⚽ Futsal</span>
                                <span className="block text-sm text-gray-400">🏀 Basket</span>
                                <span className="block text-sm text-gray-400">🎾 Padel</span>
                                <span className="block text-sm text-gray-400">🏐 Voli</span>
                            </div>
                        </div>
                        <div>
                            <h3 className="font-semibold text-accent mb-3">Kontak</h3>
                            <div className="space-y-2 text-sm text-gray-400">
                                <p>📍 EithSpace Sports Center</p>
                                <p>📞 021-12345678</p>
                                <p>📧 info@eithspace.com</p>
                            </div>
                        </div>
                    </div>
                    <div className="mt-10 pt-6 border-t border-white/10 text-center text-xs text-gray-500">
                        © {new Date().getFullYear()} EithSpace. All rights reserved.
                    </div>
                </div>
            </footer>

            {/* Toast Container */}
            <div className="toast-container">
                {toasts.map(toast => (
                    <Toast key={toast.id} message={toast.message} type={toast.type} onClose={() => removeToast(toast.id)} />
                ))}
            </div>
        </div>
    );
}
