<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <title>Web Dev Skills Test</title>
    @vite('resources/css/app.css')
    <link
        rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/@fancyapps/ui@6.0/dist/fancybox/fancybox.css"
        />
</head>

<body class="bg-white text-center font-sans py-10">

    <div class="flex justify-center">
        <div class="flex flex-col w-md">
            <h2 class="font-semibold text-4xl mb-2">Web Dev Skills Test</h2>
            <p class="text-lg text-gray-700 mb-10">
                This website will allow you to upload your photos and view them in a three-column table.
            </p>
        </div>
    </div>


    @if(session('success'))
        <div class="alert alert-success w-1/2 mx-auto my-3 text-green-700 bg-green-100 p-3 rounded">
            {{ session('success') }}
        </div>
    @endif

    @if ($errors->any())
        <div class="alert alert-danger w-1/2 mx-auto my-3 bg-red-100 text-red-700 p-3 rounded">
            <ul class="list-disc list-inside">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('upload') }}" method="POST" enctype="multipart/form-data" class="flex flex-col items-center">
        @csrf
        <label for="file-upload"
            class="bg-white border-2 border-green-500 px-28 py-2 cursor-pointer font-medium">
            Upload button
        </label>

        <input id="file-upload" type="file" name="images[]" multiple onchange="this.form.submit()" class="hidden">
    </form>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-10 px-10 mt-2">
        @foreach($photos->chunk(ceil($photos->count() / 3)) as $column)
            <div class="border-2 border-green-500 p-4 bg-white px-12">
                @foreach($column as $photo)
                <a
                    data-fancybox="gallery"
                    data-src="{{ asset('storage/images/' . $photo->filename) }}"
                    data-caption="{{ $photo->filename }}"
                    >
                    <img src="{{ asset('storage/images/' . $photo->filename) }}" alt="Uploaded Image"
                        class="w-full h-64 object-cover mb-4 rounded shadow-sm">
                    </a>
                @endforeach
            </div>
        @endforeach
    </div>

<script src="https://cdn.jsdelivr.net/npm/@fancyapps/ui@6.0/dist/fancybox/fancybox.umd.js"></script>
<script>
    Fancybox.bind("[data-fancybox]", {
        Carousel: {
            Toolbar: {
            display: {
                left: ["counter"],
                middle: [
                "zoomIn",
                "zoomOut",
                "toggle1to1",
                "rotateCCW",
                "rotateCW",
                "flipX",
                "flipY",
                "reset",
                ],
                right: ["autoplay", "thumbs", "close"],
            },
            },
        },
    });
</script>
</body>

</html>
