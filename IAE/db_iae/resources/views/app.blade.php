<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title inertia>{{ config('app.name', 'Laravel') }}</title>

        <!-- Fonts -->
        <link rel="preconnect" href="https://fonts.bunny.net">
        <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />

        <script>
            window.onerror = function(message, source, lineno, colno, error) {
                document.body.innerHTML = '<div style="color: red; padding: 20px;"><h1>Javascript Error</h1><p>' + message + '</p><pre>' + (error ? error.stack : '') + '</pre></div>';
            };
            window.addEventListener('unhandledrejection', function(event) {
                document.body.innerHTML = '<div style="color: red; padding: 20px;"><h1>Unhandled Promise Rejection</h1><p>' + event.reason + '</p><pre>' + (event.reason ? event.reason.stack : '') + '</pre></div>';
            });
        </script>
        <!-- Scripts -->
        @routes
        @viteReactRefresh
        @vite(['resources/js/app.jsx'])
        @inertiaHead
    </head>
    <body class="font-sans antialiased">
        @inertia
    </body>
</html>
