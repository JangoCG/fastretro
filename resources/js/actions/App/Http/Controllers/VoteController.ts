import { queryParams, type QueryParams } from './../../../../wayfinder'
/**
* @see \App\Http\Controllers\VoteController::store
* @see app/Http/Controllers/VoteController.php:22
* @route '/votes'
*/
export const store = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: store.url(options),
    method: 'post',
})

store.definition = {
    methods: ['post'],
    url: '/votes',
}

/**
* @see \App\Http\Controllers\VoteController::store
* @see app/Http/Controllers/VoteController.php:22
* @route '/votes'
*/
store.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return store.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\VoteController::store
* @see app/Http/Controllers/VoteController.php:22
* @route '/votes'
*/
store.post = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: store.url(options),
    method: 'post',
})

/**
* @see \App\Http\Controllers\VoteController::destroy
* @see app/Http/Controllers/VoteController.php:82
* @route '/votes/{vote}'
*/
export const destroy = (args: { vote: number | { id: number } } | [vote: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'delete',
} => ({
    url: destroy.url(args, options),
    method: 'delete',
})

destroy.definition = {
    methods: ['delete'],
    url: '/votes/{vote}',
}

/**
* @see \App\Http\Controllers\VoteController::destroy
* @see app/Http/Controllers/VoteController.php:82
* @route '/votes/{vote}'
*/
destroy.url = (args: { vote: number | { id: number } } | [vote: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    if (typeof args === 'string' || typeof args === 'number') {
        args = { vote: args }
    }

    if (typeof args === 'object' && !Array.isArray(args) && 'id' in args) {
        args = { vote: args.id }
    }

    if (Array.isArray(args)) {
        args = {
            vote: args[0],
        }
    }

    const parsedArgs = {
        vote: typeof args.vote === 'object'
        ? args.vote.id
        : args.vote,
    }

    return destroy.definition.url
            .replace('{vote}', parsedArgs.vote.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\VoteController::destroy
* @see app/Http/Controllers/VoteController.php:82
* @route '/votes/{vote}'
*/
destroy.delete = (args: { vote: number | { id: number } } | [vote: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'delete',
} => ({
    url: destroy.url(args, options),
    method: 'delete',
})

const VoteController = { store, destroy }

export default VoteController