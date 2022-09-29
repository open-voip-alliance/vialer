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
    private val gson = Gson()
    private val contacts: Contacts

    init {
        contacts = Contacts(context)
    }

    override fun importContacts(
        cacheFilePath: String,
        result: Pigeon.Result<Void>?,
    ) {
        CoroutineScope(Dispatchers.IO).launch {
            val results = contacts
                .broadQuery()
                .find()
                .map {
                    Contact(
                        identifier = it.id.toString(),
                        givenName = it.rawContacts.firstOrNull()?.name?.givenName,
                        middleName = it.rawContacts.firstOrNull()?.name?.middleName,
                        familyName = it.rawContacts.firstOrNull()?.name?.familyName,
                        chosenName = it.displayNamePrimary,
                        company = it.organizations().firstOrNull()?.company,
                        phoneNumbers = it.phoneList().toPhoneItems(),
                        emails = it.emailList().toEmailItems(),
                    )
                }

            if (results.isNotEmpty()) {
                File(cacheFilePath).writeText(gson.toJson(results))
            }
            result?.success(null)
        }
    }

    override fun importContactAvatars(avatarDirectoryPath: String, result: Pigeon.Result<Void>?) {
        CoroutineScope(Dispatchers.IO).launch {
            val results = contacts
                .query()
                .where { Contact.PhotoThumbnailUri.isNotNullOrEmpty() }
                .include(Fields.Contact.PhotoThumbnailUri)
                .find()
                .shuffled()
                .onEach {
                    it.photoThumbnailBytes(contacts)?.let { bytes ->
                        File(avatarDirectoryPath.avatarPath(it)).writeBytes(bytes)
                    }
                }

            launch {
                removeOrphanedAvatars(
                    avatarDirectoryPath,
                    results.map { it.id.toString() }
                )
            }

            result?.success(null)
        }
    }

    private fun removeOrphanedAvatars(avatarDirectoryPath: String, validIds: List<String>) =
        File(avatarDirectoryPath).listFiles()?.forEach {
            if (!validIds.contains(it.nameWithoutExtension)) {
                it.delete()
            }
        }
}

data class Contact(
    val givenName: String?,
    val middleName: String?,
    val familyName: String?,
    val chosenName: String?,
    val phoneNumbers: List<Item>,
    val emails: List<Item>,
    val identifier: String?,
    val company: String?,
)

data class Item(
    val label: String,
    val value: String,
)

fun List<Phone>.toPhoneItems() = filter { phone -> phone.number?.isNotBlank() == true }
        .map { phone -> Item(phone.displayLabel, phone.number!!) }
        .distinctBy { item -> item.value.replace(Regex("[^0-9]"), "") }

fun List<Email>.toEmailItems() = filter { email -> email.primaryValue?.isNotBlank() == true }
    .map { email -> Item(email.displayLabel, email.primaryValue!!) }
    .distinctBy { item -> item.value }

fun String.formatLabel() = toLowerCase(Locale.current).capitalize(Locale.current)

fun String.avatarPath(contact: contacts.core.entities.Contact) = "$this/${contact.id}.jpg"

val Phone.displayLabel: String
    get() = when {
        label?.isNotBlank() == true -> label!!.formatLabel()
        type != null -> type!!.name.formatLabel()
        else -> ""
    }

val Email.displayLabel: String
    get() = when {
        label?.isNotBlank() == true -> label!!.formatLabel()
        type?.name != null -> type?.name!!.formatLabel()
        else -> ""
    }