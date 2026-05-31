import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head, Link } from '@inertiajs/react';
import { useState } from 'react';
import { getSportEmoji, getSportLabel, getSportBadge } from '@/utils/sportTypes';


function HeroSection() {
    return (
        <section className="relative bg-gradient-primary overflow-hidden">
            <div className="absolute inset-0 opacity-10">
                <div className="absolute top-20 left-10 w-72 h-72 bg-accent rounded-full blur-3xl" />
                <div className="absolute bottom-10 right-20 w-96 h-96 bg-accent rounded-full blur-3xl" />
            </div>
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 lg:py-28 relative z-10">
                <div className="text-center max-w-3xl mx-auto">
                    <div className="inline-flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-1.5 rounded-full mb-6 animate-fade-in">
                        <span className="w-2 h-2 bg-accent rounded-full animate-pulse-soft" />
                        <span className="text-white/80 text-sm font-medium">Booking Lapangan Jadi Mudah</span>
                    </div>
                    <h1 className="text-4xl sm:text-5xl lg:text-6xl font-black text-white leading-tight tracking-tight mb-6 animate-fade-in-up">
                        Sewa Lapangan<br />
                        <span className="text-gradient bg-gradient-to-r from-accent to-accent-light bg-clip-text text-transparent">
                            Olahraga
                        </span>
                    </h1>
                    <p className="text-gray-400 text-lg sm:text-xl leading-relaxed mb-8 animate-fade-in-up">
                        Platform booking lapangan olahraga terpercaya. Cek jadwal real-time, booking instan, dan bayar online dalam satu platform.
                    </p>
                    <div className="flex flex-col sm:flex-row items-center justify-center gap-4 animate-fade-in-up">
                        <Link href={route('venues.index')} className="btn-accent btn-lg w-full sm:w-auto">
                            Lihat Lapangan
                        </Link>
                        <a href="#how-it-works" className="btn btn-lg bg-white/10 text-white hover:bg-white/20 w-full sm:w-auto backdrop-blur-sm">
                            Cara Booking →
                        </a>
                    </div>
                </div>
            </div>
            {/* Wave divider */}
            <div className="absolute bottom-0 left-0 right-0">
                <svg viewBox="0 0 1440 80" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M0 80L60 68C120 56 240 32 360 24C480 16 600 24 720 32C840 40 960 48 1080 44C1200 40 1320 24 1380 16L1440 8V80H1380C1320 80 1200 80 1080 80C960 80 840 80 720 80C600 80 480 80 360 80C240 80 120 80 60 80H0Z" fill="#f8f9fa" />
                </svg>
            </div>
        </section>
    );
}



function FeaturedVenuesSection({ venues }) {
    if (!venues || venues.length === 0) return null;

    return (
        <section className="py-16 bg-white">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="flex items-center justify-between mb-10">
                    <div>
                        <h2 className="section-title">Lapangan Populer</h2>
                        <p className="section-subtitle mt-1">Pilihan lapangan terbaik untuk kamu</p>
                    </div>
                    <Link href={route('venues.index')} className="btn-outline btn-sm hidden sm:flex">
                        Lihat Semua →
                    </Link>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                    {venues.map(venue => (
                        <Link key={venue.id} href={route('venues.show', venue.id)} className="card-hover group overflow-hidden">
                            <div className="aspect-video bg-gradient-to-br from-gray-200 to-gray-100 relative overflow-hidden">
                                {venue.photos && venue.photos.length > 0 ? (
                                    <img src={`/storage/${venue.photos[0]}`} alt={venue.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
                                ) : (
                                    <div className="w-full h-full flex items-center justify-center">
                                        <span className="text-5xl">{getSportEmoji(venue.sport_type)}</span>
                                    </div>
                                )}
                                <div className="absolute top-3 left-3">
                                    <span className={`badge ${getSportBadge(venue.sport_type)}`}>
                                        {getSportEmoji(venue.sport_type)} {getSportLabel(venue.sport_type)}
                                    </span>
                                </div>
                                {venue.average_rating > 0 && (
                                    <div className="absolute top-3 right-3 bg-black/60 backdrop-blur-sm text-white px-2 py-1 rounded-lg flex items-center gap-1">
                                        <span className="text-amber-400 text-xs">★</span>
                                        <span className="text-xs font-semibold">{parseFloat(venue.average_rating).toFixed(1)}</span>
                                    </div>
                                )}
                            </div>
                            <div className="p-4">
                                <h3 className="font-bold text-gray-900 mb-1 group-hover:text-accent transition-colors">{venue.name}</h3>
                                <p className="text-sm text-gray-500 mb-3 flex items-center gap-1">
                                    <span>📍</span> {venue.location}
                                </p>
                                <div className="flex items-center justify-between">
                                    <div>
                                        <span className="text-lg font-bold text-primary">Rp {parseInt(venue.price_per_hour).toLocaleString('id-ID')}</span>
                                        <span className="text-xs text-gray-400">/jam</span>
                                    </div>
                                    <span className="btn-accent btn-sm">Booking</span>
                                </div>
                            </div>
                        </Link>
                    ))}
                </div>
                <div className="text-center mt-6 sm:hidden">
                    <Link href={route('venues.index')} className="btn-outline">Lihat Semua Lapangan</Link>
                </div>
            </div>
        </section>
    );
}

function HowItWorksSection() {
    const steps = [
        { num: '01', title: 'Pilih Lapangan', desc: 'Pilih jenis olahraga dan lapangan yang tersedia sesuai preferensi kamu.', icon: '🏟️' },
        { num: '02', title: 'Pilih Jadwal', desc: 'Cek jadwal real-time dan pilih jam yang tersedia. Tambahkan ke keranjang.', icon: '📅' },
        { num: '03', title: 'Bayar Online', desc: 'Lakukan pembayaran melalui transfer bank atau e-wallet.', icon: '💳' },
        { num: '04', title: 'Main!', desc: 'Datang ke lapangan sesuai jadwal. Tunjukkan kode booking kamu.', icon: '🎉' },
    ];

    return (
        <section id="how-it-works" className="py-16 bg-surface-alt">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="text-center mb-12">
                    <h2 className="section-title">Cara Booking</h2>
                    <p className="section-subtitle mt-2">4 langkah mudah untuk booking lapangan</p>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                    {steps.map((step, i) => (
                        <div key={i} className="card p-6 text-center relative group hover:shadow-card-hover transition-all">
                            <div className="absolute -top-3 left-1/2 -translate-x-1/2 bg-accent text-primary-dark text-xs font-black px-3 py-1 rounded-full">
                                {step.num}
                            </div>
                            <div className="text-4xl mb-4 mt-2">{step.icon}</div>
                            <h3 className="font-bold text-gray-900 mb-2">{step.title}</h3>
                            <p className="text-sm text-gray-500 leading-relaxed">{step.desc}</p>
                        </div>
                    ))}
                </div>
            </div>
        </section>
    );
}

function WhyChooseSection() {
    const features = [
        { title: 'Jadwal Real-Time', desc: 'Cek ketersediaan lapangan secara langsung, tanpa perlu telepon.', icon: '⚡' },
        { title: 'Pembayaran Aman', desc: 'Bayar melalui berbagai metode pembayaran yang aman dan terpercaya.', icon: '🔒' },
        { title: 'Konfirmasi Instan', desc: 'Dapatkan kode booking dan invoice langsung setelah pembayaran.', icon: '✅' },
        { title: 'Reschedule Mudah', desc: 'Ubah jadwal dengan mudah melalui platform, tanpa ribet.', icon: '🔄' },
        { title: 'Fasilitas Lengkap', desc: 'Parkir luas, ruang ganti, kantin, dan perlengkapan olahraga.', icon: '🏆' },
        { title: 'Support 24/7', desc: 'Tim kami siap membantu kamu kapan saja melalui WhatsApp.', icon: '💬' },
    ];

    return (
        <section className="py-16 bg-white">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="text-center mb-12">
                    <h2 className="section-title">Kenapa EithSpace?</h2>
                    <p className="section-subtitle mt-2">Pengalaman booking lapangan yang premium dan mudah</p>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                    {features.map((f, i) => (
                        <div key={i} className="flex gap-4 p-5 rounded-card hover:bg-surface-alt transition-colors group">
                            <div className="w-12 h-12 bg-accent/10 rounded-xl flex items-center justify-center flex-shrink-0 group-hover:bg-accent/20 transition-colors">
                                <span className="text-2xl">{f.icon}</span>
                            </div>
                            <div>
                                <h3 className="font-bold text-gray-900 mb-1">{f.title}</h3>
                                <p className="text-sm text-gray-500 leading-relaxed">{f.desc}</p>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </section>
    );
}

function FaqSection({ faqs }) {
    const [openIdx, setOpenIdx] = useState(null);
    const faqList = faqs || [];

    if (faqList.length === 0) return null;

    return (
        <section className="py-16 bg-surface-alt">
            <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
                <div className="text-center mb-10">
                    <h2 className="section-title">Pertanyaan Umum</h2>
                    <p className="section-subtitle mt-2">Informasi yang sering ditanyakan</p>
                </div>
                <div className="space-y-3">
                    {faqList.map((faq, i) => (
                        <div key={faq.id || i} className="card overflow-hidden">
                            <button
                                onClick={() => setOpenIdx(openIdx === i ? null : i)}
                                className="w-full flex items-center justify-between p-4 text-left hover:bg-gray-50 transition-colors"
                            >
                                <span className="font-medium text-gray-900 pr-4">{faq.question}</span>
                                <svg className={`w-5 h-5 text-gray-400 flex-shrink-0 transition-transform duration-200 ${openIdx === i ? 'rotate-180' : ''}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                                </svg>
                            </button>
                            {openIdx === i && (
                                <div className="px-4 pb-4 text-sm text-gray-600 leading-relaxed animate-fade-in">
                                    {faq.answer}
                                </div>
                            )}
                        </div>
                    ))}
                </div>
                <div className="text-center mt-6">
                    <Link href={route('faq.index')} className="btn-ghost">Lihat Semua FAQ →</Link>
                </div>
            </div>
        </section>
    );
}

function CtaSection() {
    return (
        <section className="py-16 bg-gradient-primary relative overflow-hidden">
            <div className="absolute inset-0 opacity-5">
                <div className="absolute top-0 right-0 w-96 h-96 bg-accent rounded-full blur-3xl" />
            </div>
            <div className="max-w-3xl mx-auto px-4 text-center relative z-10">
                <h2 className="text-3xl sm:text-4xl font-black text-white mb-4">Siap Main?</h2>
                <p className="text-gray-400 text-lg mb-8">Booking lapangan sekarang dan nikmati pengalaman olahraga terbaik di EithSpace.</p>
                <Link href={route('venues.index')} className="btn-accent btn-lg">
                    Booking Sekarang 🚀
                </Link>
            </div>
        </section>
    );
}

export default function Welcome({ featuredVenues, faqs }) {
    return (
        <CustomerLayout>
            <Head title="EithSpace - Booking Lapangan Olahraga" />
            <HeroSection />

            <FeaturedVenuesSection venues={featuredVenues} />
            <HowItWorksSection />
            <WhyChooseSection />
            <FaqSection faqs={faqs} />
            <CtaSection />
        </CustomerLayout>
    );
}
