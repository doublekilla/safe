import React, { useState } from 'react';
import { Head, Link, useForm } from '@inertiajs/react';
import CustomerLayout from '@/Layouts/CustomerLayout';
import { getSportEmoji } from '@/utils/sportTypes';

const CommunityHeader = ({ community }) => (
    <div className="bg-white border-b border-[#E2E8F0]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 md:py-12">
            <div className="flex flex-col md:flex-row gap-8 items-start md:items-center">
                <div className="w-24 h-24 md:w-32 md:h-32 rounded-2xl bg-[#F8FAFC] border border-[#E2E8F0] flex items-center justify-center text-4xl md:text-5xl shrink-0 overflow-hidden shadow-sm p-2">
                    {community.image ? (
                        <img src={community.image.startsWith('http') ? community.image : (community.image.startsWith('/') ? community.image : (community.image.startsWith('storage/') ? `/${community.image}` : `/storage/${community.image}`))} alt={community.name} className="w-full h-full object-contain" />
                    ) : (
                        getSportEmoji(community.sport_category)
                    )}
                </div>
                <div className="flex-1">
                    <div className="flex flex-wrap items-center gap-3 mb-2">
                        <span className="px-3 py-1 bg-accent/10 text-accent font-bold text-xs rounded-full border border-accent/20">
                            {community.sport_category}
                        </span>
                        <span className="text-[#64748B] text-sm flex items-center gap-1">
                            📍 {community.location}
                        </span>
                    </div>
                    <h1 className="text-3xl md:text-4xl font-black text-[#0F172A] mb-3 leading-tight">{community.name}</h1>
                    <p className="text-[#64748B] text-base md:text-lg max-w-2xl leading-relaxed mb-6">
                        {community.description}
                    </p>
                    <div className="flex flex-wrap items-center gap-4 text-sm">
                        <div className="flex items-center gap-2">
                            <span className="w-8 h-8 rounded-full bg-gradient-primary flex items-center justify-center text-white font-bold text-xs">
                                {community.admin?.avatar ? (
                                    <img src={`/storage/${community.admin.avatar}`} alt="Admin" className="w-full h-full object-cover rounded-full" />
                                ) : (
                                    community.admin?.name?.charAt(0) || 'A'
                                )}
                            </span>
                            <span className="text-[#64748B]">Admin: <strong className="text-[#0F172A]">{community.admin?.name || 'Admin'}</strong></span>
                        </div>
                        <div className="w-1.5 h-1.5 rounded-full bg-[#E2E8F0] hidden sm:block"></div>
                        <span className="text-[#0F172A] font-medium">👥 {community.memberships_count} Anggota</span>
                        <div className="w-1.5 h-1.5 rounded-full bg-[#E2E8F0] hidden sm:block"></div>
                        <span className="text-[#0F172A] font-medium">💬 {community.feed_posts_count} Diskusi</span>
                    </div>
                </div>
                <div className="w-full md:w-auto">
                    <Link href={route('download.app')} className="inline-block text-center w-full md:w-auto px-8 py-3 bg-accent hover:bg-accent-hover text-primary font-bold rounded-xl transition-colors shadow-sm">
                        Gabung Komunitas
                    </Link>
                </div>
            </div>
        </div>
    </div>
);

const CommunityDiscussions = ({ community, recentDiscussions }) => {
    const [openComments, setOpenComments] = useState({});

    const toggleComments = (postId) => {
        setOpenComments(prev => ({ ...prev, [postId]: !prev[postId] }));
    };

    return (
        <div className="bg-white border border-[#E2E8F0] rounded-2xl p-6 shadow-sm mb-8">
            <h3 className="text-xl font-bold text-[#0F172A] mb-6">Forum Diskusi</h3>

            <div className="space-y-6">
                {recentDiscussions.length > 0 ? (
                    recentDiscussions.map(post => (
                        <div key={post.id} className="flex gap-4 pb-6 border-b border-[#E2E8F0] last:border-0 last:pb-0">
                            <div className="w-10 h-10 rounded-full bg-gradient-primary border border-[#E2E8F0] flex items-center justify-center font-bold text-white shrink-0 overflow-hidden">
                                {post.user?.avatar ? (
                                    <img src={`/storage/${post.user.avatar}`} alt={post.user.name} className="w-full h-full object-cover" />
                                ) : (
                                    post.user?.name ? post.user.name.charAt(0) : 'U'
                                )}
                            </div>
                            <div className="flex-1">
                                <div className="flex items-center gap-2 mb-1">
                                    <h4 className="font-bold text-[#0F172A] text-sm">{post.user?.name ?? 'Pengguna SpaceLink'}</h4>
                                </div>
                                <p className="text-[#0F172A] text-sm leading-relaxed mb-3 whitespace-pre-wrap">{post.text}</p>
                                
                                {post.image && (
                                    <div className="mb-4 rounded-xl overflow-hidden border border-[#E2E8F0] bg-[#F8FAFC] flex justify-center items-center p-2">
                                        <img 
                                            src={post.image.startsWith('http') ? post.image : (post.image.startsWith('/') ? post.image : (post.image.startsWith('storage/') ? '/' + post.image : '/storage/' + post.image))} 
                                            alt="Post image" 
                                            className="max-h-80 w-auto object-contain rounded"
                                        />
                                    </div>
                                )}
                                <div className="flex items-center justify-between text-sm mb-3 w-full">
                                    <div className="flex items-center gap-6">
                                        <button className="flex items-center gap-1.5 text-gray-500 hover:text-accent transition-colors">
                                            ❤️ <span>{post.likes_count ?? 0} suka</span>
                                        </button>
                                        <button 
                                            onClick={() => toggleComments(post.id)}
                                            className="flex items-center gap-1.5 text-gray-500 hover:text-accent transition-colors"
                                        >
                                            💬 <span>{post.comments_count ?? 0} balasan</span>
                                        </button>
                                    </div>
                                    <span className="text-gray-400 text-xs">
                                        {new Date(post.created_at).toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' })}
                                    </span>
                                </div>
                                {openComments[post.id] && post.comments && (
                                    <div className="mt-4 space-y-4 pl-4 border-l-2 border-[#E2E8F0]">
                                        {post.comments.length > 0 ? (
                                            post.comments.map(comment => (
                                                <div key={comment.id} className="flex gap-3">
                                                    <div className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center font-bold text-xs shrink-0 overflow-hidden">
                                                        {comment.user?.avatar ? (
                                                            <img src={`/storage/${comment.user.avatar}`} alt={comment.user.name} className="w-full h-full object-cover" />
                                                        ) : (
                                                            comment.user?.name ? comment.user.name.charAt(0) : 'U'
                                                        )}
                                                    </div>
                                                    <div className="bg-[#F8FAFC] rounded-2xl px-4 py-2 flex-1">
                                                        <h5 className="font-bold text-[#0F172A] text-xs mb-0.5">{comment.user?.name ?? 'Pengguna'}</h5>
                                                        <p className="text-[#0F172A] text-xs leading-relaxed">{comment.comment}</p>
                                                    </div>
                                                </div>
                                            ))
                                        ) : (
                                            <p className="text-xs text-gray-500 italic">Belum ada balasan.</p>
                                        )}
                                    </div>
                                )}
                            </div>
                        </div>
                    ))
                ) : (
                    <div className="text-center py-12 text-gray-500 bg-[#F8FAFC] rounded-xl border border-dashed border-[#E2E8F0]">
                        Belum ada diskusi di komunitas ini. Jadilah yang pertama!
                    </div>
                )}
            </div>
        </div>
    );
};

const CommunitySidebar = ({ community }) => (
    <div className="space-y-6">
        <div className="bg-white border border-[#E2E8F0] rounded-2xl p-6 shadow-sm">
            <h3 className="font-bold text-[#0F172A] mb-4">Tentang Komunitas</h3>
            <div className="space-y-4 text-sm text-[#64748B]">
                <div className="flex items-start gap-3">
                    <span className="text-xl">🎯</span>
                    <div>
                        <strong className="block text-[#0F172A] mb-0.5">Rules</strong>
                        <p>{community.rules || 'Komunitas terbuka untuk semua yang ingin bermain santai dan mencari keringat.'}</p>
                    </div>
                </div>
                <div className="flex items-start gap-3">
                    <span className="text-xl">🔒</span>
                    <div>
                        <strong className="block text-[#0F172A] mb-0.5">Privasi</strong>
                        <p>{community.privacy === 'private' ? 'Pribadi (Butuh Persetujuan)' : 'Terbuka untuk Umum'}</p>
                    </div>
                </div>
            </div>
        </div>

        <div className="bg-white border border-[#E2E8F0] rounded-2xl p-6 shadow-sm">
            <div className="flex items-center justify-between mb-4">
                <h3 className="font-bold text-[#0F172A]">Anggota Terbaru</h3>
                <span className="text-xs text-accent font-bold bg-accent/10 px-2 py-1 rounded-md">{community.memberships_count}</span>
            </div>
            {community.members && community.members.length > 0 ? (
                <div className="flex flex-wrap gap-2">
                    {community.members.map(member => (
                        <div key={member.id} className="w-10 h-10 rounded-full bg-gradient-primary border-2 border-white shadow-sm flex items-center justify-center text-white font-bold text-sm overflow-hidden" title={member.name}>
                            {member.avatar ? (
                                <img src={`/storage/${member.avatar}`} alt={member.name} className="w-full h-full object-cover" />
                            ) : (
                                member.name.charAt(0)
                            )}
                        </div>
                    ))}
                    {community.memberships_count > community.members.length && (
                        <div className="w-10 h-10 rounded-full bg-[#F8FAFC] border-2 border-white shadow-sm flex items-center justify-center text-[#64748B] font-bold text-xs">
                            +{community.memberships_count - community.members.length}
                        </div>
                    )}
                </div>
            ) : (
                <p className="text-sm text-gray-500">Belum ada data anggota.</p>
            )}
        </div>
    </div>
);

export default function CommunityShow({ community, recentDiscussions }) {
    return (
        <CustomerLayout title={community.name}>
            <Head title={`${community.name} - Komunitas EithSpace`} />
            
            <div className="bg-[#F8FAFC] min-h-screen pb-16">
                {/* Breadcrumb */}
                <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
                    <div className="flex items-center gap-2 text-sm text-[#64748B]">
                        <Link href={route('community.index')} className="hover:text-accent transition-colors">Komunitas</Link>
                        <span>/</span>
                        <span className="text-[#0F172A] font-medium truncate">{community.name}</span>
                    </div>
                </div>

                <CommunityHeader community={community} />

                <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 mt-8">
                    <div className="flex flex-col lg:flex-row gap-8">
                        <div className="lg:w-2/3">
                            <CommunityDiscussions community={community} recentDiscussions={recentDiscussions} />
                        </div>
                        <div className="lg:w-1/3">
                            <CommunitySidebar community={community} />
                        </div>
                    </div>
                </div>
            </div>
        </CustomerLayout>
    );
}
