package com.voipgrid.vialer

import android.content.Context
import androidx.compose.ui.text.capitalize
import androidx.compose.ui.text.intl.Locale
import androidx.compose.ui.text.toLowerCase
import contacts.core.Contacts
import contacts.core.Fields
import contacts.core.entities.Email
import contacts.core.entities.Phone
import contacts.core.isNotNullOrEmpty
import contacts.core.util.emailList
import contacts.core.util.organizations
import contacts.core.util.phoneList
import contacts.core.util.photoThumbnailBytes
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.io.File

class ContactImporter(context: Context) : Pigeon.Contacts {
    private val contacts: Contacts

    init {
        contacts = Contacts(context)
    }

    override fun fetchContacts(
        result: Pigeon.Result<List<Pigeon.PigeonContact>>?,
    ) {
        result?.success(listOf())
    }

    override fun importContactAvatars(avatarDirectoryPath: String, result: Pigeon.Result<Void>?) {
        result?.success(null)
    }
}