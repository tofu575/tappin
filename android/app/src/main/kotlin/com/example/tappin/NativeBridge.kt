package com.example.tappin

import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

private const val METHOD_LOCATION_FETCH = "location/fetch"
private const val METHOD_LOCATION_OPEN_SETTINGS = "location/openSettings"
private const val METHOD_STORAGE_GET_PINS = "storage/getPins"
private const val METHOD_STORAGE_SAVE_PIN = "storage/savePin"
private const val METHOD_STORAGE_DELETE_PIN = "storage/deletePin"
private const val METHOD_STORAGE_UPDATE_MEMO = "storage/updateMemo"
private const val METHOD_STORAGE_UPDATE_REVIEW_STATUS = "storage/updateReviewStatus"
private const val METHOD_OVERLAY_SHOW = "overlay/show"
private const val METHOD_OVERLAY_HIDE = "overlay/hide"

private const val ERROR_PERMISSION_DENIED = "PERMISSION_DENIED"
private const val ERROR_LOCATION_UNAVAILABLE = "LOCATION_UNAVAILABLE"
private const val ERROR_INVALID_ARGUMENTS = "INVALID_ARGUMENTS"
private const val ERROR_STORAGE_ERROR = "STORAGE_ERROR"
private const val ERROR_OVERLAY_PERMISSION_REQUIRED = "OVERLAY_PERMISSION_REQUIRED"

class NativeBridge(private val context: Context) : MethodChannel.MethodCallHandler {

    private val executor = Executors.newSingleThreadExecutor()

    fun register(channel: MethodChannel) {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        executor.execute {
            when (call.method) {
                METHOD_LOCATION_FETCH -> handleLocationFetch(result)
                METHOD_LOCATION_OPEN_SETTINGS -> handleOpenLocationSettings(result)
                METHOD_STORAGE_GET_PINS -> handleGetPins(result)
                METHOD_STORAGE_SAVE_PIN -> handleSavePin(call, result)
                METHOD_STORAGE_DELETE_PIN -> handleDeletePin(call, result)
                METHOD_STORAGE_UPDATE_MEMO -> handleUpdateMemo(call, result)
                METHOD_STORAGE_UPDATE_REVIEW_STATUS -> handleUpdateReviewStatus(call, result)
                METHOD_OVERLAY_SHOW -> handleOverlayShow(result)
                METHOD_OVERLAY_HIDE -> handleOverlayHide(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun handleOpenLocationSettings(result: MethodChannel.Result) {
        val intent = Intent(
            Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            android.net.Uri.fromParts("package", context.packageName, null),
        ).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
        result.success(null)
    }

    private fun handleLocationFetch(result: MethodChannel.Result) {
        try {
            val location = LocationHelper.fetchLocation(context)
            if (location == null) {
                result.error(ERROR_LOCATION_UNAVAILABLE, "位置情報を取得できませんでした", null)
            } else {
                result.success(
                    mapOf(
                        "latitude" to location.latitude,
                        "longitude" to location.longitude,
                    )
                )
            }
        } catch (e: SecurityException) {
            result.error(ERROR_PERMISSION_DENIED, "位置情報の許可が必要です", null)
        }
    }

    private fun handleGetPins(result: MethodChannel.Result) {
        try {
            val pins = StorageHelper.fetchPins(context)
            result.success(pins)
        } catch (e: Exception) {
            result.error(ERROR_STORAGE_ERROR, e.message, null)
        }
    }

    private fun handleSavePin(call: MethodCall, result: MethodChannel.Result) {
        val latitude = call.argument<Any>("latitude")
        val longitude = call.argument<Any>("longitude")
        val createdAt = call.argument<Any>("createdAt")

        if (latitude == null || longitude == null || createdAt == null) {
            result.error(ERROR_INVALID_ARGUMENTS, "latitude, longitude, createdAt が必要です", null)
            return
        }

        try {
            val id = StorageHelper.savePin(
                context,
                (latitude as Number).toDouble(),
                (longitude as Number).toDouble(),
                (createdAt as Number).toLong(),
            )
            result.success(id)
        } catch (e: Exception) {
            result.error(ERROR_STORAGE_ERROR, e.message, null)
        }
    }

    private fun handleUpdateMemo(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<Any>("id")
        val memo = call.argument<String>("memo")

        if (id == null || memo == null) {
            result.error(ERROR_INVALID_ARGUMENTS, "id と memo が必要です", null)
            return
        }

        try {
            StorageHelper.updateMemo(context, (id as Number).toLong(), memo)
            result.success(null)
        } catch (e: Exception) {
            result.error(ERROR_STORAGE_ERROR, e.message, null)
        }
    }

    private fun handleUpdateReviewStatus(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<Any>("id")
        val reviewed = call.argument<Boolean>("reviewed")

        if (id == null || reviewed == null) {
            result.error(ERROR_INVALID_ARGUMENTS, "id と reviewed が必要です", null)
            return
        }

        try {
            StorageHelper.updateReviewStatus(context, (id as Number).toLong(), reviewed)
            result.success(null)
        } catch (e: Exception) {
            result.error(ERROR_STORAGE_ERROR, e.message, null)
        }
    }

    private fun handleOverlayShow(result: MethodChannel.Result) {
        if (!Settings.canDrawOverlays(context)) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                android.net.Uri.parse("package:${context.packageName}")
            ).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
            result.error(ERROR_OVERLAY_PERMISSION_REQUIRED, "オーバーレイ表示の許可が必要です", null)
            return
        }
        val intent = Intent(context, OverlayService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
        result.success(null)
    }

    private fun handleOverlayHide(result: MethodChannel.Result) {
        context.stopService(Intent(context, OverlayService::class.java))
        result.success(null)
    }

    private fun handleDeletePin(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<Any>("id")

        if (id == null) {
            result.error(ERROR_INVALID_ARGUMENTS, "id が必要です", null)
            return
        }

        try {
            StorageHelper.deletePin(context, (id as Number).toLong())
            result.success(null)
        } catch (e: Exception) {
            result.error(ERROR_STORAGE_ERROR, e.message, null)
        }
    }
}
