import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head, Link, router } from '@inertiajs/react';
import { getSportEmoji } from '@/utils/sportTypes';


export default function CartIndex({ cart, cartItems, total }) {
    const handleRemove = (itemId) => {
        if (confirm('Hapus item ini dari keranjang?')) {
            router.delete(route('cart.remove', itemId), { preserveScroll: true });
        }
    };
    const handleClear = () => {
        if (confirm('Kosongkan semua item di keranjang?')) {
            router.delete(route('cart.clear'));
        }
    };

    return (
        <CustomerLayout>
            <Head title="Keranjang Booking" />
            <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <h1 className="text-2xl font-bold text-gray-900 mb-6">🛒 Keranjang Booking</h1>
                {cartItems && cartItems.length > 0 ? (
                    <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                        <div className="lg:col-span-2 space-y-3">
                            {cartItems.map(item => (
                                <div key={item.id} className="card p-4 flex items-center gap-4">
                                    <div className="w-12 h-12 bg-accent/10 rounded-xl flex items-center justify-center flex-shrink-0">
                                        <span className="text-xl">{getSportEmoji(item.venue_field?.venue?.sport_type)}</span>
                                    </div>
                                    <div className="flex-1 min-w-0">
                                        <h3 className="font-semibold text-gray-900 text-sm truncate">{item.venue_field?.venue?.name}</h3>
                                        <p className="text-xs text-gray-500">{item.venue_field?.name}</p>
                                        <p className="text-xs text-gray-500 mt-1">
                                            📅 {new Date(item.date).toLocaleDateString('id-ID', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
                                        </p>
                                        <p className="text-xs text-gray-500">
                                            ⏰ {item.start_time?.substring(0, 5)} - {item.end_time?.substring(0, 5)}
                                        </p>
                                    </div>
                                    <div className="text-right flex-shrink-0">
                                        <p className="font-bold text-primary">Rp {parseInt(item.price).toLocaleString('id-ID')}</p>
                                        <button onClick={() => handleRemove(item.id)} className="text-xs text-red-500 hover:text-red-700 mt-1">Hapus</button>
                                    </div>
                                </div>
                            ))}
                            <button onClick={handleClear} className="btn-ghost btn-sm text-red-600 hover:text-red-700">Kosongkan Keranjang</button>
                        </div>
                        <div className="card p-6 h-fit sticky top-20">
                            <h3 className="font-bold text-gray-900 mb-4">Ringkasan</h3>
                            <div className="space-y-2 text-sm mb-4">
                                <div className="flex justify-between"><span className="text-gray-500">Jumlah Slot</span><span className="font-medium">{cartItems.length} slot</span></div>
                                <div className="flex justify-between border-t border-surface-border pt-2 mt-2">
                                    <span className="font-bold text-gray-900">Subtotal</span>
                                    <span className="font-bold text-primary text-lg">Rp {parseInt(total).toLocaleString('id-ID')}</span>
                                </div>
                            </div>
                            <p className="text-[10px] text-gray-400 mb-4">*Belum termasuk biaya layanan dan pajak</p>
                            <Link href={route('checkout.index')} className="btn-accent w-full">Lanjut ke Pembayaran</Link>
                            <Link href={route('venues.index')} className="btn-ghost w-full mt-2 text-sm">Tambah Slot Lain</Link>
                        </div>
                    </div>
                ) : (
                    <div className="card p-12 text-center">
                        <span className="text-5xl mb-4 block">🛒</span>
                        <h3 className="text-lg font-semibold text-gray-900 mb-2">Keranjang Kosong</h3>
                        <p className="text-gray-500 mb-4">Pilih jadwal lapangan untuk mulai booking</p>
                        <Link href={route('venues.index')} className="btn-accent">Lihat Lapangan</Link>
                    </div>
                )}
            </div>
        </CustomerLayout>
    );
}
