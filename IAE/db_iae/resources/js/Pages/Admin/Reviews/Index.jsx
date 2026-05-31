import AdminLayout from '@/Layouts/AdminLayout';
import { Head, router, useForm } from '@inertiajs/react';
import { useState } from 'react';


export default function ReviewsIndex({ reviews, filters }) {
    const [replyId, setReplyId] = useState(null);
    const replyForm = useForm({ admin_reply: '' });

    const handleReply = (reviewId) => {
        replyForm.post(route('admin.reviews.reply', reviewId), { onSuccess: () => { setReplyId(null); replyForm.reset(); }, preserveScroll: true });
    };

    return (
        <AdminLayout title="Manajemen Ulasan">
            <Head title="Manajemen Ulasan" />
            <h1 className="text-xl font-bold text-gray-900 mb-6">Manajemen Ulasan</h1>
            <div className="space-y-4">
                {reviews?.data?.map(review => (
                    <div key={review.id} className={`card p-5 ${!review.is_visible ? 'opacity-50' : ''}`}>
                        <div className="flex items-start justify-between mb-3">
                            <div className="flex items-center gap-3">
                                <div className="w-10 h-10 bg-primary rounded-full flex items-center justify-center"><span className="text-accent text-sm font-bold">{review.user?.name?.charAt(0)}</span></div>
                                <div>
                                    <p className="font-semibold text-sm">{review.user?.name}</p>
                                    <p className="text-xs text-gray-400">{review.venue?.name} | {new Date(review.created_at).toLocaleDateString('id-ID')}</p>
                                </div>
                            </div>
                            <div className="flex items-center gap-2">
                                <div className="flex gap-0.5">{[1,2,3,4,5].map(s => <span key={s} className={`text-sm ${s <= review.rating ? 'text-amber-400' : 'text-gray-300'}`}>★</span>)}</div>
                                <button onClick={() => router.put(route('admin.reviews.toggle-visibility', review.id), {}, { preserveScroll: true })} className={`btn-ghost btn-sm text-xs ${review.is_visible ? 'text-gray-500' : 'text-emerald-600'}`}>
                                    {review.is_visible ? 'Sembunyikan' : 'Tampilkan'}
                                </button>
                            </div>
                        </div>
                        {review.comment && <p className="text-sm text-gray-600 mb-3">{review.comment}</p>}
                        {review.admin_reply && (
                            <div className="p-3 bg-accent/5 rounded-lg border-l-2 border-accent mb-3">
                                <p className="text-xs font-semibold text-accent-dark">Balasan Admin:</p>
                                <p className="text-sm text-gray-600">{review.admin_reply}</p>
                            </div>
                        )}
                        {replyId === review.id ? (
                            <div className="flex gap-2">
                                <input type="text" value={replyForm.data.admin_reply} onChange={e => replyForm.setData('admin_reply', e.target.value)} className="input flex-1" placeholder="Tulis balasan..." />
                                <button onClick={() => handleReply(review.id)} className="btn-accent btn-sm">Kirim</button>
                                <button onClick={() => setReplyId(null)} className="btn-ghost btn-sm">Batal</button>
                            </div>
                        ) : (
                            <button onClick={() => setReplyId(review.id)} className="text-xs text-accent font-medium hover:text-accent-dark">Balas →</button>
                        )}
                    </div>
                ))}
            </div>
        </AdminLayout>
    );
}
