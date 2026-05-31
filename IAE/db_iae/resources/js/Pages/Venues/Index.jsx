import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head, Link, router } from '@inertiajs/react';
import { useState } from 'react';
import { getSportEmoji, getSportLabel, getSportBadge } from '@/utils/sportTypes';


export default function VenuesIndex({ venues, filters: rawFilters }) {
    // Safely normalize props — PHP may send [] instead of {} when empty
    const filters = rawFilters && typeof rawFilters === 'object' && !Array.isArray(rawFilters) ? rawFilters : {};

    const [search, setSearch] = useState(filters.search || '');
    const [sportType, setSportType] = useState(filters.sport_type || '');
    const [sortBy, setSortBy] = useState(filters.sort ? `${filters.sort}_${filters.direction || 'asc'}` : 'name_asc');

    const applyFilters = () => {
        const params = {};
        if (search) params.search = search;
        if (sportType) params.sport_type = sportType;
        if (sortBy !== 'name_asc') {
            const lastUnderscore = sortBy.lastIndexOf('_');
            params.sort = sortBy.substring(0, lastUnderscore);
            params.direction = sortBy.substring(lastUnderscore + 1);
        }
        router.get(route('venues.index'), params, { preserveState: true });
    };

    const clearFilters = () => {
        setSearch(''); setSportType(''); setSortBy('name_asc');
        router.get(route('venues.index'));
    };

    const venueData = venues?.data || [];
    const venueLinks = venues?.links || [];

    return (
        <CustomerLayout>
            <Head title="Daftar Lapangan" />
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                {/* Header */}
                <div className="mb-8">
                    <h1 className="text-2xl font-bold text-gray-900">Daftar Lapangan</h1>
                    <p className="text-gray-500 mt-1">Temukan dan booking lapangan yang tersedia</p>
                </div>

                {/* Filters */}
                <div className="card p-4 mb-6">
                    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
                        {/* Search */}
                        <div className="lg:col-span-2">
                            <input
                                type="text"
                                placeholder="Cari lapangan..."
                                value={search}
                                onChange={e => setSearch(e.target.value)}
                                onKeyDown={e => e.key === 'Enter' && applyFilters()}
                                className="input"
                            />
                        </div>
                        {/* Sport Type */}
                        <select value={sportType} onChange={e => setSportType(e.target.value)} className="input">
                            <option value="">Semua Olahraga</option>
                            <option value="badminton">🏸 Badminton</option>
                            <option value="futsal">⚽ Futsal</option>
                            <option value="basketball">🏀 Basket</option>
                            <option value="padel">🎾 Padel</option>
                            <option value="volleyball">🏐 Voli</option>
                        </select>
                        {/* Sort */}
                        <select value={sortBy} onChange={e => setSortBy(e.target.value)} className="input">
                            <option value="name_asc">Nama A-Z</option>
                            <option value="price_per_hour_asc">Harga Terendah</option>
                            <option value="price_per_hour_desc">Harga Tertinggi</option>
                        </select>
                        {/* Actions */}
                        <div className="flex gap-2">
                            <button onClick={applyFilters} className="btn-accent flex-1">Filter</button>
                            <button onClick={clearFilters} className="btn-ghost">Reset</button>
                        </div>
                    </div>
                </div>

                {/* Active Filters Tags */}
                {(filters.search || filters.sport_type) && (
                    <div className="flex flex-wrap items-center gap-2 mb-4">
                        <span className="text-sm text-gray-500">Filter aktif:</span>
                        {filters.search && <span className="badge-neutral">🔍 {filters.search} <button onClick={() => { setSearch(''); applyFilters(); }} className="ml-1">✕</button></span>}
                        {filters.sport_type && <span className="badge-accent">{filters.sport_type} <button onClick={() => { setSportType(''); applyFilters(); }} className="ml-1">✕</button></span>}
                    </div>
                )}

                {/* Venue Grid */}
                {venueData.length > 0 ? (
                    <>
                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                            {venueData.map(venue => (
                                <Link key={venue.id} href={route('venues.show', venue.id)} className="card-hover group overflow-hidden">
                                    <div className="aspect-video bg-gradient-to-br from-gray-200 to-gray-100 relative overflow-hidden">
                                        {venue.photos && venue.photos.length > 0 ? (
                                            <img src={`/storage/${venue.photos[0]}`} alt={venue.name} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
                                        ) : (
                                            <div className="w-full h-full flex items-center justify-center">
                                                <span className="text-5xl">{getSportEmoji(venue.sport_type)}</span>
                                            </div>
                                        )}
                                        <div className="absolute top-3 left-3">
                                            <span className={`badge ${getSportBadge(venue.sport_type)}`}>
                                                {getSportLabel(venue.sport_type)}
                                            </span>
                                        </div>
                                        {parseFloat(venue.average_rating) > 0 && (
                                            <div className="absolute top-3 right-3 bg-black/60 backdrop-blur-sm text-white px-2 py-1 rounded-lg flex items-center gap-1">
                                                <span className="text-amber-400 text-xs">★</span>
                                                <span className="text-xs font-semibold">{parseFloat(venue.average_rating).toFixed(1)}</span>
                                                <span className="text-[10px] text-gray-300">({venue.review_count || 0})</span>
                                            </div>
                                        )}
                                    </div>
                                    <div className="p-4">
                                        <h3 className="font-bold text-gray-900 mb-1 group-hover:text-accent transition-colors">{venue.name}</h3>
                                        <p className="text-sm text-gray-500 mb-2 flex items-center gap-1">📍 {venue.location}</p>
                                        {venue.facilities && venue.facilities.length > 0 && (
                                            <div className="flex flex-wrap gap-1 mb-3">
                                                {venue.facilities.slice(0, 3).map((f, i) => (
                                                    <span key={i} className="text-[10px] bg-gray-100 text-gray-600 px-2 py-0.5 rounded-full">{f}</span>
                                                ))}
                                                {venue.facilities.length > 3 && (
                                                    <span className="text-[10px] text-gray-400">+{venue.facilities.length - 3} lainnya</span>
                                                )}
                                            </div>
                                        )}
                                        <div className="flex items-center justify-between pt-2 border-t border-surface-border">
                                            <div>
                                                <span className="text-lg font-bold text-primary">Rp {parseInt(venue.price_per_hour).toLocaleString('id-ID')}</span>
                                                <span className="text-xs text-gray-400">/jam</span>
                                            </div>
                                            <span className="btn-accent btn-sm">Lihat Detail</span>
                                        </div>
                                    </div>
                                </Link>
                            ))}
                        </div>

                        {/* Pagination */}
                        {venueLinks.length > 3 && (
                            <div className="flex items-center justify-center gap-1 mt-8">
                                {venueLinks.map((link, i) => (
                                    <Link
                                        key={i}
                                        href={link.url || '#'}
                                        className={`px-3 py-2 text-sm rounded-lg transition-all ${link.active ? 'bg-primary text-white' :
                                            link.url ? 'text-gray-600 hover:bg-gray-100' : 'text-gray-300 cursor-not-allowed'
                                            }`}
                                        dangerouslySetInnerHTML={{ __html: link.label }}
                                        preserveState
                                    />
                                ))}
                            </div>
                        )}
                    </>
                ) : (
                    <div className="card p-12 text-center">
                        <span className="text-5xl mb-4 block">🔍</span>
                        <h3 className="text-lg font-semibold text-gray-900 mb-2">Tidak ada lapangan ditemukan</h3>
                        <p className="text-gray-500 mb-4">Coba ubah filter pencarian kamu</p>
                        <button onClick={clearFilters} className="btn-accent">Reset Filter</button>
                    </div>
                )}
            </div>
        </CustomerLayout>
    );
}
