import { queryParams, type QueryParams } from './../../../wayfinder'
/**
* @see \App\Http\Controllers\RetroController::complete
* @see app/Http/Controllers/RetroController.php:65
* @route '/retro/{retro}/phase'
*/
export const complete = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'patch',
} => ({
    url: complete.url(args, options),
    method: 'patch',
})

complete.definition = {
    methods: ['patch'],
    url: '/retro/{retro}/phase',
}

/**
* @see \App\Http\Controllers\RetroController::complete
* @see app/Http/Controllers/RetroController.php:65
* @route '/retro/{retro}/phase'
*/
complete.url = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
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

    return complete.definition.url
            .replace('{retro}', parsedArgs.retro.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\RetroController::complete
* @see app/Http/Controllers/RetroController.php:65
* @route '/retro/{retro}/phase'
*/
complete.patch = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'patch',
} => ({
    url: complete.url(args, options),
    method: 'patch',
})

const phase = {
    complete,
}

export default phase