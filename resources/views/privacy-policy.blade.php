@extends('layouts.legal')

@section('title', 'Privacy Policy')
@section('description', 'Privacy Policy for Fast Retro- Open Source Retrospective Tool')

@section('content')
    {!! app(\Spatie\LaravelMarkdown\MarkdownRenderer::class)->toHtml(
        File::get(resource_path('markdown/privacy-policy.md'))
    ) !!}
@endsection
