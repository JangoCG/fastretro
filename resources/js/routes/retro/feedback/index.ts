import { queryParams, type QueryParams } from './../../../wayfinder'
/**
* @see \App\Http\Controllers\RetroController::highlight
* @see app/Http/Controllers/RetroController.php:27
* @route '/retros/{retro}/feedback-highlights'
*/
export const highlight = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: highlight.url(args, options),
    method: 'post',
})

highlight.definition = {
    methods: ['post'],
    url: '/retros/{retro}/feedback-highlights',
}

/**
* @see \App\Http\Controllers\RetroController::highlight
* @see app/Http/Controllers/RetroController.php:27
* @route '/retros/{retro}/feedback-highlights'
*/
highlight.url = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    if (typeof args === 'string' || typeof args === 'number') {
        args = { retro: args }
    }

    if (typeof args === 'object' && !Array.isArray(args) && 'id' in args) {
        args = { retro: args.id }
    }

    if (Array.isArray(args)) {
        args = {
            retro: args[0],
        }
    }

    const parsedArgs = {
        retro: typeof args.retro === 'object'
        ? args.retro.id
        : args.retro,
    }

    return highlight.definition.url
            .replace('{retro}', parsedArgs.retro.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\RetroController::highlight
* @see app/Http/Controllers/RetroController.php:27
* @route '/retros/{retro}/feedback-highlights'
*/
highlight.post = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: highlight.url(args, options),
    method: 'post',
})

const feedback = {
    highlight,
}

export default feedback