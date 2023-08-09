package com.voipgrid.vialer

import android.content.Context
import androidx.compose.ui.text.capitalize
import androidx.compose.ui.text.intl.Locale
import androidx.compose.ui.text.toLowerCase
import com.google.gson.Gson
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.File

class ContactImporter(context: Context) : Pigeon.Contacts {

    init {
    }

    override fun importContacts(cacheFilePath: String, result: Pigeon.Result<Void>) {
        result.success(null)
    }

    override fun importContactAvatars(avatarDirectoryPath: String, result: Pigeon.Result<Void>) {
        result.success(null)
    }
}