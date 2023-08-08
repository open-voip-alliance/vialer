package com.voipgrid.vialer

import android.content.Context
import androidx.compose.ui.text.capitalize
import androidx.compose.ui.text.intl.Locale
import androidx.compose.ui.text.toLowerCase
import com.google.gson.Gson
import contacts.core.Contacts
import contacts.core.Fields
import contacts.core.entities.Email
import contacts.core.entities.Phone
import contacts.core.isNotNullOrEmpty
import contacts.core.util.*
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