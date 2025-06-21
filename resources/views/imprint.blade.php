@extends('layouts.legal')

@section('title', 'Imprint')
@section('description', 'Imprint for Fast Retro- Open Source Retrospective Tool')

@section('content')
    {!! app(\Spatie\LaravelMarkdown\MarkdownRenderer::class)->toHtml(
        File::get(resource_path('markdown/imprint.md'))
    ) !!}
@endsection
