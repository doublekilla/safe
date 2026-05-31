import AdminLayout from '@/Layouts/AdminLayout';
import { Head, router } from '@inertiajs/react';
import { useState, useRef } from 'react';


export default function ReportsIndex({ revenueSummary, dailyRevenue, bookingStats, revenueBySport, paymentMethods, filters }) {
    const [startDate, setStartDate] = useState(filters.start_date);
    const [endDate, setEndDate] = useState(filters.end_date);
    const applyFilter = () => router.get(route('admin.reports.index'), { start_date: startDate, end_date: endDate }, { preserveState: true });
    const reportRef = useRef(null);

    const handlePrint = () => window.print();

    const handleDownloadExcel = () => {
        const params = new URLSearchParams({ start_date: startDate, end_date: endDate });
        window.open(`/admin/reports/download-excel?${params.toString()}`, '_blank');
    };

    const sportLabels = { badminton: '🏸 Badminton', futsal: '⚽ Futsal', basketball: '🏀 Basket', padel: '🎾 Padel', volleyball: '🏐 Voli' };
    const statusLabels = { completed: 'Selesai', cancelled: 'Dibatalkan', confirmed: 'Dikonfirmasi', pending: 'Menunggu', rescheduled: 'Dijadwal Ulang' };

    return (
        <AdminLayout title="Laporan">
            <Head title="Laporan" />

            {/* Header with actions */}
            <div className="flex items-center justify-between mb-6">
                <h1 className="text-xl font-bold text-gray-900">Laporan & Analisis</h1>
                <div className="flex gap-2">
                    <button onClick={handleDownloadExcel} className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-white bg-emerald-600 rounded-lg hover:bg-emerald-700 transition-colors shadow-sm">
                        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" /></svg>
                        Download Excel
                    </button>
                    <button onClick={handlePrint} className="inline-flex items-center gap-2 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors shadow-sm">
                        <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" /></svg>
                        Print
                    </button>
                </div>
            </div>

            {/* Date Filter */}
            <div className="card p-4 mb-6 flex flex-wrap gap-3 items-end print:hidden">
                <div><label className="input-label">Dari</label><input type="date" value={startDate} onChange={e => setStartDate(e.target.value)} className="input" /></div>
                <div><label className="input-label">Sampai</label><input type="date" value={endDate} onChange={e => setEndDate(e.target.value)} className="input" /></div>
                <button onClick={applyFilter} className="btn-accent">Terapkan</button>
            </div>

            <div ref={reportRef}>
                {/* Summary */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-6">
                    <div className="card p-6 bg-gradient-primary text-white">
                        <p className="text-sm text-gray-400">Total Pendapatan</p>
                        <p className="text-3xl font-black mt-1">Rp {parseInt(revenueSummary.total).toLocaleString('id-ID')}</p>
                        <p className="text-xs text-gray-400 mt-1">{revenueSummary.count} transaksi</p>
                    </div>
                    <div className="card p-6">
                        <p className="text-sm text-gray-500">Status Booking</p>
                        <div className="space-y-2 mt-3">
                            {bookingStats?.map(s => (
                                <div key={s.status} className="flex justify-between text-sm">
                                    <span className={`badge ${s.status === 'completed' ? 'badge-success' : s.status === 'cancelled' ? 'badge-danger' : s.status === 'confirmed' ? 'badge-info' : 'badge-warning'}`}>{statusLabels[s.status] || s.status}</span>
                                    <span className="font-semibold">{s.count}</span>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>

                {/* Revenue Chart */}
                <div className="card p-6 mb-6">
                    <h3 className="font-semibold text-gray-900 mb-5">Pendapatan Harian</h3>
                    {(() => {
                        const chartData = dailyRevenue || [];
                        if (chartData.length === 0) {
                            return <p className="text-center text-gray-400 py-12">Belum ada data pendapatan</p>;
                        }

                        const values = chartData.map(d => Number(d.total) || 0);
                        const maxVal = Math.max(...values, 1);
                        const barAreaHeight = 220;

                        const formatCurrency = (num) => {
                            if (num >= 1000000) return `${(num / 1000000).toFixed(1)}jt`;
                            if (num >= 1000) return `${(num / 1000).toFixed(0)}k`;
                            return num.toLocaleString('id-ID');
                        };

                        const formatFullCurrency = (num) => `Rp ${Number(num).toLocaleString('id-ID')}`;

                        const formatDateLabel = (dateStr) => {
                            try {
                                const [year, month, day] = dateStr.split('-');
                                const d = new Date(year, month - 1, day);
                                return d.toLocaleDateString('id-ID', { day: 'numeric', month: 'short' });
                            } catch { return dateStr; }
                        };

                        const tickCount = 4;
                        const yTicks = Array.from({ length: tickCount + 1 }, (_, i) => Math.round((maxVal / tickCount) * i));

                        return (
                            <div className="flex gap-1">
                                {/* Y-axis labels */}
                                <div className="flex flex-col justify-between pr-3 py-0" style={{ height: `${barAreaHeight}px` }}>
                                    {[...yTicks].reverse().map((tick, i) => (
                                        <span key={i} className="text-xs text-gray-500 text-right whitespace-nowrap leading-none font-medium">{formatCurrency(tick)}</span>
                                    ))}
                                </div>
                                {/* Chart area */}
                                <div className="flex-1 relative" style={{ height: `${barAreaHeight + 36}px` }}>
                                    {/* Gridlines */}
                                    {yTicks.map((tick, i) => (
                                        <div key={i} className="absolute left-0 right-0 border-t border-dashed border-gray-200" style={{ bottom: `${36 + (tick / maxVal) * barAreaHeight}px` }} />
                                    ))}
                                    {/* Bars */}
                                    <div className="absolute inset-0 flex items-end gap-[6px] pb-9">
                                        {chartData.map((d, i) => {
                                            const revenue = Number(d.total) || 0;
                                            const ratio = revenue / maxVal;
                                            const barHeight = revenue > 0 ? Math.max(ratio * barAreaHeight, 14) : 4;

                                            return (
                                                <div key={i} className="flex-1 flex flex-col items-center justify-end h-full group relative" style={{ minWidth: '32px' }}>
                                                    {/* Tooltip */}
                                                    <div className="absolute bottom-full mb-2 opacity-0 group-hover:opacity-100 transition-opacity duration-200 pointer-events-none z-10">
                                                        <div className="bg-gray-800 text-white text-xs px-3 py-2 rounded-lg shadow-lg whitespace-nowrap text-center">
                                                            <p className="font-bold">{formatFullCurrency(revenue)}</p>
                                                            <p className="text-gray-300 text-[11px]">{d.date}</p>
                                                        </div>
                                                        <div className="w-2 h-2 bg-gray-800 rotate-45 mx-auto -mt-1" />
                                                    </div>
                                                    {/* Value on hover */}
                                                    <span className="text-[11px] text-gray-600 font-bold mb-1 opacity-0 group-hover:opacity-100 transition-opacity">
                                                        {formatCurrency(revenue)}
                                                    </span>
                                                    {/* Bar */}
                                                    <div
                                                        className="w-full rounded-t-md relative overflow-hidden transition-all duration-300 cursor-pointer group-hover:shadow-md"
                                                        style={{ height: `${barHeight}px`, maxWidth: '56px' }}
                                                    >
                                                        <div className={`absolute inset-0 rounded-t-md ${revenue > 0 ? 'bg-gradient-to-t from-[#1a3a5c] to-[#c9a84c]' : 'bg-gray-200'}`} />
                                                        <div className="absolute inset-0 opacity-0 group-hover:opacity-20 bg-white transition-opacity" />
                                                    </div>
                                                    {/* Date label */}
                                                    <span className="text-[11px] text-gray-500 mt-2 whitespace-nowrap font-medium">{formatDateLabel(d.date)}</span>
                                                </div>
                                            );
                                        })}
                                    </div>
                                </div>
                            </div>
                        );
                    })()}
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                    {/* By Sport */}
                    <div className="card p-6">
                        <h3 className="font-semibold text-gray-900 mb-4">Pendapatan per Olahraga</h3>
                        {revenueBySport?.map(s => (
                            <div key={s.sport_type} className="flex justify-between items-center p-3 bg-gray-50 rounded-lg mb-2">
                                <span className="text-sm font-medium">{sportLabels[s.sport_type] || s.sport_type}</span>
                                <span className="font-bold text-primary">Rp {parseInt(s.total).toLocaleString('id-ID')}</span>
                            </div>
                        ))}
                    </div>
                    {/* By Payment Method */}
                    <div className="card p-6">
                        <h3 className="font-semibold text-gray-900 mb-4">Metode Pembayaran</h3>
                        {paymentMethods?.map(m => (
                            <div key={m.method} className="flex justify-between items-center p-3 bg-gray-50 rounded-lg mb-2">
                                <span className="text-sm font-medium capitalize">{m.method?.replace('_', ' ')}</span>
                                <div className="text-right">
                                    <p className="font-bold text-sm">Rp {parseInt(m.total).toLocaleString('id-ID')}</p>
                                    <p className="text-xs text-gray-400">{m.count} transaksi</p>
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </AdminLayout>
    );
}
