import { queryParams, type QueryParams } from './../../../../wayfinder'
/**
* @see \App\Http\Controllers\SessionController::update
* @see app/Http/Controllers/SessionController.php:19
* @route '/sessions'
*/
export const update = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'patch',
} => ({
    url: update.url(options),
    method: 'patch',
})

update.definition = {
    methods: ['patch'],
    url: '/sessions',
}

/**
* @see \App\Http\Controllers\SessionController::update
* @see app/Http/Controllers/SessionController.php:19
* @route '/sessions'
*/
update.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return update.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\SessionController::update
* @see app/Http/Controllers/SessionController.php:19
* @route '/sessions'
*/
update.patch = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'patch',
} => ({
    url: update.url(options),
    method: 'patch',
})

const SessionController = { update }

export default SessionController