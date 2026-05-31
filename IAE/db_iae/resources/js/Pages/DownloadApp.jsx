import React from 'react';
import { Head, Link } from '@inertiajs/react';
import CustomerLayout from '@/Layouts/CustomerLayout';

export default function DownloadApp() {
    return (
        <CustomerLayout title="Download SpaceLink">
            <Head title="Download SpaceLink - EithSpace" />
            
            <div className="bg-[#F8FAFC] min-h-[calc(100vh-80px)] flex flex-col items-center justify-center py-16 px-4">
                <div className="max-w-2xl mx-auto text-center">
                    <div className="mb-8 relative inline-block">
                        <div className="absolute inset-0 bg-accent/20 rounded-full blur-3xl"></div>
                        <img 
                            src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" 
                            alt="Get it on Google Play" 
                            className="w-48 md:w-64 h-auto relative z-10 cursor-pointer hover:scale-105 transition-transform"
                        />
                    </div>
                    
                    <h1 className="text-4xl md:text-5xl font-black text-[#0F172A] mb-6 tracking-tight">
                        Lebih Dekat dengan Komunitas Anda
                    </h1>
                    
                    <p className="text-lg md:text-xl text-[#64748B] mb-10 max-w-xl mx-auto leading-relaxed">
                        Unduh aplikasi <strong className="text-[#0F172A]">SpaceLink</strong> sekarang untuk berinteraksi lebih mudah, bergabung dengan komunitas olahraga favoritmu, dan kelola aktivitasmu dalam satu genggaman.
                    </p>
                    
                    <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
                        <Link 
                            href={route('community.index')}
                            className="px-8 py-3 bg-white border border-[#E2E8F0] hover:bg-gray-50 text-[#0F172A] font-bold rounded-xl transition-colors shadow-sm"
                        >
                            Kembali ke Komunitas
                        </Link>
                    </div>
                </div>
            </div>
        </CustomerLayout>
    );
}
