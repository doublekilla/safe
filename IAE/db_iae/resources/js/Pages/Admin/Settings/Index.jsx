import AdminLayout from '@/Layouts/AdminLayout';
import { Head, useForm } from '@inertiajs/react';


export default function SettingsIndex({ settings }) {
    const allSettings = settings ? Object.values(settings).flat() : [];
    const { data, setData, post, processing } = useForm({ settings: allSettings.map(s => ({ key: s.key, value: s.value, type: s.type, group: s.group, label: s.label })) });

    const updateSetting = (key, value) => {
        setData('settings', data.settings.map(s => s.key === key ? { ...s, value } : s));
    };

    const handleSubmit = (e) => { e.preventDefault(); post(route('admin.settings.update')); };
    const groups = settings ? Object.keys(settings) : [];

    return (
        <AdminLayout title="Pengaturan">
            <Head title="Pengaturan" />
            <h1 className="text-xl font-bold text-gray-900 mb-6">Pengaturan Bisnis</h1>
            <form onSubmit={handleSubmit} className="max-w-3xl space-y-6">
                {groups.map(group => (
                    <div key={group} className="card p-6">
                        <h3 className="font-semibold text-gray-900 mb-4 capitalize">⚙️ {group}</h3>
                        <div className="space-y-4">
                            {settings[group].map(setting => (
                                <div key={setting.key} className="flex items-center justify-between gap-4">
                                    <label className="text-sm font-medium text-gray-700 flex-1">{setting.label || setting.key}</label>
                                    {setting.type === 'boolean' ? (
                                        <select value={data.settings.find(s => s.key === setting.key)?.value || 'false'} onChange={e => updateSetting(setting.key, e.target.value)} className="input w-32">
                                            <option value="true">Ya</option><option value="false">Tidak</option>
                                        </select>
                                    ) : (
                                        <input type={setting.type === 'integer' ? 'number' : 'text'} value={data.settings.find(s => s.key === setting.key)?.value || ''} onChange={e => updateSetting(setting.key, e.target.value)} className="input w-64" />
                                    )}
                                </div>
                            ))}
                        </div>
                    </div>
                ))}
                <button type="submit" disabled={processing} className="btn-accent">{processing ? 'Menyimpan...' : 'Simpan Pengaturan'}</button>
            </form>
        </AdminLayout>
    );
}
