<?php

namespace App\Http\Controllers;

use App\Models\Faq;
use Inertia\Inertia;

class FaqController extends Controller
{
    public function index()
    {
        $faqs = Faq::active()->ordered()->get()->groupBy('category');

        return Inertia::render('Faq/Index', [
            'faqs' => $faqs,
        ]);
    }
}
