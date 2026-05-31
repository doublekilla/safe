import AdminLayout from '@/Layouts/AdminLayout';
import { Head, useForm, router } from '@inertiajs/react';
import { useState } from 'react';


export default function CmsIndex({ contents, faqs }) {
    const [tab, setTab] = useState('faqs');
    const faqForm = useForm({ question: '', answer: '', category: 'general', order: 0, is_active: true });
    const [editFaq, setEditFaq] = useState(null);

    const handleAddFaq = (e) => { e.preventDefault(); faqForm.post(route('admin.cms.faqs.store'), { onSuccess: () => faqForm.reset(), preserveScroll: true }); };
    const handleDeleteFaq = (id) => { if (confirm('Hapus FAQ ini?')) router.delete(route('admin.cms.faqs.destroy', id), { preserveScroll: true }); };

    return (
        <AdminLayout title="CMS">
            <Head title="CMS" />
            <h1 className="text-xl font-bold text-gray-900 mb-6">Manajemen Konten</h1>
            <div className="flex gap-2 mb-6">
                {['faqs', 'banners', 'pages'].map(t => (
                    <button key={t} onClick={() => setTab(t)} className={`px-4 py-2 text-sm rounded-lg font-medium capitalize ${tab === t ? 'bg-primary text-white' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}>{t}</button>
                ))}
            </div>

            {tab === 'faqs' && (
                <div className="space-y-6">
                    <div className="card p-6">
                        <h3 className="font-semibold text-gray-900 mb-4">Tambah FAQ</h3>
                        <form onSubmit={handleAddFaq} className="space-y-3">
                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                                <div><label className="input-label">Pertanyaan</label><input type="text" value={faqForm.data.question} onChange={e => faqForm.setData('question', e.target.value)} className="input" /></div>
                                <div><label className="input-label">Kategori</label><select value={faqForm.data.category} onChange={e => faqForm.setData('category', e.target.value)} className="input"><option value="general">General</option><option value="Booking">Booking</option><option value="Pembayaran">Pembayaran</option><option value="Reschedule">Reschedule</option><option value="Fasilitas">Fasilitas</option><option value="Pembatalan">Pembatalan</option></select></div>
                            </div>
                            <div><label className="input-label">Jawaban</label><textarea value={faqForm.data.answer} onChange={e => faqForm.setData('answer', e.target.value)} className="input h-20 resize-none" /></div>
                            <button type="submit" disabled={faqForm.processing} className="btn-accent btn-sm">Tambah FAQ</button>
                        </form>
                    </div>
                    <div className="space-y-2">
                        {faqs?.map(faq => (
                            <div key={faq.id} className="card p-4 flex items-start justify-between">
                                <div>
                                    <span className="badge-neutral text-[10px] mb-1">{faq.category}</span>
                                    <p className="font-medium text-sm text-gray-900">{faq.question}</p>
                                    <p className="text-xs text-gray-500 mt-1">{faq.answer?.substring(0, 100)}...</p>
                                </div>
                                <button onClick={() => handleDeleteFaq(faq.id)} className="btn-ghost btn-sm text-xs text-red-600">Hapus</button>
                            </div>
                        ))}
                    </div>
                </div>
            )}

            {tab === 'banners' && (
                <div className="card p-8 text-center text-gray-400">
                    <span className="text-4xl block mb-2">🖼️</span>
                    <p>Kelola banner promosi dan konten website</p>
                </div>
            )}
            {tab === 'pages' && (
                <div className="card p-8 text-center text-gray-400">
                    <span className="text-4xl block mb-2">📄</span>
                    <p>Kelola halaman: Syarat & Ketentuan, Kebijakan Refund, Kontak</p>
                </div>
            )}
        </AdminLayout>
    );
}
