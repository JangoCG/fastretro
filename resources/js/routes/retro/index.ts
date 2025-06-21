import { queryParams, type QueryParams } from './../../wayfinder'
import feedback from './feedback'
import phase from './phase'
import participant from './participant'
/**
* @see \App\Http\Controllers\RetroController::create
* @see app/Http/Controllers/RetroController.php:22
* @route '/retro/create'
*/
export const create = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: create.url(options),
    method: 'get',
})

create.definition = {
    methods: ['get','head'],
    url: '/retro/create',
}

/**
* @see \App\Http\Controllers\RetroController::create
* @see app/Http/Controllers/RetroController.php:22
* @route '/retro/create'
*/
create.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return create.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\RetroController::create
* @see app/Http/Controllers/RetroController.php:22
* @route '/retro/create'
*/
create.get = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: create.url(options),
    method: 'get',
})

/**
* @see \App\Http\Controllers\RetroController::create
* @see app/Http/Controllers/RetroController.php:22
* @route '/retro/create'
*/
create.head = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'head',
} => ({
    url: create.url(options),
    method: 'head',
})

/**
* @see \App\Http\Controllers\RetroController::store
* @see app/Http/Controllers/RetroController.php:35
* @route '/retro'
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
    url: '/retro',
}

/**
* @see \App\Http\Controllers\RetroController::store
* @see app/Http/Controllers/RetroController.php:35
* @route '/retro'
*/
store.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return store.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\RetroController::store
* @see app/Http/Controllers/RetroController.php:35
* @route '/retro'
*/
store.post = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: store.url(options),
    method: 'post',
})

/**
* @see \App\Http\Controllers\RetroController::show
* @see app/Http/Controllers/RetroController.php:100
* @route '/retro/{retro}'
*/
export const show = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: show.url(args, options),
    method: 'get',
})

show.definition = {
    methods: ['get','head'],
    url: '/retro/{retro}',
}

/**
* @see \App\Http\Controllers\RetroController::show
* @see app/Http/Controllers/RetroController.php:100
* @route '/retro/{retro}'
*/
show.url = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
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

    return show.definition.url
            .replace('{retro}', parsedArgs.retro.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\RetroController::show
* @see app/Http/Controllers/RetroController.php:100
* @route '/retro/{retro}'
*/
show.get = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'get',
} => ({
    url: show.url(args, options),
    method: 'get',
})

/**
* @see \App\Http\Controllers\RetroController::show
* @see app/Http/Controllers/RetroController.php:100
* @route '/retro/{retro}'
*/
show.head = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'head',
} => ({
    url: show.url(args, options),
    method: 'head',
})

/**
* @see \App\Http\Controllers\RetroController::join
* @see app/Http/Controllers/RetroController.php:80
* @route '/retro/{retro}/join'
*/
export const join = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: join.url(args, options),
    method: 'post',
})

join.definition = {
    methods: ['post'],
    url: '/retro/{retro}/join',
}

/**
* @see \App\Http\Controllers\RetroController::join
* @see app/Http/Controllers/RetroController.php:80
* @route '/retro/{retro}/join'
*/
join.url = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
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

    return join.definition.url
            .replace('{retro}', parsedArgs.retro.toString())
            .replace(/\/+$/, '') + queryParams(options)
}

/**
* @see \App\Http\Controllers\RetroController::join
* @see app/Http/Controllers/RetroController.php:80
* @route '/retro/{retro}/join'
*/
join.post = (args: { retro: string | { id: string } } | [retro: string | { id: string } ] | string | { id: string }, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: join.url(args, options),
    method: 'post',
})

const retro = {
    feedback,
    create,
    store,
    show,
    join,
    phase,
    participant,
}

export default retro