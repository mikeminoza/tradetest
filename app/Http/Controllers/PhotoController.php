<?php

namespace App\Http\Controllers;

use App\Models\Photo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PhotoController extends Controller
{
    public function index()
    {
        $photos = Photo::all();
        return view('index', compact('photos'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'images.*' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
        ], [
            'images.*.image' => 'Each file must be an image.',
            'images.*.mimes' => 'Allowed image types: jpeg, png, jpg, gif.',
            'images.*.max' => 'Each image must be smaller than 2MB.',
        ]);

        if ($request->hasfile('images')) {
            foreach ($request->file('images') as $file) {
                $filename = time() . '_' . $file->getClientOriginalName();
                Storage::disk('public')->putFileAs('images', $file, $filename);
                Photo::create(['filename' => $filename]);
            }
        }

        return redirect()->back()->with('success', 'Images uploaded successfully!');
    }

}
