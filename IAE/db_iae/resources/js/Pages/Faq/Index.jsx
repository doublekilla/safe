import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head } from '@inertiajs/react';
import { useState } from 'react';

export default function FaqIndex({ faqs }) {
    const [openIdx, setOpenIdx] = useState(null);
    const categories = faqs ? Object.keys(faqs) : [];

    return (
        <CustomerLayout>
            <Head title="FAQ" />
            <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <div className="text-center mb-10">
                    <h1 className="text-3xl font-bold text-gray-900">❓ Pertanyaan Umum (FAQ)</h1>
                    <p className="text-gray-500 mt-2">Temukan jawaban untuk pertanyaan yang sering diajukan</p>
                </div>
                {categories.length > 0 ? categories.map(category => (
                    <div key={category} className="mb-8">
                        <h2 className="text-lg font-bold text-primary mb-3">{category}</h2>
                        <div className="space-y-2">
                            {faqs[category].map((faq, i) => {
                                const idx = `${category}-${i}`;
                                return (
                                    <div key={idx} className="card overflow-hidden">
                                        <button onClick={() => setOpenIdx(openIdx === idx ? null : idx)} className="w-full flex items-center justify-between p-4 text-left hover:bg-gray-50 transition-colors">
                                            <span className="font-medium text-gray-900 pr-4">{faq.question}</span>
                                            <svg className={`w-5 h-5 text-gray-400 flex-shrink-0 transition-transform ${openIdx === idx ? 'rotate-180' : ''}`} fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" /></svg>
                                        </button>
                                        {openIdx === idx && <div className="px-4 pb-4 text-sm text-gray-600 leading-relaxed animate-fade-in">{faq.answer}</div>}
                                    </div>
                                );
                            })}
                        </div>
                    </div>
                )) : (
                    <div className="card p-12 text-center"><span className="text-5xl mb-4 block">📋</span><p className="text-gray-500">Belum ada FAQ tersedia</p></div>
                )}
                {/* Support contact */}
                <div className="card p-6 text-center mt-8 bg-primary text-white">
                    <h3 className="text-lg font-bold mb-2">Masih punya pertanyaan?</h3>
                    <p className="text-gray-400 text-sm mb-4">Hubungi tim support kami untuk bantuan lebih lanjut</p>
                    <a href="https://wa.me/6281234567890" target="_blank" className="btn-accent">💬 Hubungi via WhatsApp</a>
                </div>
            </div>
        </CustomerLayout>
    );
}
