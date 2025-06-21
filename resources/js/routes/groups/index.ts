import { queryParams, type QueryParams } from './../../wayfinder'
/**
* @see \App\Http\Controllers\BoardController::create
* @see app/Http/Controllers/BoardController.php:56
* @route '/groups'
*/
export const create = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: create.url(options),
    method: 'post',
})

create.definition = {
    methods: ['post'],
    url: '/groups',
}

/**
* @see \App\Http\Controllers\BoardController::create
* @see app/Http/Controllers/BoardController.php:56
* @route '/groups'
*/
create.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return create.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\BoardController::create
* @see app/Http/Controllers/BoardController.php:56
* @route '/groups'
*/
create.post = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: create.url(options),
    method: 'post',
})

/**
* @see \App\Http\Controllers\BoardController::ungroup
* @see app/Http/Controllers/BoardController.php:85
* @route '/groups/{group}/ungroup'
*/
export const ungroup = (args: { group: number | { id: number } } | [group: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: ungroup.url(args, options),
    method: 'post',
})

ungroup.definition = {
    methods: ['post'],
    url: '/groups/{group}/ungroup',
}

/**
* @see \App\Http\Controllers\BoardController::ungroup
* @see app/Http/Controllers/BoardController.php:85
* @route '/groups/{group}/ungroup'
*/
ungroup.url = (args: { group: number | { id: number } } | [group: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    if (typeof args === 'string' || typeof args === 'number') {
        args = { group: args }
    }

    if (typeof args === 'object' && !Array.isArray(args) && 'id' in args) {
        args = { group: args.id }
    }

    if (Array.isArray(args)) {
        args = {
            group: args[0],
        }
    }

    const parsedArgs = {
        group: typeof args.group === 'object'
        ? args.group.id
        : args.group,
    }

    return ungroup.definition.url
            .replace('{group}', parsedArgs.group.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\BoardController::ungroup
* @see app/Http/Controllers/BoardController.php:85
* @route '/groups/{group}/ungroup'
*/
ungroup.post = (args: { group: number | { id: number } } | [group: number | { id: number } ] | number | { id: number }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: ungroup.url(args, options),
    method: 'post',
})

const groups = {
    create,
    ungroup,
}

export default groups