import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head, Link } from '@inertiajs/react';


export default function Dashboard({ activeBookings, recentBookings, stats }) {
    const statCards = [
        { label: 'Total Booking', value: stats.total_bookings, icon: '📋', color: 'bg-blue-50 text-blue-700' },
        { label: 'Booking Aktif', value: stats.active_bookings, icon: '🎯', color: 'bg-emerald-50 text-emerald-700' },
        { label: 'Selesai', value: stats.completed_bookings, icon: '✅', color: 'bg-amber-50 text-amber-700' },
        { label: 'Keranjang', value: stats.cart_items, icon: '🛒', color: 'bg-purple-50 text-purple-700' },
    ];

    const getStatusBadge = (status) => {
        const map = {
            pending: 'badge-warning',
            confirmed: 'badge-info',
            completed: 'badge-success',
            cancelled: 'badge-danger',
            reschedule_requested: 'badge-warning',
            rescheduled: 'badge-info',
        };
        const labels = {
            pending: 'Menunggu', confirmed: 'Dikonfirmasi', completed: 'Selesai',
            cancelled: 'Dibatalkan', reschedule_requested: 'Minta Reschedule', rescheduled: 'Dijadwal Ulang',
        };
        return <span className={map[status] || 'badge-neutral'}>{labels[status] || status}</span>;
    };

    return (
        <CustomerLayout>
            <Head title="Dashboard" />
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <div className="mb-8">
                    <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
                    <p className="text-gray-500 mt-1">Selamat datang kembali!</p>
                </div>

                {/* Stats */}
                <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
                    {statCards.map((stat, i) => (
                        <div key={i} className="card p-4">
                            <div className="flex items-center gap-3">
                                <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${stat.color}`}>
                                    <span className="text-lg">{stat.icon}</span>
                                </div>
                                <div>
                                    <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
                                    <p className="text-xs text-gray-500">{stat.label}</p>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>

                {/* Quick Actions */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-8">
                    <Link href={route('venues.index')} className="card-hover p-5 flex items-center gap-4 group">
                        <div className="w-12 h-12 bg-accent/10 rounded-xl flex items-center justify-center group-hover:bg-accent/20 transition-colors">
                            <span className="text-2xl">🏟️</span>
                        </div>
                        <div>
                            <h3 className="font-bold text-gray-900">Booking Lapangan</h3>
                            <p className="text-sm text-gray-500">Cari dan booking lapangan</p>
                        </div>
                    </Link>
                    <Link href={route('cart.index')} className="card-hover p-5 flex items-center gap-4 group">
                        <div className="w-12 h-12 bg-blue-50 rounded-xl flex items-center justify-center group-hover:bg-blue-100 transition-colors">
                            <span className="text-2xl">🛒</span>
                        </div>
                        <div>
                            <h3 className="font-bold text-gray-900">Keranjang Saya</h3>
                            <p className="text-sm text-gray-500">{stats.cart_items} item di keranjang</p>
                        </div>
                    </Link>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    {/* Active Bookings */}
                    <div className="card">
                        <div className="p-4 border-b border-surface-border flex items-center justify-between">
                            <h3 className="font-semibold text-gray-900">Booking Aktif</h3>
                            <Link href={route('bookings.index')} className="text-xs text-accent hover:text-accent-dark font-medium">Lihat Semua</Link>
                        </div>
                        <div className="divide-y divide-surface-border">
                            {activeBookings && activeBookings.length > 0 ? activeBookings.map(booking => (
                                <Link key={booking.id} href={route('bookings.show', booking.id)} className="block p-4 hover:bg-gray-50 transition-colors">
                                    <div className="flex items-center justify-between mb-1">
                                        <span className="font-mono text-sm font-semibold text-primary">{booking.booking_code}</span>
                                        {getStatusBadge(booking.status)}
                                    </div>
                                    <p className="text-sm text-gray-500">
                                        {booking.items?.[0]?.venue_field?.venue?.name} — {booking.items?.length} slot
                                    </p>
                                    <p className="text-sm font-semibold text-gray-900 mt-1">
                                        Rp {parseInt(booking.total_amount).toLocaleString('id-ID')}
                                    </p>
                                </Link>
                            )) : (
                                <div className="p-8 text-center">
                                    <p className="text-gray-400 text-sm">Belum ada booking aktif</p>
                                    <Link href={route('venues.index')} className="btn-accent btn-sm mt-3">Booking Sekarang</Link>
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Recent Bookings */}
                    <div className="card">
                        <div className="p-4 border-b border-surface-border flex items-center justify-between">
                            <h3 className="font-semibold text-gray-900">Riwayat Terbaru</h3>
                            <Link href={route('bookings.index')} className="text-xs text-accent hover:text-accent-dark font-medium">Lihat Semua</Link>
                        </div>
                        <div className="divide-y divide-surface-border">
                            {recentBookings && recentBookings.length > 0 ? recentBookings.map(booking => (
                                <Link key={booking.id} href={route('bookings.show', booking.id)} className="block p-4 hover:bg-gray-50 transition-colors">
                                    <div className="flex items-center justify-between mb-1">
                                        <span className="font-mono text-sm font-semibold text-primary">{booking.booking_code}</span>
                                        {getStatusBadge(booking.status)}
                                    </div>
                                    <p className="text-sm text-gray-500">
                                        {new Date(booking.created_at).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' })}
                                    </p>
                                </Link>
                            )) : (
                                <div className="p-8 text-center">
                                    <p className="text-gray-400 text-sm">Belum ada riwayat booking</p>
                                </div>
                            )}
                        </div>
                    </div>
                </div>
            </div>
        </CustomerLayout>
    );
}
