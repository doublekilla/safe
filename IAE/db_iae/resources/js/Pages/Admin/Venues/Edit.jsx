import AdminLayout from '@/Layouts/AdminLayout';
import { Head, useForm, Link, router } from '@inertiajs/react';
import { useState } from 'react';


export default function VenueEdit({ venue }) {
    const { data, setData, processing, errors } = useForm({
        name: venue.name || '',
        sport_type: venue.sport_type || 'badminton',
        description: venue.description || '',
        location: venue.location || '',
        price_per_hour: venue.price_per_hour || '',
        facilities: venue.facilities || [],
        operating_hours: venue.operating_hours || {
            monday: ['08:00', '22:00'],
            tuesday: ['08:00', '22:00'],
            wednesday: ['08:00', '22:00'],
            thursday: ['08:00', '22:00'],
            friday: ['08:00', '22:00'],
            saturday: ['07:00', '23:00'],
            sunday: ['07:00', '23:00'],
        },
        status: venue.status || 'active',
        existing_photos: venue.photos || [],
        new_photos: [],
    });

    const [facilityInput, setFacilityInput] = useState('');

    const addFacility = () => {
        if (facilityInput.trim()) {
            setData('facilities', [...data.facilities, facilityInput.trim()]);
            setFacilityInput('');
        }
    };
    const removeFacility = (i) => setData('facilities', data.facilities.filter((_, idx) => idx !== i));

    const removeExistingPhoto = (i) => {
        setData('existing_photos', data.existing_photos.filter((_, idx) => idx !== i));
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        // Use router.post with _method: 'PUT' for file upload support
        router.post(route('admin.venues.update', venue.id), {
            _method: 'PUT',
            ...data,
        }, {
            forceFormData: true,
            preserveScroll: true,
        });
    };

    return (
        <AdminLayout title="Edit Lapangan">
            <Head title={`Edit - ${venue.name}`} />
            <div className="max-w-3xl">
                <div className="mb-6">
                    <Link href={route('admin.venues.index')} className="text-sm text-gray-500 hover:text-gray-700">← Kembali</Link>
                    <h1 className="text-xl font-bold text-gray-900 mt-2">Edit: {venue.name}</h1>
                </div>
                <form onSubmit={handleSubmit} className="space-y-6">
                    {/* Informasi Dasar */}
                    <div className="card p-6 space-y-4">
                        <h3 className="font-semibold text-gray-900">Informasi Dasar</h3>
                        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <div>
                                <label className="input-label">Nama Lapangan *</label>
                                <input type="text" value={data.name} onChange={e => setData('name', e.target.value)} className={`input ${errors.name ? 'input-error' : ''}`} />
                                {errors.name && <p className="input-error-msg">{errors.name}</p>}
                            </div>
                            <div>
                                <label className="input-label">Jenis Olahraga *</label>
                                <select value={data.sport_type} onChange={e => setData('sport_type', e.target.value)} className="input">
                                    <option value="badminton">🏸 Badminton</option>
                                    <option value="futsal">⚽ Futsal</option>
                                    <option value="basketball">🏀 Basket</option>
                                    <option value="padel">🎾 Padel</option>
                                    <option value="volleyball">🏐 Voli</option>
                                </select>
                            </div>
                            <div>
                                <label className="input-label">Lokasi *</label>
                                <input type="text" value={data.location} onChange={e => setData('location', e.target.value)} className={`input ${errors.location ? 'input-error' : ''}`} />
                                {errors.location && <p className="input-error-msg">{errors.location}</p>}
                            </div>
                            <div>
                                <label className="input-label">Harga per Jam (Rp) *</label>
                                <input type="number" value={data.price_per_hour} onChange={e => setData('price_per_hour', e.target.value)} className={`input ${errors.price_per_hour ? 'input-error' : ''}`} />
                                {errors.price_per_hour && <p className="input-error-msg">{errors.price_per_hour}</p>}
                            </div>
                        </div>
                        <div>
                            <label className="input-label">Deskripsi</label>
                            <textarea value={data.description} onChange={e => setData('description', e.target.value)} className="input h-24 resize-none" placeholder="Deskripsi lapangan..." />
                        </div>
                        <div>
                            <label className="input-label">Status</label>
                            <select value={data.status} onChange={e => setData('status', e.target.value)} className="input w-48">
                                <option value="active">Active</option>
                                <option value="inactive">Inactive</option>
                                <option value="maintenance">Maintenance</option>
                            </select>
                        </div>
                    </div>

                    {/* Fasilitas */}
                    <div className="card p-6">
                        <h3 className="font-semibold text-gray-900 mb-3">Fasilitas</h3>
                        <div className="flex gap-2 mb-3">
                            <input type="text" value={facilityInput} onChange={e => setFacilityInput(e.target.value)} onKeyDown={e => { if (e.key === 'Enter') { e.preventDefault(); addFacility(); } }} className="input flex-1" placeholder="Tambah fasilitas..." />
                            <button type="button" onClick={addFacility} className="btn-outline btn-sm">Tambah</button>
                        </div>
                        <div className="flex flex-wrap gap-2">
                            {data.facilities.map((f, i) => (
                                <span key={i} className="badge-accent">{f}<button type="button" onClick={() => removeFacility(i)} className="ml-1">✕</button></span>
                            ))}
                        </div>
                    </div>

                    {/* Jam Operasional */}
                    <div className="card p-6">
                        <h3 className="font-semibold text-gray-900 mb-3">Jam Operasional</h3>
                        <div className="space-y-3">
                            {Object.entries(data.operating_hours).map(([day, hours]) => {
                                const dayNames = { monday: 'Senin', tuesday: 'Selasa', wednesday: 'Rabu', thursday: 'Kamis', friday: 'Jumat', saturday: 'Sabtu', sunday: 'Minggu' };
                                return (
                                    <div key={day} className="flex items-center gap-3">
                                        <span className="text-sm text-gray-700 w-16 font-medium">{dayNames[day]}</span>
                                        <input type="time" value={hours[0]} onChange={e => {
                                            const updated = { ...data.operating_hours };
                                            updated[day] = [e.target.value, hours[1]];
                                            setData('operating_hours', updated);
                                        }} className="input w-32 text-sm" />
                                        <span className="text-gray-400">—</span>
                                        <input type="time" value={hours[1]} onChange={e => {
                                            const updated = { ...data.operating_hours };
                                            updated[day] = [hours[0], e.target.value];
                                            setData('operating_hours', updated);
                                        }} className="input w-32 text-sm" />
                                    </div>
                                );
                            })}
                        </div>
                    </div>

                    {/* Foto yang Ada */}
                    {data.existing_photos.length > 0 && (
                        <div className="card p-6">
                            <h3 className="font-semibold text-gray-900 mb-3">Foto Saat Ini</h3>
                            <div className="grid grid-cols-3 sm:grid-cols-4 gap-3">
                                {data.existing_photos.map((photo, i) => (
                                    <div key={i} className="relative group rounded-lg overflow-hidden">
                                        <img src={`/storage/${photo}`} alt="" className="w-full h-24 object-cover" />
                                        <button type="button" onClick={() => removeExistingPhoto(i)} className="absolute top-1 right-1 w-6 h-6 bg-red-500 text-white rounded-full text-xs flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">✕</button>
                                    </div>
                                ))}
                            </div>
                        </div>
                    )}

                    {/* Upload Foto Baru */}
                    <div className="card p-6">
                        <h3 className="font-semibold text-gray-900 mb-3">Tambah Foto Baru</h3>
                        <input type="file" multiple accept="image/*" onChange={e => setData('new_photos', Array.from(e.target.files))} className="input" />
                        <p className="input-hint">Upload beberapa foto lapangan (max 2MB per foto)</p>
                    </div>

                    {/* Actions */}
                    <div className="flex gap-3">
                        <button type="submit" disabled={processing} className="btn-accent">{processing ? 'Menyimpan...' : 'Simpan Perubahan'}</button>
                        <Link href={route('admin.venues.index')} className="btn-ghost">Batal</Link>
                    </div>
                </form>
            </div>
        </AdminLayout>
    );
}
