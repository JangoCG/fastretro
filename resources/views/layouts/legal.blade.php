<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title') - Fast Retro</title>
    <meta name="description"
          content="@yield('description', 'Legal information for Fast Retro - Open Source Retrospective Tool')">
    @vite(['resources/css/blade.css', 'resources/js/blade.js'])
</head>
<body class="bg-white antialiased font-sans">
<div class="legal-document">
    <div class="legal-document-container">
        <div class="markdown-content">
            @yield('content')
        </div>
    </div>
</div>
</body>
</html>
