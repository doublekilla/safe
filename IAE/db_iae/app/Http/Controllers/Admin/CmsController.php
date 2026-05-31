<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CmsContent;
use App\Models\Faq;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Inertia\Inertia;

class CmsController extends Controller
{
    public function index()
    {
        $contents = CmsContent::latest()->get()->groupBy('type');
        $faqs = Faq::ordered()->get();

        return Inertia::render('Admin/Cms/Index', [
            'contents' => $contents,
            'faqs' => $faqs,
        ]);
    }

    public function storeContent(Request $request)
    {
        $validated = $request->validate([
            'key' => 'required|string|unique:cms_contents,key',
            'title' => 'required|string|max:255',
            'content' => 'nullable|string',
            'type' => 'required|in:banner,promo,page,contact,terms,refund_policy',
            'is_active' => 'boolean',
            'media_files' => 'nullable|array',
            'media_files.*' => 'file|max:5120',
        ]);

        $media = [];
        if ($request->hasFile('media_files')) {
            foreach ($request->file('media_files') as $file) {
                $media[] = $file->store('cms', 'public');
            }
        }

        $validated['media'] = $media;
        unset($validated['media_files']);

        CmsContent::create($validated);

        return back()->with('success', 'Konten berhasil ditambahkan.');
    }

    public function updateContent(Request $request, CmsContent $content)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'nullable|string',
            'is_active' => 'boolean',
            'media_files' => 'nullable|array',
            'media_files.*' => 'file|max:5120',
            'existing_media' => 'nullable|array',
        ]);

        $media = $request->get('existing_media', []);

        if ($request->hasFile('media_files')) {
            foreach ($request->file('media_files') as $file) {
                $media[] = $file->store('cms', 'public');
            }
        }

        // Clean up removed media
        $oldMedia = $content->media ?? [];
        foreach (array_diff($oldMedia, $media) as $removed) {
            Storage::disk('public')->delete($removed);
        }

        $content->update([
            'title' => $validated['title'],
            'content' => $validated['content'],
            'is_active' => $validated['is_active'] ?? true,
            'media' => $media,
        ]);

        return back()->with('success', 'Konten berhasil diperbarui.');
    }

    public function destroyContent(CmsContent $content)
    {
        if ($content->media) {
            foreach ($content->media as $file) {
                Storage::disk('public')->delete($file);
            }
        }

        $content->delete();

        return back()->with('success', 'Konten berhasil dihapus.');
    }

    // FAQ Management
    public function faqs()
    {
        $faqs = Faq::ordered()->get();

        return Inertia::render('Admin/Cms/Faqs', [
            'faqs' => $faqs,
        ]);
    }

    public function storeFaq(Request $request)
    {
        $validated = $request->validate([
            'question' => 'required|string|max:500',
            'answer' => 'required|string',
            'category' => 'required|string|max:100',
            'order' => 'nullable|integer',
            'is_active' => 'boolean',
        ]);

        Faq::create($validated);

        return back()->with('success', 'FAQ berhasil ditambahkan.');
    }

    public function updateFaq(Request $request, Faq $faq)
    {
        $validated = $request->validate([
            'question' => 'required|string|max:500',
            'answer' => 'required|string',
            'category' => 'required|string|max:100',
            'order' => 'nullable|integer',
            'is_active' => 'boolean',
        ]);

        $faq->update($validated);

        return back()->with('success', 'FAQ berhasil diperbarui.');
    }

    public function destroyFaq(Faq $faq)
    {
        $faq->delete();

        return back()->with('success', 'FAQ berhasil dihapus.');
    }
}
