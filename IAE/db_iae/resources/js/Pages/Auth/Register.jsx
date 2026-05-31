import { Head, Link, useForm } from '@inertiajs/react';
import { useState } from 'react';

export default function Register() {
    const { data, setData, post, processing, errors, reset } = useForm({
        name: '',
        email: '',
        phone: '',
        password: '',
        password_confirmation: '',
    });

    const [showPassword, setShowPassword] = useState(false);

    const submit = (e) => {
        e.preventDefault();
        post(route('register'), {
            onFinish: () => reset('password', 'password_confirmation'),
        });
    };

    return (
        <>
            <Head title="Daftar" />
            <div className="min-h-screen bg-surface-alt flex">
                {/* Left: Branding */}
                <div className="hidden lg:flex lg:w-1/2 bg-gradient-primary relative overflow-hidden items-center justify-center">
                    <div className="absolute inset-0 opacity-10">
                        <div className="absolute top-20 left-10 w-72 h-72 bg-accent rounded-full blur-3xl" />
                        <div className="absolute bottom-10 right-20 w-96 h-96 bg-accent rounded-full blur-3xl" />
                    </div>
                    <div className="relative z-10 text-center px-12">
                        <div className="w-16 h-16 bg-accent rounded-2xl flex items-center justify-center mx-auto mb-6">
                            <span className="text-primary-dark font-black text-2xl">ES</span>
                        </div>
                        <h1 className="text-4xl font-black text-white mb-4">EithSpace</h1>
                        <p className="text-gray-400 text-lg leading-relaxed">
                            Bergabung dan nikmati kemudahan booking lapangan olahraga secara online.
                        </p>
                        <div className="mt-8 grid grid-cols-3 gap-4 text-center">
                            <div className="bg-white/5 backdrop-blur-sm rounded-xl p-3">
                                <span className="text-2xl">🏸</span>
                                <p className="text-white/70 text-xs mt-1">Badminton</p>
                            </div>
                            <div className="bg-white/5 backdrop-blur-sm rounded-xl p-3">
                                <span className="text-2xl">⚽</span>
                                <p className="text-white/70 text-xs mt-1">Futsal</p>
                            </div>
                            <div className="bg-white/5 backdrop-blur-sm rounded-xl p-3">
                                <span className="text-2xl">🏀</span>
                                <p className="text-white/70 text-xs mt-1">Basket</p>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Right: Form */}
                <div className="flex-1 flex items-center justify-center px-4 sm:px-6 lg:px-8 py-8">
                    <div className="w-full max-w-md">
                        <div className="lg:hidden text-center mb-8">
                            <Link href="/" className="inline-flex items-center gap-2.5">
                                <div className="w-10 h-10 bg-gradient-primary rounded-xl flex items-center justify-center">
                                    <span className="text-accent font-black text-sm">ES</span>
                                </div>
                                <span className="text-2xl font-bold text-primary">EithSpace</span>
                            </Link>
                        </div>

                        <div className="card p-8">
                            <div className="text-center mb-8">
                                <h2 className="text-2xl font-bold text-gray-900">Daftar</h2>
                                <p className="text-gray-500 mt-1">Buat akun EithSpace baru</p>
                            </div>

                            <form onSubmit={submit} className="space-y-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1.5">Nama Lengkap</label>
                                    <input
                                        type="text"
                                        value={data.name}
                                        onChange={(e) => setData('name', e.target.value)}
                                        className="input w-full"
                                        placeholder="Nama lengkap kamu"
                                        required
                                        autoFocus
                                    />
                                    {errors.name && <p className="text-red-500 text-xs mt-1">{errors.name}</p>}
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1.5">Email</label>
                                    <input
                                        type="email"
                                        value={data.email}
                                        onChange={(e) => setData('email', e.target.value)}
                                        className="input w-full"
                                        placeholder="email@example.com"
                                        required
                                    />
                                    {errors.email && <p className="text-red-500 text-xs mt-1">{errors.email}</p>}
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1.5">No. Telepon</label>
                                    <input
                                        type="tel"
                                        value={data.phone}
                                        onChange={(e) => setData('phone', e.target.value)}
                                        className="input w-full"
                                        placeholder="08xxxxxxxxxx"
                                        required
                                    />
                                    {errors.phone && <p className="text-red-500 text-xs mt-1">{errors.phone}</p>}
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1.5">Password</label>
                                    <div className="relative">
                                        <input
                                            type={showPassword ? 'text' : 'password'}
                                            value={data.password}
                                            onChange={(e) => setData('password', e.target.value)}
                                            className="input w-full pr-10"
                                            placeholder="Minimal 8 karakter"
                                            required
                                        />
                                        <button
                                            type="button"
                                            onClick={() => setShowPassword(!showPassword)}
                                            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                                        >
                                            {showPassword ? '🙈' : '👁️'}
                                        </button>
                                    </div>
                                    {errors.password && <p className="text-red-500 text-xs mt-1">{errors.password}</p>}
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1.5">Konfirmasi Password</label>
                                    <input
                                        type="password"
                                        value={data.password_confirmation}
                                        onChange={(e) => setData('password_confirmation', e.target.value)}
                                        className="input w-full"
                                        placeholder="Ulangi password"
                                        required
                                    />
                                    {errors.password_confirmation && <p className="text-red-500 text-xs mt-1">{errors.password_confirmation}</p>}
                                </div>

                                <button type="submit" disabled={processing} className="btn-accent w-full py-3 font-semibold mt-2">
                                    {processing ? 'Memproses...' : 'Daftar'}
                                </button>

                                <div className="mt-6">
                                    <div className="relative">
                                        <div className="absolute inset-0 flex items-center">
                                            <div className="w-full border-t border-gray-200"></div>
                                        </div>
                                        <div className="relative flex justify-center text-sm">
                                            <span className="px-2 bg-white text-gray-500">Atau daftar dengan</span>
                                        </div>
                                    </div>

                                    <div className="mt-6">
                                        <a
                                            href={route('auth.google')}
                                            className="w-full flex items-center justify-center gap-3 px-4 py-3 border border-gray-300 rounded-xl shadow-sm bg-white text-sm font-medium text-gray-700 hover:bg-gray-50 transition-colors"
                                        >
                                            <svg className="w-5 h-5" viewBox="0 0 24 24">
                                                <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4" />
                                                <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" />
                                                <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05" />
                                                <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" />
                                            </svg>
                                            Google
                                        </a>
                                    </div>
                                </div>
                            </form>

                            <p className="text-center text-sm text-gray-500 mt-6">
                                Sudah punya akun?{' '}
                                <Link href={route('login')} className="text-accent hover:text-accent-dark font-semibold">
                                    Masuk
                                </Link>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </>
    );
}
