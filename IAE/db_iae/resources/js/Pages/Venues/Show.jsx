import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head, router, usePage } from '@inertiajs/react';
import { useState, useEffect } from 'react';
import axios from 'axios';
import { getSportEmoji, getSportLabel, getSportBadge } from '@/utils/sportTypes';


function ScheduleGrid({ fields, venuePrice, onAddToCart, refreshKey }) {
    const getLocalDate = (d) => {
        const y = d.getFullYear();
        const m = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        return `${y}-${m}-${day}`;
    };

    const [selectedField, setSelectedField] = useState(fields?.[0]?.id || null);
    const [selectedDate, setSelectedDate] = useState(getLocalDate(new Date()));
    const [schedules, setSchedules] = useState([]);
    const [loading, setLoading] = useState(false);

    const dates = [];
    for (let i = 0; i < 14; i++) {
        const d = new Date(); d.setDate(d.getDate() + i);
        dates.push({ date: getLocalDate(d), label: d.toLocaleDateString('id-ID', { weekday: 'short', day: 'numeric', month: 'short' }), isToday: i === 0 });
    }

    useEffect(() => {
        if (selectedField && selectedDate) fetchSchedules();
    }, [selectedField, selectedDate, refreshKey]);

    const fetchSchedules = async () => {
        setLoading(true);
        try {
            const res = await axios.get(route('schedules.available'), {
                params: { venue_field_id: selectedField, date: selectedDate }
            });
            setSchedules(res.data.schedules || []);
        } catch (e) { setSchedules([]); }
        setLoading(false);
    };

    const getStatusColor = (status) => {
        const map = {
            available: 'bg-emerald-50 border-emerald-200 text-emerald-700 hover:bg-emerald-100 cursor-pointer',
            booked: 'bg-red-50 border-red-200 text-red-400 cursor-not-allowed',
            pending: 'bg-amber-50 border-amber-200 text-amber-600 cursor-not-allowed',
            blocked: 'bg-gray-100 border-gray-200 text-gray-400 cursor-not-allowed',
            maintenance: 'bg-gray-100 border-gray-200 text-gray-400 cursor-not-allowed',
            expired: 'bg-gray-50 border-gray-200 text-gray-300 cursor-not-allowed line-through',
        };
        return map[status] || 'bg-gray-100 border-gray-200 text-gray-400';
    };

    return (
        <div>
            <h3 className="font-bold text-gray-900 text-lg mb-4">📅 Jadwal & Booking</h3>
            {/* Field Selection */}
            {fields.length > 1 && (
                <div className="flex flex-wrap gap-2 mb-4">
                    {fields.map(field => (
                        <button key={field.id} onClick={() => setSelectedField(field.id)}
                            className={`px-4 py-2 text-sm rounded-lg border-2 transition-all font-medium ${selectedField === field.id ? 'border-accent bg-accent/10 text-accent-dark' : 'border-gray-200 text-gray-600 hover:border-gray-300'}`}>
                            {field.name}
                        </button>
                    ))}
                </div>
            )}
            {/* Date Selection */}
            <div className="flex gap-2 overflow-x-auto pb-2 mb-4 scrollbar-thin">
                {dates.map(d => (
                    <button key={d.date} onClick={() => setSelectedDate(d.date)}
                        className={`flex-shrink-0 px-3 py-2 rounded-lg text-xs font-medium border-2 transition-all ${selectedDate === d.date ? 'border-primary bg-primary text-white' : 'border-gray-200 text-gray-600 hover:border-gray-300'}`}>
                        {d.isToday ? 'Hari Ini' : d.label}
                    </button>
                ))}
            </div>
            {/* Schedule Grid */}
            {loading ? (
                <div className="grid grid-cols-3 sm:grid-cols-4 lg:grid-cols-6 gap-2">
                    {Array.from({ length: 12 }).map((_, i) => <div key={i} className="skeleton h-16 rounded-lg" />)}
                </div>
            ) : schedules.length > 0 ? (
                <div className="grid grid-cols-3 sm:grid-cols-4 lg:grid-cols-6 gap-2">
                    {schedules.map(slot => {
                        const isBookable = slot.status === 'available';
                        return (
                            <button key={slot.id} disabled={!isBookable}
                                onClick={() => isBookable && onAddToCart(slot.id)}
                                className={`p-3 rounded-lg border-2 text-center transition-all ${getStatusColor(slot.status)}`}>
                                <div className={`text-sm font-semibold ${slot.status === 'expired' ? 'line-through decoration-gray-300' : ''}`}>
                                    {slot.start_time?.substring(0, 5)} - {slot.end_time?.substring(0, 5)}
                                </div>
                                <div className="text-[10px] mt-0.5">
                                    {slot.status === 'available' ? `Rp ${parseInt(slot.price).toLocaleString('id-ID')}` :
                                     slot.status === 'booked' ? 'Terisi' :
                                     slot.status === 'pending' ? 'Pending' :
                                     slot.status === 'expired' ? '⏰ Lewat' : 'Tutup'}
                                </div>
                            </button>
                        );
                    })}
                </div>
            ) : (
                <div className="text-center py-8 text-gray-400">
                    <p>Tidak ada jadwal untuk tanggal ini</p>
                </div>
            )}
            {/* Legend */}
            <div className="flex flex-wrap gap-4 mt-4 pt-4 border-t border-surface-border">
                <div className="flex items-center gap-2 text-xs text-gray-500"><div className="w-3 h-3 rounded bg-emerald-200 border border-emerald-300" /> Tersedia</div>
                <div className="flex items-center gap-2 text-xs text-gray-500"><div className="w-3 h-3 rounded bg-red-200 border border-red-300" /> Terisi</div>
                <div className="flex items-center gap-2 text-xs text-gray-500"><div className="w-3 h-3 rounded bg-amber-200 border border-amber-300" /> Pending</div>
                <div className="flex items-center gap-2 text-xs text-gray-500"><div className="w-3 h-3 rounded bg-gray-200 border border-gray-300" /> Tutup</div>
                <div className="flex items-center gap-2 text-xs text-gray-500"><div className="w-3 h-3 rounded bg-gray-100 border border-gray-200" /> Lewat</div>
            </div>
        </div>
    );
}

export default function VenueShow({ venue, reviews, averageRating, reviewCount, ratingDistribution }) {
    const { auth } = usePage().props;
    const [addingToCart, setAddingToCart] = useState(false);
    const [refreshKey, setRefreshKey] = useState(0);
    const [selectedPhoto, setSelectedPhoto] = useState(0);
    const [showLightbox, setShowLightbox] = useState(false);

    const handleAddToCart = (scheduleId) => {
        if (!auth?.user) { router.visit(route('login')); return; }
        setAddingToCart(true);
        router.post(route('cart.add'), { schedule_id: scheduleId }, {
            preserveScroll: true,
            onFinish: () => {
                setAddingToCart(false);
                setRefreshKey(prev => prev + 1); // Trigger schedule grid refresh
            },
        });
    };

    return (
        <CustomerLayout>
            <Head title={venue.name} />
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    {/* Main Content */}
                    <div className="lg:col-span-2 space-y-6">
                        {/* Gallery */}
                        <div className="card overflow-hidden">
                            {/* Main Image */}
                            <div className="aspect-video bg-gradient-to-br from-gray-200 to-gray-100 relative group">
                                {venue.photos && venue.photos.length > 0 ? (
                                    <img
                                        src={`/storage/${venue.photos[selectedPhoto]}`}
                                        alt={venue.name}
                                        className="w-full h-full object-cover transition-opacity duration-300 cursor-pointer"
                                        onClick={() => setShowLightbox(true)}
                                    />
                                ) : (
                                    <div className="w-full h-full flex items-center justify-center">
                                        <span className="text-7xl">{getSportEmoji(venue.sport_type)}</span>
                                    </div>
                                )}
                                {/* Badges */}
                                <div className="absolute top-4 left-4 flex gap-2">
                                    <span className={`badge ${getSportBadge(venue.sport_type)} text-sm`}>
                                        {getSportEmoji(venue.sport_type)} {getSportLabel(venue.sport_type)}
                                    </span>
                                </div>
                                {averageRating > 0 && (
                                    <div className="absolute top-4 right-4 bg-black/60 backdrop-blur-sm text-white px-3 py-1.5 rounded-lg flex items-center gap-2">
                                        <span className="text-amber-400">★</span>
                                        <span className="font-semibold">{averageRating}</span>
                                        <span className="text-xs text-gray-300">({reviewCount} ulasan)</span>
                                    </div>
                                )}
                                {/* Fullscreen hint */}
                                {venue.photos && venue.photos.length > 0 && (
                                    <div className="absolute bottom-4 right-4 bg-black/50 backdrop-blur-sm text-white px-3 py-1.5 rounded-lg text-xs opacity-0 group-hover:opacity-100 transition-opacity flex items-center gap-1.5 cursor-pointer" onClick={() => setShowLightbox(true)}>
                                        <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0zM10 7v3m0 0v3m0-3h3m-3 0H7" /></svg>
                                        Klik untuk perbesar
                                    </div>
                                )}
                                {/* Prev/Next Arrows on main image */}
                                {venue.photos && venue.photos.length > 1 && (
                                    <>
                                        <button
                                            onClick={(e) => { e.stopPropagation(); setSelectedPhoto(prev => prev === 0 ? venue.photos.length - 1 : prev - 1); }}
                                            className="absolute left-3 top-1/2 -translate-y-1/2 w-9 h-9 bg-black/40 backdrop-blur-sm hover:bg-black/60 text-white rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
                                        >
                                            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" /></svg>
                                        </button>
                                        <button
                                            onClick={(e) => { e.stopPropagation(); setSelectedPhoto(prev => prev === venue.photos.length - 1 ? 0 : prev + 1); }}
                                            className="absolute right-3 top-1/2 -translate-y-1/2 w-9 h-9 bg-black/40 backdrop-blur-sm hover:bg-black/60 text-white rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity"
                                        >
                                            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" /></svg>
                                        </button>
                                    </>
                                )}
                                {/* Photo counter */}
                                {venue.photos && venue.photos.length > 1 && (
                                    <div className="absolute bottom-4 left-4 bg-black/50 backdrop-blur-sm text-white px-2.5 py-1 rounded-lg text-xs font-medium">
                                        {selectedPhoto + 1} / {venue.photos.length}
                                    </div>
                                )}
                            </div>
                            {/* Thumbnails */}
                            {venue.photos && venue.photos.length > 1 && (
                                <div className="flex gap-2 p-3 overflow-x-auto scrollbar-thin bg-gray-50/50">
                                    {venue.photos.map((photo, i) => (
                                        <button
                                            key={i}
                                            onClick={() => setSelectedPhoto(i)}
                                            className={`flex-shrink-0 w-20 h-20 rounded-lg overflow-hidden border-2 transition-all duration-200 ${
                                                selectedPhoto === i
                                                    ? 'border-accent ring-2 ring-accent/30 scale-105'
                                                    : 'border-transparent opacity-70 hover:opacity-100 hover:border-gray-300'
                                            }`}
                                        >
                                            <img src={`/storage/${photo}`} alt="" className="w-full h-full object-cover" />
                                        </button>
                                    ))}
                                </div>
                            )}
                        </div>

                        {/* Lightbox Modal */}
                        {showLightbox && venue.photos && venue.photos.length > 0 && (
                            <div
                                className="fixed inset-0 z-50 bg-black/90 flex items-center justify-center"
                                onClick={() => setShowLightbox(false)}
                                onKeyDown={(e) => {
                                    if (e.key === 'Escape') setShowLightbox(false);
                                    if (e.key === 'ArrowLeft') setSelectedPhoto(prev => prev === 0 ? venue.photos.length - 1 : prev - 1);
                                    if (e.key === 'ArrowRight') setSelectedPhoto(prev => prev === venue.photos.length - 1 ? 0 : prev + 1);
                                }}
                                tabIndex={0}
                                ref={el => el && el.focus()}
                            >
                                {/* Close Button */}
                                <button
                                    onClick={() => setShowLightbox(false)}
                                    className="absolute top-4 right-4 text-white/80 hover:text-white z-10 bg-white/10 hover:bg-white/20 rounded-full p-2 transition-colors"
                                >
                                    <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" /></svg>
                                </button>

                                {/* Counter */}
                                <div className="absolute top-4 left-4 text-white/80 text-sm font-medium bg-white/10 px-3 py-1.5 rounded-lg">
                                    {selectedPhoto + 1} / {venue.photos.length}
                                </div>

                                {/* Main Image */}
                                <img
                                    src={`/storage/${venue.photos[selectedPhoto]}`}
                                    alt={venue.name}
                                    className="max-h-[85vh] max-w-[90vw] object-contain rounded-lg"
                                    onClick={(e) => e.stopPropagation()}
                                />

                                {/* Prev/Next */}
                                {venue.photos.length > 1 && (
                                    <>
                                        <button
                                            onClick={(e) => { e.stopPropagation(); setSelectedPhoto(prev => prev === 0 ? venue.photos.length - 1 : prev - 1); }}
                                            className="absolute left-4 top-1/2 -translate-y-1/2 w-12 h-12 bg-white/10 hover:bg-white/20 text-white rounded-full flex items-center justify-center transition-colors"
                                        >
                                            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" /></svg>
                                        </button>
                                        <button
                                            onClick={(e) => { e.stopPropagation(); setSelectedPhoto(prev => prev === venue.photos.length - 1 ? 0 : prev + 1); }}
                                            className="absolute right-4 top-1/2 -translate-y-1/2 w-12 h-12 bg-white/10 hover:bg-white/20 text-white rounded-full flex items-center justify-center transition-colors"
                                        >
                                            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" /></svg>
                                        </button>
                                    </>
                                )}

                                {/* Bottom Thumbnails in Lightbox */}
                                {venue.photos.length > 1 && (
                                    <div className="absolute bottom-4 left-1/2 -translate-x-1/2 flex gap-2 bg-black/50 backdrop-blur-sm p-2 rounded-xl max-w-[80vw] overflow-x-auto">
                                        {venue.photos.map((photo, i) => (
                                            <button
                                                key={i}
                                                onClick={(e) => { e.stopPropagation(); setSelectedPhoto(i); }}
                                                className={`flex-shrink-0 w-14 h-14 rounded-lg overflow-hidden border-2 transition-all ${
                                                    selectedPhoto === i
                                                        ? 'border-white ring-1 ring-white/30'
                                                        : 'border-transparent opacity-50 hover:opacity-80'
                                                }`}
                                            >
                                                <img src={`/storage/${photo}`} alt="" className="w-full h-full object-cover" />
                                            </button>
                                        ))}
                                    </div>
                                )}
                            </div>
                        )}

                        {/* Description */}
                        <div className="card p-6">
                            <h1 className="text-2xl font-bold text-gray-900 mb-2">{venue.name}</h1>
                            <p className="text-gray-500 flex items-center gap-1 mb-4">📍 {venue.location}</p>
                            <p className="text-gray-600 leading-relaxed">{venue.description}</p>
                        </div>

                        {/* Facilities */}
                        {venue.facilities && venue.facilities.length > 0 && (
                            <div className="card p-6">
                                <h3 className="font-bold text-gray-900 text-lg mb-4">🏆 Fasilitas</h3>
                                <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
                                    {venue.facilities.map((f, i) => (
                                        <div key={i} className="flex items-center gap-2 text-sm text-gray-700 bg-gray-50 px-3 py-2 rounded-lg">
                                            <span className="text-accent">✓</span> {f}
                                        </div>
                                    ))}
                                </div>
                            </div>
                        )}

                        {/* Schedule Grid */}
                        <div className="card p-6">
                            <ScheduleGrid fields={venue.fields || []} venuePrice={venue.price_per_hour} onAddToCart={handleAddToCart} refreshKey={refreshKey} />
                        </div>

                        {/* Reviews */}
                        <div className="card p-6">
                            <h3 className="font-bold text-gray-900 text-lg mb-4">⭐ Ulasan ({reviewCount})</h3>
                            {averageRating > 0 && (
                                <div className="flex items-center gap-6 mb-6 p-4 bg-gray-50 rounded-card">
                                    <div className="text-center">
                                        <div className="text-4xl font-black text-primary">{averageRating}</div>
                                        <div className="flex gap-0.5 mt-1">
                                            {[1,2,3,4,5].map(s => (
                                                <span key={s} className={`text-sm ${s <= Math.round(averageRating) ? 'text-amber-400' : 'text-gray-300'}`}>★</span>
                                            ))}
                                        </div>
                                        <p className="text-xs text-gray-500 mt-1">{reviewCount} ulasan</p>
                                    </div>
                                    <div className="flex-1 space-y-1.5">
                                        {[5,4,3,2,1].map(star => (
                                            <div key={star} className="flex items-center gap-2">
                                                <span className="text-xs text-gray-500 w-3">{star}</span>
                                                <span className="text-amber-400 text-xs">★</span>
                                                <div className="flex-1 bg-gray-200 rounded-full h-2">
                                                    <div className="bg-amber-400 rounded-full h-2 transition-all" style={{ width: `${reviewCount > 0 ? (ratingDistribution[star] / reviewCount * 100) : 0}%` }} />
                                                </div>
                                                <span className="text-xs text-gray-400 w-6">{ratingDistribution[star]}</span>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            )}
                            <div className="space-y-4">
                                {reviews?.data?.length > 0 ? reviews.data.map(review => (
                                    <div key={review.id} className="border-b border-surface-border pb-4 last:border-0">
                                        <div className="flex items-center gap-3 mb-2">
                                            <div className="w-8 h-8 bg-primary rounded-full flex items-center justify-center">
                                                <span className="text-accent text-xs font-bold">{review.user?.name?.charAt(0)}</span>
                                            </div>
                                            <div>
                                                <p className="text-sm font-semibold text-gray-900">{review.user?.name}</p>
                                                <div className="flex items-center gap-1">
                                                    {[1,2,3,4,5].map(s => (
                                                        <span key={s} className={`text-xs ${s <= review.rating ? 'text-amber-400' : 'text-gray-300'}`}>★</span>
                                                    ))}
                                                    <span className="text-xs text-gray-400 ml-1">{new Date(review.created_at).toLocaleDateString('id-ID')}</span>
                                                </div>
                                            </div>
                                        </div>
                                        {review.comment && <p className="text-sm text-gray-600 ml-11">{review.comment}</p>}
                                        {review.admin_reply && (
                                            <div className="ml-11 mt-2 p-3 bg-accent/5 rounded-lg border-l-2 border-accent">
                                                <p className="text-xs font-semibold text-accent-dark mb-0.5">Balasan Admin:</p>
                                                <p className="text-xs text-gray-600">{review.admin_reply}</p>
                                            </div>
                                        )}
                                    </div>
                                )) : (
                                    <p className="text-center text-gray-400 py-4">Belum ada ulasan</p>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* Sidebar - Pricing & Info */}
                    <div className="space-y-4">
                        <div className="card p-6 sticky top-20">
                            <div className="mb-4">
                                <div className="flex items-baseline gap-1">
                                    <span className="text-3xl font-black text-primary">Rp {parseInt(venue.price_per_hour).toLocaleString('id-ID')}</span>
                                    <span className="text-gray-400">/jam</span>
                                </div>
                                <p className="text-xs text-gray-500 mt-1">*Harga dapat berbeda pada jam sibuk & weekend</p>
                            </div>
                            <div className="space-y-3 mb-6 text-sm">
                                <div className="flex items-center justify-between">
                                    <span className="text-gray-500">Jenis</span>
                                    <span className="font-medium text-gray-900">{venue.sport_type === 'badminton' ? '🏸 Badminton' : '⚽ Futsal'}</span>
                                </div>
                                <div className="flex items-center justify-between">
                                    <span className="text-gray-500">Lapangan</span>
                                    <span className="font-medium text-gray-900">{venue.fields?.length || 0} unit</span>
                                </div>
                                <div className="flex items-center justify-between">
                                    <span className="text-gray-500">Rating</span>
                                    <span className="font-medium text-gray-900">⭐ {averageRating} ({reviewCount})</span>
                                </div>
                                <div className="flex items-center justify-between">
                                    <span className="text-gray-500">Status</span>
                                    <span className="badge-success">Buka</span>
                                </div>
                            </div>
                            <p className="text-xs text-gray-500 text-center">Pilih jadwal di sebelah kiri untuk booking</p>
                        </div>

                        {/* Operating Hours */}
                        {venue.operating_hours && (
                            <div className="card p-6">
                                <h3 className="font-bold text-gray-900 mb-3">⏰ Jam Operasional</h3>
                                <div className="space-y-2 text-sm">
                                    {Object.entries(venue.operating_hours).map(([day, hours]) => {
                                        const dayNames = { monday: 'Senin', tuesday: 'Selasa', wednesday: 'Rabu', thursday: 'Kamis', friday: 'Jumat', saturday: 'Sabtu', sunday: 'Minggu' };
                                        return (
                                            <div key={day} className="flex justify-between">
                                                <span className="text-gray-500">{dayNames[day]}</span>
                                                <span className="font-medium text-gray-900">{hours[0]} - {hours[1]}</span>
                                            </div>
                                        );
                                    })}
                                </div>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </CustomerLayout>
    );
}
