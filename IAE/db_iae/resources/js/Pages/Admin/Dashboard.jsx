import AdminLayout from '@/Layouts/AdminLayout';
import { Head, Link } from '@inertiajs/react';


export default function Dashboard({ stats, popularFields, recentBookings, revenueChart, bookingBySport }) {
    const statCards = [
        { label: 'Booking Hari Ini', value: stats.bookings_today, icon: '📋', color: 'bg-blue-50 text-blue-600' },
        { label: 'Booking Aktif', value: stats.active_bookings, icon: '🎯', color: 'bg-emerald-50 text-emerald-600' },
        { label: 'Pendapatan Hari Ini', value: `Rp ${parseInt(stats.revenue_today).toLocaleString('id-ID')}`, icon: '💰', color: 'bg-amber-50 text-amber-600', small: true },
        { label: 'Pendapatan Bulan Ini', value: `Rp ${parseInt(stats.revenue_month).toLocaleString('id-ID')}`, icon: '📊', color: 'bg-purple-50 text-purple-600', small: true },
        { label: 'Pembayaran Pending', value: stats.pending_payments, icon: '⏳', color: 'bg-red-50 text-red-600' },
        { label: 'Slot Tersedia', value: stats.available_slots, icon: '🟢', color: 'bg-teal-50 text-teal-600' },
    ];

    const statusBadge = (status) => {
        const map = { pending: 'badge-warning', confirmed: 'badge-info', completed: 'badge-success', cancelled: 'badge-danger' };
        return <span className={map[status] || 'badge-neutral'}>{status}</span>;
    };


    return (
        <AdminLayout title="Dashboard">
            <Head title="Admin Dashboard" />
            {/* Stats Grid */}
            <div className="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4 mb-6">
                {statCards.map((stat, i) => (
                    <div key={i} className="card p-4">
                        <div className="flex items-center gap-3">
                            <div className={`w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 ${stat.color}`}>
                                <span className="text-lg">{stat.icon}</span>
                            </div>
                            <div className="min-w-0">
                                <p className={`font-bold text-gray-900 truncate ${stat.small ? 'text-sm' : 'text-xl'}`}>{stat.value}</p>
                                <p className="text-[10px] text-gray-500 truncate">{stat.label}</p>
                            </div>
                        </div>
                    </div>
                ))}
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
                {/* Revenue Chart */}
                <div className="lg:col-span-2 card p-6">
                    <h3 className="font-semibold text-gray-900 mb-4">📈 Pendapatan 7 Hari Terakhir</h3>
                    {(() => {
                        const chartData = revenueChart || [];
                        const values = chartData.map(d => Number(d.revenue) || 0);
                        const maxVal = Math.max(...values, 1);
                        const barAreaHeight = 160;

                        const formatCurrency = (num) => {
                            if (num >= 1000000) return `${(num / 1000000).toFixed(1)}jt`;
                            if (num >= 1000) return `${(num / 1000).toFixed(0)}k`;
                            if (num > 0) return num.toLocaleString('id-ID');
                            return '0';
                        };

                        const formatFullCurrency = (num) => `Rp ${Number(num).toLocaleString('id-ID')}`;

                        const formatDateLabel = (dateStr) => {
                            try {
                                const [year, month, day] = dateStr.split('-');
                                const d = new Date(year, month - 1, day);
                                return d.toLocaleDateString('id-ID', { weekday: 'short', day: 'numeric' });
                            } catch { return dateStr; }
                        };

                        const tickCount = 4;
                        const yTicks = Array.from({ length: tickCount + 1 }, (_, i) => Math.round((maxVal / tickCount) * i));

                        if (chartData.length === 0) {
                            return <p className="text-center text-gray-400 py-8">Belum ada data</p>;
                        }

                        return (
                            <div className="flex gap-0">
                                <div className="flex flex-col justify-between pr-2" style={{ height: `${barAreaHeight}px` }}>
                                    {[...yTicks].reverse().map((tick, i) => (
                                        <span key={i} className="text-[10px] text-gray-400 text-right whitespace-nowrap leading-none">{formatCurrency(tick)}</span>
                                    ))}
                                </div>
                                <div className="flex-1 relative" style={{ height: `${barAreaHeight + 32}px` }}>
                                    {yTicks.map((tick, i) => (
                                        <div key={i} className="absolute left-0 right-0 border-t border-gray-100" style={{ bottom: `${32 + (tick / maxVal) * barAreaHeight}px` }} />
                                    ))}
                                    <div className="absolute inset-0 flex items-end gap-2 pb-8">
                                        {chartData.map((d, i) => {
                                            const revenue = Number(d.revenue) || 0;
                                            const ratio = revenue / maxVal;
                                            const barHeight = revenue > 0 ? Math.max(ratio * barAreaHeight, 12) : 3;

                                            return (
                                                <div key={i} className="flex-1 flex flex-col items-center justify-end h-full group relative">
                                                    <div className="absolute bottom-full mb-2 opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none z-10">
                                                        <div className="bg-gray-800 text-white text-[10px] px-2.5 py-1.5 rounded-lg shadow-lg whitespace-nowrap text-center">
                                                            <p className="font-bold">{formatFullCurrency(revenue)}</p>
                                                            <p className="text-gray-300">{d.date}</p>
                                                        </div>
                                                        <div className="w-2 h-2 bg-gray-800 rotate-45 mx-auto -mt-1" />
                                                    </div>
                                                    <span className="text-[9px] text-gray-500 font-semibold mb-1 opacity-0 group-hover:opacity-100 transition-opacity">
                                                        {formatCurrency(revenue)}
                                                    </span>
                                                    <div
                                                        className="w-full rounded-t-md relative overflow-hidden transition-all duration-300 cursor-pointer group-hover:opacity-80"
                                                        style={{ height: `${barHeight}px`, maxWidth: '52px' }}
                                                    >
                                                        <div className={`absolute inset-0 rounded-t-md ${revenue > 0 ? 'bg-gradient-to-t from-[#1a3a5c] to-[#c9a84c]' : 'bg-gray-200'}`} />
                                                    </div>
                                                    <span className="text-[9px] text-gray-400 mt-1.5 whitespace-nowrap font-medium">{formatDateLabel(d.date)}</span>
                                                </div>
                                            );
                                        })}
                                    </div>
                                </div>
                            </div>
                        );
                    })()}
                </div>

                {/* Popular Fields */}
                <div className="card p-6">
                    <h3 className="font-semibold text-gray-900 mb-4">🔥 Lapangan Populer</h3>
                    <div className="space-y-3">
                        {popularFields?.length > 0 ? popularFields.map((f, i) => (
                            <div key={i} className="flex items-center gap-3">
                                <div className="w-8 h-8 bg-accent/10 rounded-lg flex items-center justify-center text-sm font-bold text-accent">{i + 1}</div>
                                <div className="flex-1 min-w-0">
                                    <p className="text-sm font-medium text-gray-900 truncate">{f.field_name}</p>
                                    <p className="text-xs text-gray-500">{f.venue_name} • {(() => { const m = {badminton:'🏸',futsal:'⚽',basketball:'🏀',padel:'🎾',volleyball:'🏐'}; return m[f.sport_type] || '🏟️'; })()}</p>
                                </div>
                                <span className="badge-accent">{f.booking_count}x</span>
                            </div>
                        )) : (
                            <p className="text-sm text-gray-400 text-center py-4">Belum ada data</p>
                        )}
                    </div>
                </div>
            </div>

            {/* Recent Bookings */}
            <div className="card">
                <div className="p-4 border-b border-surface-border flex items-center justify-between">
                    <h3 className="font-semibold text-gray-900">📋 Booking Terbaru</h3>
                    <Link href={route('admin.bookings.index')} className="text-xs text-accent font-medium">Lihat Semua →</Link>
                </div>
                <div className="overflow-x-auto">
                    <table className="table">
                        <thead><tr><th>Kode</th><th>Customer</th><th>Lapangan</th><th>Status</th><th>Total</th><th>Tanggal</th></tr></thead>
                        <tbody>
                            {recentBookings?.length > 0 ? recentBookings.map(booking => (
                                <tr key={booking.id}>
                                    <td><Link href={route('admin.bookings.show', booking.id)} className="font-mono text-sm font-bold text-accent hover:text-accent-dark">{booking.booking_code}</Link></td>
                                    <td><p className="text-sm font-medium">{booking.user?.name}</p><p className="text-xs text-gray-400">{booking.user?.email}</p></td>
                                    <td className="text-sm">{booking.items?.[0]?.venue_field?.venue?.name}</td>
                                    <td>{statusBadge(booking.status)}</td>
                                    <td className="font-semibold text-sm">Rp {parseInt(booking.total_amount).toLocaleString('id-ID')}</td>
                                    <td className="text-xs text-gray-500">{new Date(booking.created_at).toLocaleDateString('id-ID')}</td>
                                </tr>
                            )) : (
                                <tr><td colSpan="6" className="text-center py-8 text-gray-400">Belum ada booking</td></tr>
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        </AdminLayout>
    );
}
