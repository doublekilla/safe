import React, { useState } from 'react';
import { Head, Link, useForm, router } from '@inertiajs/react';
import CustomerLayout from '@/Layouts/CustomerLayout';
import { getSportEmoji } from '@/utils/sportTypes';

// --- Subcomponents ---

const CommunityHero = ({ stats }) => (
    <section className="relative bg-gradient-primary overflow-hidden">
        <div className="absolute inset-0 opacity-10">
            <div className="absolute top-20 left-10 w-72 h-72 bg-accent rounded-full blur-3xl" />
            <div className="absolute bottom-10 right-20 w-96 h-96 bg-accent rounded-full blur-3xl" />
        </div>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 lg:py-28 relative z-10">
            <div className="text-center max-w-3xl mx-auto">
                <div className="inline-flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-1.5 rounded-full mb-6 animate-fade-in">
                    <span className="w-2 h-2 bg-accent rounded-full animate-pulse-soft" />
                    <span className="text-white/80 text-sm font-medium">Komunitas Olahraga EithSpace</span>
                </div>
                <h1 className="text-4xl sm:text-5xl lg:text-6xl font-black text-white leading-tight tracking-tight mb-6 animate-fade-in-up">
                    Temukan <span className="text-gradient bg-gradient-to-r from-accent to-accent-light bg-clip-text text-transparent">Komunitas Olahraga</span> <br className="hidden md:block" /> yang Sesuai Gaya Mainmu
                </h1>
                <p className="text-gray-400 text-lg sm:text-xl leading-relaxed mb-8 animate-fade-in-up">
                    Gabung dengan komunitas olahraga di sekitarmu. Cari teman bermain, diskusi jadwal, dan bangun rutinitas olahraga bersama anggota EithSpace.
                </p>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6 max-w-2xl mx-auto mt-12 animate-fade-in-up">
                    <div className="bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl p-6 hover:-translate-y-1 transition-transform duration-200">
                        <div className="text-3xl font-black text-white mb-1">{stats?.active_members ?? '0'}</div>
                        <div className="text-gray-400 text-sm">Anggota Aktif</div>
                    </div>
                    <div className="bg-white/5 backdrop-blur-sm border border-white/10 rounded-2xl p-6 hover:-translate-y-1 transition-transform duration-200">
                        <div className="text-3xl font-black text-white mb-1">{stats?.total_communities ?? '0'}</div>
                        <div className="text-gray-400 text-sm">Komunitas</div>
                    </div>
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



const CommunityCard = ({ community }) => (
    <div className="bg-white border border-[#E2E8F0] rounded-2xl p-6 shadow-[0_4px_6px_-1px_rgba(0,0,0,0.05)] hover:shadow-[0_10px_15px_-3px_rgba(0,0,0,0.1)] transition-all duration-200 hover:-translate-y-1 flex flex-col h-full">
        <div className="flex items-start gap-4 mb-4">
            <div className="w-12 h-12 rounded-xl bg-[#F8FAFC] border border-[#E2E8F0] flex items-center justify-center text-2xl shrink-0 overflow-hidden p-1">
                {community.image ? (
                    <img src={community.image.startsWith('http') ? community.image : (community.image.startsWith('/') ? community.image : (community.image.startsWith('storage/') ? `/${community.image}` : `/storage/${community.image}`))} alt={community.name} className="w-full h-full object-contain" />
                ) : (
                    getSportEmoji(community.sport_category)
                )}
            </div>
            <div>
                <h3 className="font-bold text-[#0F172A] text-lg leading-tight mb-1">{community.name}</h3>
                <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-sm text-[#64748B]">
                    <span className="flex items-center gap-1">📍 {community.location}</span>
                    <span className="flex items-center gap-1 capitalize">🏷️ {community.sport_category}</span>
                </div>
            </div>
        </div>
        
        <div className="flex flex-wrap gap-2 mb-4">
            <span className="px-2.5 py-1 bg-[#F8FAFC] border border-[#E2E8F0] rounded-md text-xs font-medium text-[#0F172A]">
                👥 {community.memberships_count} anggota
            </span>
            <span className="px-2.5 py-1 bg-[#F8FAFC] border border-[#E2E8F0] rounded-md text-xs font-medium text-[#0F172A]">
                ⭐ {community.activity_frequency ?? 'Aktif'}
            </span>
        </div>
        
        <p className="text-[#64748B] text-sm flex-1 mb-5 line-clamp-3">
            {community.description}
        </p>
        
        <div className="pt-4 border-t border-[#E2E8F0] flex items-center justify-between mt-auto">
            <div className="text-xs text-[#64748B]">
                <span className="font-medium text-primary">{community.feed_posts_count}</span> diskusi
            </div>
            <Link href={route('community.show', community.id)} className="px-4 py-2 bg-accent hover:bg-accent-hover text-primary hover:text-primary text-sm font-bold rounded-lg transition-colors">
                Detail
            </Link>
        </div>
    </div>
);

const CommunityGrid = ({ communities }) => (
    <section className="bg-[#F8FAFC] py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-6xl mx-auto">
            <div className="mb-10 text-center md:text-left flex flex-col md:flex-row md:items-end justify-between gap-4">
                <div>
                    <h2 className="text-3xl font-bold text-primary mb-2">Komunitas EithSpace</h2>
                    <p className="text-gray-500">Pilih komunitas yang paling sesuai dengan minat dan level bermainmu.</p>
                </div>
                <Link href={route('community.browse')} className="text-accent font-medium hover:underline text-sm">Lihat Semua Komunitas →</Link>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {communities.length > 0 ? (
                    communities.map(community => (
                        <CommunityCard key={community.id} community={community} />
                    ))
                ) : (
                    <div className="col-span-full text-center py-12 text-gray-500">
                        Belum ada komunitas yang sesuai dengan pencarian Anda.
                    </div>
                )}
            </div>
        </div>
    </section>
);

const CommunityDiscussionForum = ({ recentDiscussions, communities }) => {
    return (
        <section className="bg-white py-16 px-4 sm:px-6 lg:px-8 border-y border-[#E2E8F0]">
            <div className="max-w-3xl mx-auto">
                <div className="text-center mb-10">
                    <h2 className="text-3xl font-bold text-[#0F172A] mb-3">Forum Diskusi Komunitas</h2>
                    <p className="text-[#64748B]">Diskusikan jadwal, cari partner bermain, atau bagikan pengalaman bersama anggota lain.</p>
                </div>

                <div className="space-y-4">
                    {recentDiscussions.length > 0 ? (
                        recentDiscussions.map(post => (
                            <div key={post.id} className="bg-white border border-[#E2E8F0] rounded-2xl p-5 hover:shadow-[0_4px_6px_-1px_rgba(0,0,0,0.05)] transition-shadow">
                                <div className="flex gap-4">
                                    <div className="w-10 h-10 rounded-full bg-gradient-primary border border-[#E2E8F0] flex items-center justify-center font-bold text-white shrink-0 overflow-hidden">
                                        {post.user?.avatar ? (
                                            <img src={`/storage/${post.user.avatar}`} alt={post.user.name} className="w-full h-full object-cover" />
                                        ) : (
                                            post.user?.name ? post.user.name.charAt(0) : 'U'
                                        )}
                                    </div>
                                    <div className="flex-1">
                                        <div className="flex items-center gap-2 mb-1">
                                            <h4 className="font-bold text-[#0F172A] text-sm">{post.user?.name ?? 'Pengguna SpaceLink'}</h4>
                                            <span className="text-xs text-[#64748B] bg-[#F8FAFC] px-2 py-0.5 rounded-full border border-[#E2E8F0]">{post.community?.name}</span>
                                        </div>
                                        <p className="text-[#0F172A] text-sm leading-relaxed mb-4">{post.text}</p>
                                        
                                        {post.image && (
                                            <div className="mb-4 rounded-xl overflow-hidden border border-[#E2E8F0] bg-[#F8FAFC] flex justify-center items-center p-2">
                                                <img 
                                                    src={post.image.startsWith('http') ? post.image : (post.image.startsWith('/') ? post.image : (post.image.startsWith('storage/') ? '/' + post.image : '/storage/' + post.image))} 
                                                    alt="Post image" 
                                                    className="max-h-80 w-auto object-contain rounded"
                                                />
                                            </div>
                                        )}

                                        <div className="flex items-center justify-between text-sm w-full">
                                            <button className="flex items-center gap-1.5 text-gray-500 hover:text-accent transition-colors">
                                                ❤️ <span>{post.likes_count ?? 0} suka</span>
                                            </button>
                                            <span className="text-gray-400 text-xs">
                                                {new Date(post.created_at).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })}
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        ))
                    ) : (
                        <div className="text-center py-8 text-gray-500">
                            Belum ada diskusi terbaru.
                        </div>
                    )}
                </div>
            </div>
        </section>
    );
};

const ActiveCommunityRanking = ({ activeCommunities }) => (
    <section className="bg-[#F8FAFC] py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto">
            <div className="text-center mb-10">
                <h2 className="text-3xl font-bold text-[#0F172A] mb-3">Komunitas Teraktif Bulan Ini</h2>
                <p className="text-[#64748B]">Lihat komunitas dengan aktivitas diskusi dan jumlah anggota paling aktif.</p>
            </div>
            
            <div className="bg-white border border-[#E2E8F0] rounded-2xl overflow-hidden shadow-[0_4px_6px_-1px_rgba(0,0,0,0.05)]">
                <div className="divide-y divide-[#E2E8F0]">
                    {activeCommunities.map((community, index) => (
                        <div key={community.id} className="p-4 sm:p-5 flex items-center gap-4 hover:bg-[#F8FAFC] transition-colors">
                            <div className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm shrink-0 ${index < 3 ? 'bg-accent text-primary shadow-md' : 'bg-[#E2E8F0] text-[#64748B]'}`}>
                                {index + 1}
                            </div>
                            <div className="w-10 h-10 rounded-xl bg-[#F8FAFC] border border-[#E2E8F0] flex items-center justify-center text-xl shrink-0 hidden sm:flex overflow-hidden p-1">
                                {community.image ? (
                                    <img src={community.image.startsWith('http') ? community.image : (community.image.startsWith('/') ? community.image : (community.image.startsWith('storage/') ? `/${community.image}` : `/storage/${community.image}`))} alt={community.name} className="w-full h-full object-contain" />
                                ) : (
                                    getSportEmoji(community.sport_category)
                                )}
                            </div>
                            <div className="flex-1 min-w-0">
                                <h4 className="font-bold text-primary truncate capitalize">{community.name}</h4>
                                <div className="text-sm text-gray-500 flex items-center gap-3 mt-1">
                                    <span className="truncate capitalize">{community.sport_category}</span>
                                </div>
                            </div>
                            <div className="text-right shrink-0">
                                <div className="text-sm font-medium text-primary">{community.memberships_count} Anggota</div>
                                <div className="text-xs text-accent font-medium">{community.feed_posts_count} Diskusi</div>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    </section>
);

const HowToJoinCommunity = () => {
    const steps = [
        { title: 'Buat Akun', description: 'Daftar atau masuk ke akun EithSpace.', icon: '👤' },
        { title: 'Cari Komunitas', description: 'Gunakan filter olahraga, lokasi, dan level permainan.', icon: '🔍' },
        { title: 'Gabung Komunitas', description: 'Pilih komunitas yang sesuai, lalu klik tombol Gabung.', icon: '🤝' },
        { title: 'Mulai Berinteraksi', description: 'Ikuti diskusi, cari informasi jadwal, dan bangun rutinitas bermain.', icon: '💬' }
    ];

    return (
        <section className="bg-white py-16 px-4 sm:px-6 lg:px-8 border-y border-[#E2E8F0]">
            <div className="max-w-6xl mx-auto">
                <div className="text-center mb-12">
                    <h2 className="text-3xl font-bold text-[#0F172A] mb-3">Cara Gabung Komunitas</h2>
                    <p className="text-[#64748B]">4 langkah mudah untuk mulai berinteraksi.</p>
                </div>
                
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                    {steps.map((step, index) => (
                        <div key={index} className="bg-[#F8FAFC] border border-[#E2E8F0] rounded-2xl p-6 relative">
                            <div className="w-12 h-12 rounded-xl bg-white border border-[#E2E8F0] text-accent flex items-center justify-center text-xl mb-4 shadow-sm">
                                {step.icon}
                            </div>
                            <h4 className="font-bold text-[#0F172A] text-lg mb-2">{step.title}</h4>
                            <p className="text-[#64748B] text-sm leading-relaxed">{step.description}</p>
                            {index < steps.length - 1 && (
                                <div className="hidden lg:block absolute top-12 right-0 translate-x-1/2 w-6 h-0.5 bg-[#E2E8F0]"></div>
                            )}
                        </div>
                    ))}
                </div>
            </div>
        </section>
    );
};

const CommunityFAQ = () => {
    const [openIndex, setOpenIndex] = useState(null);
    const faqs = [
        { question: 'Apakah bergabung komunitas harus membayar?', answer: 'Bergabung dengan komunitas di EithSpace 100% gratis. Anda hanya membayar saat melakukan booking lapangan untuk bermain bersama.' },
        { question: 'Apakah saya bisa membuat komunitas sendiri?', answer: 'Saat ini pembuatan komunitas baru dikelola oleh tim EithSpace. Namun, Anda dapat menyarankan pembuatan komunitas baru melalui layanan pelanggan kami.' },
        { question: 'Bagaimana cara mencari partner bermain?', answer: 'Anda dapat bergabung dengan komunitas yang sesuai dengan minat Anda, lalu membuat postingan di forum diskusi untuk mencari partner bermain dengan jadwal yang pas.' },
        { question: 'Apakah komunitas hanya untuk pemain berpengalaman?', answer: 'Tidak! Kami memiliki banyak komunitas yang ditujukan untuk level pemula hingga menengah yang ingin berolahraga santai dan mencari teman baru.' },
        { question: 'Apakah saya bisa keluar dari komunitas?', answer: 'Tentu. Anda dapat meninggalkan komunitas kapan saja tanpa syarat apapun.' },
        { question: 'Apakah saya bisa bergabung ke lebih dari satu komunitas?', answer: 'Ya, Anda bebas bergabung dengan berbagai komunitas olahraga yang berbeda sesuai dengan minat Anda.' }
    ];

    return (
        <section className="bg-[#F8FAFC] py-16 px-4 sm:px-6 lg:px-8">
            <div className="max-w-3xl mx-auto">
                <div className="text-center mb-10">
                    <h2 className="text-3xl font-bold text-[#0F172A] mb-3">Pertanyaan Umum Komunitas</h2>
                    <p className="text-[#64748B]">Informasi yang sering ditanyakan.</p>
                </div>
                
                <div className="space-y-3">
                    {faqs.map((faq, index) => {
                        const isOpen = openIndex === index;
                        return (
                            <div key={index} className="bg-white border border-[#E2E8F0] rounded-xl overflow-hidden transition-all duration-200">
                                <button 
                                    className="w-full text-left px-6 py-4 flex items-center justify-between focus:outline-none"
                                    onClick={() => setOpenIndex(isOpen ? null : index)}
                                    aria-expanded={isOpen}
                                >
                                    <span className="font-semibold text-[#0F172A] pr-4">{faq.question}</span>
                                    <span className={`text-[#64748B] transition-transform duration-200 shrink-0 ${isOpen ? 'rotate-180' : ''}`}>
                                        ▼
                                    </span>
                                </button>
                                {isOpen && (
                                    <div className="px-6 pb-4 text-[#64748B] text-sm leading-relaxed border-t border-[#E2E8F0] pt-3">
                                        {faq.answer}
                                    </div>
                                )}
                            </div>
                        );
                    })}
                </div>
            </div>
        </section>
    );
};

const CommunityCTA = () => (
    <section className="bg-[#FFFFFF] py-16 px-4 sm:px-6 lg:px-8">
        <div className="max-w-4xl mx-auto">
            <div className="bg-gradient-primary rounded-[24px] p-10 md:p-16 text-center shadow-xl relative overflow-hidden">
                {/* Decorative element */}
                <div className="absolute top-0 right-0 w-64 h-64 bg-accent rounded-full opacity-10 blur-3xl -translate-y-1/2 translate-x-1/2 pointer-events-none"></div>
                <div className="absolute bottom-0 left-0 w-64 h-64 bg-accent rounded-full opacity-10 blur-3xl translate-y-1/2 -translate-x-1/2 pointer-events-none"></div>
                
                <h2 className="text-3xl md:text-4xl font-bold text-white mb-4 relative z-10">Mulai Bangun Koneksi Olahragamu</h2>
                <p className="text-gray-300 text-lg mb-8 max-w-2xl mx-auto relative z-10 leading-relaxed">
                    Gabung dengan komunitas EithSpace dan temukan teman bermain sesuai olahraga, lokasi, dan level permainanmu.
                </p>
                <Link href={route('download.app')} className="inline-block px-8 py-3.5 bg-accent hover:bg-accent-hover text-primary font-bold rounded-xl transition-all duration-200 hover:-translate-y-0.5 shadow-lg relative z-10">
                    Gabung Sekarang
                </Link>
            </div>
        </div>
    </section>
);

// --- Main Page Component ---

export default function CommunityPage({ communities, activeCommunities, recentDiscussions, filters, stats }) {
    return (
        <CustomerLayout title="Komunitas">
            <Head title="Komunitas - EithSpace" />
            <div className="bg-surface-alt">
                <CommunityHero stats={stats} />
                <CommunityGrid communities={communities} />
                <CommunityDiscussionForum recentDiscussions={recentDiscussions} communities={communities} />
                <ActiveCommunityRanking activeCommunities={activeCommunities} />
                <HowToJoinCommunity />
                <CommunityFAQ />
                <CommunityCTA />
            </div>
        </CustomerLayout>
    );
}
