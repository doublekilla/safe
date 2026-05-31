import CustomerLayout from '@/Layouts/CustomerLayout';
import { Head, Link, router } from '@inertiajs/react';
import { useState } from 'react';
import { getSportEmoji } from '@/utils/sportTypes';

const CommunityCard = ({ community }) => (
    <div className="bg-white border border-[#E2E8F0] rounded-2xl p-6 shadow-[0_4px_6px_-1px_rgba(0,0,0,0.05)] hover:shadow-[0_10px_15px_-3px_rgba(0,0,0,0.1)] transition-all duration-200 hover:-translate-y-1 flex flex-col h-full">
        <div className="flex items-start gap-4 mb-4">
            <div className="w-12 h-12 rounded-xl bg-[#F8FAFC] border border-[#E2E8F0] flex items-center justify-center text-2xl shrink-0 overflow-hidden">
                {community.image ? (
                    <img src={community.image.startsWith('http') ? community.image : (community.image.startsWith('/') ? community.image : (community.image.startsWith('storage/') ? `/${community.image}` : `/storage/${community.image}`))} alt={community.name} className="w-full h-full object-contain" />
                ) : (
                    getSportEmoji(community.sport_category)
                )}
            </div>
            <div>
                <h3 className="font-bold text-[#0F172A] text-lg leading-tight mb-1">{community.name}</h3>
                <div className="flex flex-wrap items-center gap-x-3 gap-y-1 text-sm text-[#64748B]">
                    <span className="flex items-center gap-1">📍 {community.location}</span>
                    <span className="flex items-center gap-1 capitalize">🏷️ {community.sport_category}</span>
                </div>
            </div>
        </div>
        
        <div className="flex flex-wrap gap-2 mb-4">
            <span className="px-2.5 py-1 bg-[#F8FAFC] border border-[#E2E8F0] rounded-md text-xs font-medium text-[#0F172A]">
                👥 {community.memberships_count} anggota
            </span>
            <span className="px-2.5 py-1 bg-[#F8FAFC] border border-[#E2E8F0] rounded-md text-xs font-medium text-[#0F172A]">
                ⭐ {community.activity_frequency ?? 'Aktif'}
            </span>
        </div>
        
        <p className="text-[#64748B] text-sm flex-1 mb-5 line-clamp-3">
            {community.description}
        </p>
        
        <div className="pt-4 border-t border-[#E2E8F0] flex items-center justify-between mt-auto">
            <div className="text-xs text-[#64748B]">
                <span className="font-medium text-primary">{community.feed_posts_count} diskusi</span>
            </div>
            <Link href={route('community.show', community.id)} className="px-4 py-2 bg-accent hover:bg-accent-hover text-primary hover:text-primary text-sm font-bold rounded-lg transition-colors">
                Detail
            </Link>
        </div>
    </div>
);

export default function CommunityBrowse({ communities, filters: rawFilters }) {
    const filters = rawFilters && typeof rawFilters === 'object' && !Array.isArray(rawFilters) ? rawFilters : {};

    const [search, setSearch] = useState(filters.search || '');
    const [sportType, setSportType] = useState(filters.sport_type || '');
    const [sortBy, setSortBy] = useState(filters.sort ? `${filters.sort}_${filters.direction || 'desc'}` : '');
    const [isFilterOpen, setIsFilterOpen] = useState(false);

    const handleSearch = (e) => {
        if (e) e.preventDefault();
        setIsFilterOpen(false);
        applyFilters();
    };

    const applyFilters = () => {
        const params = {};
        if (search) params.search = search;
        if (sportType) params.sport_type = sportType;
        if (sortBy && sortBy !== '') {
            const lastUnderscore = sortBy.lastIndexOf('_');
            params.sort = sortBy.substring(0, lastUnderscore);
            params.direction = sortBy.substring(lastUnderscore + 1);
        }
        router.get(route('community.browse'), params, { preserveState: true });
    };

    const clearFilters = () => {
        setSearch(''); setSportType(''); setSortBy('');
        router.get(route('community.browse'));
    };

    const communityData = communities?.data || [];
    const communityLinks = communities?.links || [];

    return (
        <CustomerLayout>
            <Head title="Daftar Komunitas" />
            <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                {/* Header */}
                <div className="mb-8">
                    <h1 className="text-2xl font-bold text-gray-900">Daftar Komunitas</h1>
                    <p className="text-gray-500 mt-1">Temukan komunitas yang sesuai dengan minat dan level bermainmu</p>
                </div>

                {/* Filters */}
                <form onSubmit={handleSearch} className="bg-white p-4 rounded-2xl shadow-[0_4px_6px_-1px_rgba(0,0,0,0.05)] border border-[#E2E8F0] flex items-center gap-4 mb-6 relative">
                    <div className="flex-1 relative">
                        <span className="absolute left-4 top-1/2 -translate-y-1/2 text-[#64748B]">🔍</span>
                        <input
                            type="text"
                            placeholder="Cari komunitas atau lokasi..."
                            value={search}
                            onChange={e => setSearch(e.target.value)}
                            className="w-full pl-11 pr-4 py-3 bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl focus:outline-none focus:ring-2 focus:ring-accent focus:border-transparent transition-all"
                        />
                    </div>
                    
                    <div className="relative">
                        <button 
                            type="button"
                            onClick={() => setIsFilterOpen(!isFilterOpen)}
                            className={`p-3 rounded-xl border transition-colors flex items-center justify-center ${isFilterOpen || sportType !== '' || sortBy !== '' ? 'bg-accent/10 border-accent text-accent' : 'bg-[#F8FAFC] border-[#E2E8F0] text-[#64748B] hover:bg-gray-50'}`}
                            title="Filter"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon>
                            </svg>
                            {(sportType !== '' || sortBy !== '') && (
                                <span className="absolute -top-1 -right-1 w-3 h-3 bg-accent rounded-full border-2 border-white"></span>
                            )}
                        </button>

                        {isFilterOpen && (
                            <div className="absolute right-0 top-full mt-2 w-72 bg-white rounded-2xl shadow-xl border border-[#E2E8F0] p-5 z-50">
                                <div className="mb-4">
                                    <label className="block text-sm font-bold text-[#0F172A] mb-2">Cabang Olahraga</label>
                                    <select 
                                        value={sportType} 
                                        onChange={e => setSportType(e.target.value)} 
                                        className="w-full px-4 py-2.5 bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-accent"
                                    >
                                        <option value="">Semua Olahraga</option>
                                        <option value="badminton">Badminton</option>
                                        <option value="basketball">Basketball</option>
                                        <option value="futsal">Futsal</option>
                                        <option value="padel">Padel</option>
                                        <option value="volleyball">Volleyball</option>
                                    </select>
                                </div>
                                <div className="mb-6">
                                    <label className="block text-sm font-bold text-[#0F172A] mb-2">Urutkan</label>
                                    <select 
                                        value={sortBy} 
                                        onChange={e => setSortBy(e.target.value)} 
                                        className="w-full px-4 py-2.5 bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-accent"
                                    >
                                        <option value="">Semua</option>
                                        <option value="members_desc">Paling Banyak</option>
                                        <option value="members_asc">Paling Sedikit</option>
                                    </select>
                                </div>
                                <div className="flex gap-2">
                                    <button 
                                        type="button" 
                                        onClick={() => { clearFilters(); setIsFilterOpen(false); }}
                                        className="w-full py-2.5 bg-[#F8FAFC] hover:bg-[#E2E8F0] border border-[#E2E8F0] text-[#64748B] font-bold rounded-xl transition-colors text-sm"
                                    >
                                        Hapus
                                    </button>
                                    <button 
                                        type="button" 
                                        onClick={handleSearch}
                                        className="w-full py-2.5 bg-accent hover:bg-accent-hover text-primary font-bold rounded-xl transition-colors text-sm"
                                    >
                                        Terapkan
                                    </button>
                                </div>
                            </div>
                        )}
                    </div>

                    <button type="submit" className="px-6 py-3 bg-primary text-white font-bold rounded-xl hover:bg-accent hover:text-primary transition-colors whitespace-nowrap">
                        Cari
                    </button>
                </form>

                {/* Active Filters Tags */}
                {(filters.search || filters.sport_type) && (
                    <div className="flex flex-wrap items-center gap-2 mb-6">
                        <span className="text-sm text-gray-500">Filter aktif:</span>
                        {filters.search && (
                            <span className="bg-[#F8FAFC] border border-[#E2E8F0] text-[#0F172A] text-sm px-3 py-1 rounded-full flex items-center gap-2">
                                🔍 {filters.search} 
                                <button onClick={() => { setSearch(''); applyFilters(); }} className="text-gray-400 hover:text-red-500">✕</button>
                            </span>
                        )}
                        {filters.sport_type && (
                            <span className="bg-accent/10 border border-accent text-accent text-sm px-3 py-1 rounded-full flex items-center gap-2 font-medium">
                                {filters.sport_type} 
                                <button onClick={() => { setSportType(''); applyFilters(); }} className="hover:text-red-500">✕</button>
                            </span>
                        )}
                    </div>
                )}

                {/* Community Grid */}
                {communityData.length > 0 ? (
                    <>
                        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                            {communityData.map(community => (
                                <CommunityCard key={community.id} community={community} />
                            ))}
                        </div>

                        {/* Pagination */}
                        {communityLinks.length > 3 && (
                            <div className="flex items-center justify-center gap-1 mt-8">
                                {communityLinks.map((link, i) => (
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
                    <div className="bg-white border border-[#E2E8F0] rounded-2xl p-12 text-center shadow-sm">
                        <span className="text-5xl mb-4 block">🔍</span>
                        <h3 className="text-lg font-bold text-gray-900 mb-2">Tidak ada komunitas ditemukan</h3>
                        <p className="text-gray-500 mb-6">Coba ubah filter pencarian kamu</p>
                        <button onClick={clearFilters} className="px-6 py-2 bg-accent hover:bg-accent-hover text-primary font-bold rounded-xl transition-colors">
                            Reset Filter
                        </button>
                    </div>
                )}
            </div>
        </CustomerLayout>
    );
}
