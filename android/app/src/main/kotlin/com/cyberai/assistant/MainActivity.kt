package com.cyberai.assistant

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.cyberai.assistant/platform"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isPackageInstalled" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "Package name cannot be empty", null)
                    } else {
                        result.success(isPackageInstalled(packageName))
                    }
                }
                "getInstalledApps" -> {
                    try {
                        val apps = getLaunchableApps()
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("DISCOVERY_FAILED", e.localizedMessage, null)
                    }
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "Package name cannot be empty", null)
                    } else {
                        val launched = launchAppByPackage(packageName)
                        result.success(launched)
                    }
                }
                "openUrlInPackage" -> {
                    val url = call.argument<String>("url")
                    val packageName = call.argument<String>("packageName")
                    if (url.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "URL cannot be empty", null)
                    } else {
                        val opened = openUrl(url, packageName)
                        result.success(opened)
                    }
                }
                "openSystemSettings" -> {
                    val settingType = call.argument<String>("settingType") ?: "general"
                    val opened = openSettings(settingType)
                    result.success(opened)
                }
                "searchMusic" -> {
                    val query = call.argument<String>("query")
                    val preferredPackage = call.argument<String>("preferredPackage")
                    if (query.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "Query cannot be empty", null)
                    } else {
                        val launched = searchMusicAction(query, preferredPackage)
                        result.success(launched)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName, 0)
            }
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        } catch (e: Exception) {
            false
        }
    }

    private fun getLaunchableApps(): List<Map<String, String>> {
        val appList = mutableListOf<Map<String, String>>()
        val intent = Intent(Intent.ACTION_MAIN)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)

        val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(0))
        } else {
            @Suppress("DEPRECATION")
            packageManager.queryIntentActivities(intent, 0)
        }

        for (resolveInfo in resolveInfos) {
            val pkg = resolveInfo.activityInfo.packageName
            val label = resolveInfo.loadLabel(packageManager).toString()
            appList.add(mapOf(
                "name" to label,
                "packageName" to pkg
            ))
        }

        return appList.sortedBy { it["name"]?.lowercase() ?: "" }
    }

    private fun launchAppByPackage(packageName: String): Boolean {
        return try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    private fun openUrl(url: String, packageName: String?): Boolean {
        return try {
            val uri = Uri.parse(url)
            val intent = Intent(Intent.ACTION_VIEW, uri)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            if (!packageName.isNullOrBlank() && isPackageInstalled(packageName)) {
                intent.setPackage(packageName)
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            // Fallback to browser without package constraint
            try {
                val fallbackIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                fallbackIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(fallbackIntent)
                true
            } catch (ex: Exception) {
                false
            }
        }
    }

    private fun openSettings(settingType: String): Boolean {
        val action = when (settingType) {
            "application_details" -> Settings.ACTION_APPLICATION_DETAILS_SETTINGS
            "wifi" -> Settings.ACTION_WIFI_SETTINGS
            "bluetooth" -> Settings.ACTION_BLUETOOTH_SETTINGS
            "sound" -> Settings.ACTION_SOUND_SETTINGS
            "display" -> Settings.ACTION_DISPLAY_SETTINGS
            else -> Settings.ACTION_SETTINGS
        }

        return try {
            val intent = Intent(action)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            if (action == Settings.ACTION_APPLICATION_DETAILS_SETTINGS) {
                intent.data = Uri.fromParts("package", packageName, null)
            }
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun searchMusicAction(query: String, preferredPackage: String?): Boolean {
        val encodedQuery = Uri.encode(query)
        val musicUrl = "https://music.youtube.com/search?q=$encodedQuery"

        if (!preferredPackage.isNullOrBlank() && isPackageInstalled(preferredPackage)) {
            val success = openUrl(musicUrl, preferredPackage)
            if (success) return true
        }

        // Try standard YouTube Music package if installed
        val officialYtMusic = "com.google.android.apps.youtube.music"
        if (isPackageInstalled(officialYtMusic)) {
            val success = openUrl(musicUrl, officialYtMusic)
            if (success) return true
        }

        // Try standard YouTube
        val officialYt = "com.google.android.youtube"
        val ytSearchUrl = "https://www.youtube.com/results?search_query=$encodedQuery"
        if (isPackageInstalled(officialYt)) {
            val success = openUrl(ytSearchUrl, officialYt)
            if (success) return true
        }

        // Default browser fallback
        return openUrl(musicUrl, null)
    }
}
