import { queryParams, type QueryParams } from './../../../wayfinder'
/**
* @see \App\Http\Controllers\ParticipantStatusController::toggleStatus
* @see app/Http/Controllers/ParticipantStatusController.php:16
* @route '/retro/{retro}/participant/toggle-status'
*/
export const toggleStatus = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: toggleStatus.url(args, options),
    method: 'post',
})

toggleStatus.definition = {
    methods: ['post'],
    url: '/retro/{retro}/participant/toggle-status',
}

/**
* @see \App\Http\Controllers\ParticipantStatusController::toggleStatus
* @see app/Http/Controllers/ParticipantStatusController.php:16
* @route '/retro/{retro}/participant/toggle-status'
*/
toggleStatus.url = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
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

    return toggleStatus.definition.url
            .replace('{retro}', parsedArgs.retro.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\ParticipantStatusController::toggleStatus
* @see app/Http/Controllers/ParticipantStatusController.php:16
* @route '/retro/{retro}/participant/toggle-status'
*/
toggleStatus.post = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: toggleStatus.url(args, options),
    method: 'post',
})

const participant = {
    toggleStatus,
}

export default participant