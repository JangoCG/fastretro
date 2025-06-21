<?php

use App\Models\User;
use Illuminate\Support\Facades\Broadcast;

Broadcast::channel('users.{id}', function (User $user, $id) {
    return (int) $user->id === (int) $id;
});


Broadcast::channel('retro.{retroId}', function (User $user, $retroId) {

    // if !userCanAccessRoom return false
    return true;
});
