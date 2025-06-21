import { queryParams, type QueryParams } from './../../../wayfinder'
/**
* @see \App\Http\Controllers\FeedbackGroupController::create
* @see app/Http/Controllers/FeedbackGroupController.php:18
* @route '/feedback/groups'
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
    url: '/feedback/groups',
}

/**
* @see \App\Http\Controllers\FeedbackGroupController::create
* @see app/Http/Controllers/FeedbackGroupController.php:18
* @route '/feedback/groups'
*/
create.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return create.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\FeedbackGroupController::create
* @see app/Http/Controllers/FeedbackGroupController.php:18
* @route '/feedback/groups'
*/
create.post = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: create.url(options),
    method: 'post',
})

/**
* @see \App\Http\Controllers\FeedbackGroupController::add
* @see app/Http/Controllers/FeedbackGroupController.php:74
* @route '/feedback/groups/add'
*/
export const add = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: add.url(options),
    method: 'post',
})

add.definition = {
    methods: ['post'],
    url: '/feedback/groups/add',
}

/**
* @see \App\Http\Controllers\FeedbackGroupController::add
* @see app/Http/Controllers/FeedbackGroupController.php:74
* @route '/feedback/groups/add'
*/
add.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return add.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\FeedbackGroupController::add
* @see app/Http/Controllers/FeedbackGroupController.php:74
* @route '/feedback/groups/add'
*/
add.post = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: add.url(options),
    method: 'post',
})

/**
* @see \App\Http\Controllers\FeedbackGroupController::remove
* @see app/Http/Controllers/FeedbackGroupController.php:100
* @route '/feedback/groups/remove'
*/
export const remove = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: remove.url(options),
    method: 'post',
})

remove.definition = {
    methods: ['post'],
    url: '/feedback/groups/remove',
}

/**
* @see \App\Http\Controllers\FeedbackGroupController::remove
* @see app/Http/Controllers/FeedbackGroupController.php:100
* @route '/feedback/groups/remove'
*/
remove.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return remove.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\FeedbackGroupController::remove
* @see app/Http/Controllers/FeedbackGroupController.php:100
* @route '/feedback/groups/remove'
*/
remove.post = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: remove.url(options),
    method: 'post',
})

const groups = {
    create,
    add,
    remove,
}

export default groups