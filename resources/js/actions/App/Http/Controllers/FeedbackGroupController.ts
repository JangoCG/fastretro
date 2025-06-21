import { queryParams, type QueryParams } from './../../../../wayfinder'
/**
* @see \App\Http\Controllers\FeedbackGroupController::store
* @see app/Http/Controllers/FeedbackGroupController.php:18
* @route '/feedback/groups'
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
    url: '/feedback/groups',
}

/**
* @see \App\Http\Controllers\FeedbackGroupController::store
* @see app/Http/Controllers/FeedbackGroupController.php:18
* @route '/feedback/groups'
*/
store.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return store.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\FeedbackGroupController::store
* @see app/Http/Controllers/FeedbackGroupController.php:18
* @route '/feedback/groups'
*/
store.post = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: store.url(options),
    method: 'post',
})

/**
* @see \App\Http\Controllers\FeedbackGroupController::addToGroup
* @see app/Http/Controllers/FeedbackGroupController.php:74
* @route '/feedback/groups/add'
*/
export const addToGroup = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: addToGroup.url(options),
    method: 'post',
})

addToGroup.definition = {
    methods: ['post'],
    url: '/feedback/groups/add',
}

/**
* @see \App\Http\Controllers\FeedbackGroupController::addToGroup
* @see app/Http/Controllers/FeedbackGroupController.php:74
* @route '/feedback/groups/add'
*/
addToGroup.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return addToGroup.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\FeedbackGroupController::addToGroup
* @see app/Http/Controllers/FeedbackGroupController.php:74
* @route '/feedback/groups/add'
*/
addToGroup.post = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: addToGroup.url(options),
    method: 'post',
})

/**
* @see \App\Http\Controllers\FeedbackGroupController::removeFromGroup
* @see app/Http/Controllers/FeedbackGroupController.php:100
* @route '/feedback/groups/remove'
*/
export const removeFromGroup = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: removeFromGroup.url(options),
    method: 'post',
})

removeFromGroup.definition = {
    methods: ['post'],
    url: '/feedback/groups/remove',
}

/**
* @see \App\Http\Controllers\FeedbackGroupController::removeFromGroup
* @see app/Http/Controllers/FeedbackGroupController.php:100
* @route '/feedback/groups/remove'
*/
removeFromGroup.url = (options?: { query?: QueryParams, mergeQuery?: QueryParams }) => {
    return removeFromGroup.definition.url + queryParams(options)
}

/**
* @see \App\Http\Controllers\FeedbackGroupController::removeFromGroup
* @see app/Http/Controllers/FeedbackGroupController.php:100
* @route '/feedback/groups/remove'
*/
removeFromGroup.post = (options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
    url: string,
    method: 'post',
} => ({
    url: removeFromGroup.url(options),
    method: 'post',
})

const FeedbackGroupController = { store, addToGroup, removeFromGroup }

export default FeedbackGroupController