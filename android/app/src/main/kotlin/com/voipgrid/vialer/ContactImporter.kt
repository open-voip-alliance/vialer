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
        CoroutineScope(Dispatchers.IO).launch {
            val results = contacts
                .broadQuery()
                .find()
                .map {
                    Pigeon.PigeonContact.Builder().apply {
                        setChosenName(it.displayNamePrimary)
                        setCompany(it.organizations().firstOrNull()?.company)
                        setFamilyName(it.rawContacts.firstOrNull()?.name?.familyName)
                        setIdentifier(it.id.toString())
                        setGivenName(it.rawContacts.firstOrNull()?.name?.givenName)
                        setMiddleName(it.rawContacts.firstOrNull()?.name?.middleName)
                        setPhoneNumbers(it.phoneList().toPhoneItems())
                        setEmails(it.emailList().toEmailItems())
                    }.build()
                }


            result?.success(results)
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
        File(avatarDirectoryPath).listFiles()
            ?.filter { !validIds.contains(it.nameWithoutExtension) }
            ?.forEach { it.delete() }
}

fun List<Phone>.toPhoneItems() = filter { phone -> phone.number?.isNotBlank() == true }
        .map { phone -> Pigeon.PigeonContactItem.Builder().apply {
            setLabel(phone.displayLabel)
            setValue(phone.number!!)
        }.build() }
        .distinctBy { item -> item.value?.replace(Regex("[^0-9]"), "") }

fun List<Email>.toEmailItems() = filter { email -> email.primaryValue?.isNotBlank() == true }
    .map { email -> Pigeon.PigeonContactItem.Builder().apply {
        setLabel(email.displayLabel)
        setValue(email.primaryValue!!)
    }.build() }
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